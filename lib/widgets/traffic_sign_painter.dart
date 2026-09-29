import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/traffic_sign.dart';

/// 道路標識を CustomPainter でゼロから描画する汎用 Widget。
///
/// 画像ファイルは一切使用せず、[TrafficSign] の形状・色・図柄・文字・斜線の
/// データだけから描画する。1つの Widget で全標識に対応する。
class TrafficSignWidget extends StatelessWidget {
  const TrafficSignWidget({
    super.key,
    required this.sign,
    this.size = 200,
    this.fontFamily,
  });

  final TrafficSign sign;
  final double size;

  /// 標識内の文字に使うフォント（null ならアプリ既定のフォント）
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '道路標識の図',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: TrafficSignPainter(sign, fontFamily: fontFamily)),
      ),
    );
  }
}

/// [TrafficSign] を描画する CustomPainter。
///
/// 描画順:
///   1. 外形（最外周フチ → 枠線 → 地色 の3層）
///   2. 地色の内側にクリップして 図柄 / 横棒 / 文字 / アイコン
///   3. 赤い斜線（単線 or ×字）
class TrafficSignPainter extends CustomPainter {
  TrafficSignPainter(this.sign, {this.fontFamily});

  final TrafficSign sign;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final origin = Offset((size.width - s) / 2, (size.height - s) / 2);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);

    final rimW = s * sign.rimWidthRatio;
    final borderW = s * sign.borderWidthRatio;

    // 1. 外形の3層
    final outer = _shapePath(s, 0);
    canvas.drawShadow(outer, Colors.black, 3, false);
    _fill(canvas, outer, sign.rimColor ?? sign.borderColor ?? sign.backgroundColor);
    if (sign.borderColor != null && borderW > 0) {
      _fill(canvas, _shapePath(s, rimW), sign.borderColor!);
    }
    final inner = _shapePath(s, rimW + borderW);
    _fill(canvas, inner, sign.backgroundColor);

    // 2. 内側の要素（地色の範囲にクリップ）
    final geo = _innerGeometry(s, rimW + borderW);
    canvas.save();
    canvas.clipPath(inner);

    if (sign.hasHorizontalBar) {
      _drawHorizontalBar(canvas, geo);
    }
    if (sign.symbol != SignSymbol.none) {
      _SymbolPainter(canvas, geo.center, geo.radius * (sign.shape == SignShape.diamond ? 0.72 : 0.62), sign.symbolColor)
          .draw(sign.symbol);
    }
    if (sign.centerIcon != null) {
      _drawIcon(canvas, geo, sign.centerIcon!);
    }
    if (sign.centerText != null) {
      _drawCenterText(canvas, s, geo);
    }

    // 3. 禁止の赤線（円の枠線内側に収める）
    switch (sign.slash) {
      case SignSlash.none:
        break;
      case SignSlash.single:
        _drawSlash(canvas, s, geo, false);
      case SignSlash.cross:
        _drawSlash(canvas, s, geo, false);
        _drawSlash(canvas, s, geo, true);
    }
    canvas.restore();
    canvas.restore();
  }

  void _fill(Canvas canvas, Path path, Color color) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  // ---- 外形 ------------------------------------------------------------

  /// 一辺 [s] の正方形に収まる外形を、内側へ [inset] だけ縮めたパス。
  Path _shapePath(double s, double inset) {
    final c = Offset(s / 2, s / 2);
    switch (sign.shape) {
      case SignShape.circle:
        return Path()
          ..addOval(Rect.fromCircle(center: c, radius: s / 2 - inset));
      case SignShape.square:
        final rect = Rect.fromLTWH(0, 0, s, s).deflate(inset);
        final r = math.max(s * 0.06 - inset * 0.5, s * 0.01);
        return Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
      case SignShape.diamond:
        // 頂点までの距離 R。辺から垂直に inset だけ縮める → R - inset*√2
        final r = s / 2 - inset * math.sqrt2;
        return _roundedPolygon([
          c + Offset(0, -r),
          c + Offset(r, 0),
          c + Offset(0, r),
          c + Offset(-r, 0),
        ], s * 0.04);
      case SignShape.invertedTriangle:
        return _roundedPolygon(_triangleVertices(s, inset), s * 0.05);
    }
  }

  /// 正三角形（逆向き）の頂点。上辺が幅 s に一致するよう配置する。
  List<Offset> _triangleVertices(double s, double inset) {
    final h = s * math.sqrt(3) / 2;
    final top = (s - h) / 2;
    final centroid = Offset(s / 2, top + h / 3);
    // 外接円半径 R = s/√3。内側へ inset 縮めると R' = R - 2*inset
    final r = s / math.sqrt(3) - 2 * inset;
    return [
      centroid + Offset(-r * math.cos(math.pi / 6), -r * math.sin(math.pi / 6)),
      centroid + Offset(r * math.cos(math.pi / 6), -r * math.sin(math.pi / 6)),
      centroid + Offset(0, r),
    ];
  }

  /// 角を丸めた多角形パス。
  Path _roundedPolygon(List<Offset> pts, double radius) {
    final path = Path();
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final prev = pts[(i - 1 + n) % n];
      final cur = pts[i];
      final next = pts[(i + 1) % n];
      final toPrev = prev - cur;
      final toNext = next - cur;
      final d = math.min(radius, math.min(toPrev.distance, toNext.distance) / 2);
      final a = cur + toPrev / toPrev.distance * d;
      final b = cur + toNext / toNext.distance * d;
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    path.close();
    return path;
  }

  /// 地色部分の中心と、図柄を置ける目安の半径。
  _InnerGeometry _innerGeometry(double s, double inset) {
    switch (sign.shape) {
      case SignShape.circle:
        return _InnerGeometry(Offset(s / 2, s / 2), s / 2 - inset);
      case SignShape.square:
        return _InnerGeometry(Offset(s / 2, s / 2), s / 2 - inset);
      case SignShape.diamond:
        // ひし形の内接円半径 = R/√2
        return _InnerGeometry(
          Offset(s / 2, s / 2),
          (s / 2 - inset * math.sqrt2) / math.sqrt2 * 1.15,
        );
      case SignShape.invertedTriangle:
        final v = _triangleVertices(s, inset);
        final centroid = Offset(s / 2, (v[0].dy + v[0].dy + v[2].dy) / 3);
        // 内接円半径 = R/2
        return _InnerGeometry(centroid, (s / math.sqrt(3) - 2 * inset) / 2);
    }
  }

  // ---- 内側要素 ----------------------------------------------------------

  void _drawHorizontalBar(Canvas canvas, _InnerGeometry g) {
    final w = g.radius * 1.5;
    final h = g.radius * 0.36;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: g.center, width: w, height: h),
        Radius.circular(h * 0.12),
      ),
      Paint()..color = SignColors.white,
    );
  }

  void _drawCenterText(Canvas canvas, double s, _InnerGeometry g) {
    final text = sign.centerText!;
    final hasSub = sign.subText != null;
    final fontSize = s * sign.centerTextScale;
    final maxWidth = sign.shape == SignShape.invertedTriangle
        ? g.radius * 2.0
        : g.radius * 1.8;

    final main = _layoutText(
      text,
      TextStyle(
        color: sign.centerTextColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: text.length >= 3 ? -fontSize * 0.04 : 0,
      ),
      maxWidth,
    );

    TextPainter? sub;
    if (hasSub) {
      sub = _layoutText(
        sign.subText!,
        TextStyle(
          color: sign.centerTextColor,
          fontSize: fontSize * 0.5,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: fontSize * 0.04,
        ),
        maxWidth,
      );
    }

    final gap = hasSub ? fontSize * 0.12 : 0.0;
    final totalH = main.height + (sub?.height ?? 0) + gap;
    // 逆三角形は重心がやや下にあるので文字を少し上へ寄せる
    final dyShift =
        sign.shape == SignShape.invertedTriangle ? -g.radius * 0.12 : 0.0;
    var y = g.center.dy - totalH / 2 + dyShift + s * sign.centerTextOffsetY;
    main.paint(canvas, Offset(g.center.dx - main.width / 2, y));
    if (sub != null) {
      y += main.height + gap;
      sub.paint(canvas, Offset(g.center.dx - sub.width / 2, y));
    }
  }

  /// 最大幅を超える場合は横方向に縮めて収める。
  TextPainter _layoutText(String text, TextStyle style, double maxWidth) {
    var tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    if (tp.width > maxWidth && tp.width > 0) {
      final ratio = maxWidth / tp.width;
      tp = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(fontSize: (style.fontSize ?? 14) * ratio),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
    }
    return tp;
  }

  void _drawIcon(Canvas canvas, _InnerGeometry g, IconData icon) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: g.radius * 1.3,
          color: sign.symbolColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, g.center - Offset(tp.width / 2, tp.height / 2));
  }

  /// 左上→右下（mirror=true で右上→左下）の赤い斜線。
  void _drawSlash(Canvas canvas, double s, _InnerGeometry g, bool mirror) {
    final r = g.radius;
    final d = r / math.sqrt2;
    final c = g.center;
    final start = mirror ? c + Offset(d, -d) : c + Offset(-d, -d);
    final end = mirror ? c + Offset(-d, d) : c + Offset(d, d);
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = SignColors.red
        ..strokeWidth = s * 0.085
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant TrafficSignPainter oldDelegate) =>
      oldDelegate.sign.id != sign.id ||
      oldDelegate.fontFamily != fontFamily;
}

class _InnerGeometry {
  const _InnerGeometry(this.center, this.radius);

  final Offset center;
  final double radius;
}

/// 図柄の描画。座標は中心 [c] を原点とし、[k] を 1.0 とした正規化座標で指定する
/// （概ね -1.0〜1.0 の範囲に収まるように設計）。
class _SymbolPainter {
  _SymbolPainter(this.canvas, this.c, this.k, this.color);

  final Canvas canvas;
  final Offset c;
  final double k;
  final Color color;

  Offset p(double x, double y) => c + Offset(x * k, y * k);

  Paint get _fillPaint => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  Paint _stroke(double w, {Color? paintColor, StrokeCap cap = StrokeCap.round}) =>
      Paint()
        ..color = paintColor ?? color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * k
        ..strokeCap = cap
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

  Path _poly(List<List<double>> pts) {
    final path = Path()..moveTo(p(pts[0][0], pts[0][1]).dx, p(pts[0][0], pts[0][1]).dy);
    for (final pt in pts.skip(1)) {
      final o = p(pt[0], pt[1]);
      path.lineTo(o.dx, o.dy);
    }
    return path..close();
  }

  void _circle(double x, double y, double r, Paint paint) {
    canvas.drawCircle(p(x, y), r * k, paint);
  }

  void _line(double x1, double y1, double x2, double y2, Paint paint) {
    canvas.drawLine(p(x1, y1), p(x2, y2), paint);
  }

  void _rrect(double l, double t, double r, double b, double radius, Paint paint) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        p(l, t).dx,
        p(l, t).dy,
        p(r, b).dx,
        p(r, b).dy,
        Radius.circular(radius * k),
      ),
      paint,
    );
  }

  void draw(SignSymbol symbol) {
    switch (symbol) {
      case SignSymbol.none:
        break;
      case SignSymbol.twoRiders:
        _motorcycle(withPassenger: true);
      case SignSymbol.motorcycle:
        _motorcycle(withPassenger: false);
      case SignSymbol.twoCars:
        _twoCars();
      case SignSymbol.uTurnArrow:
        _uTurn();
      case SignSymbol.arrowUp:
        _arrowUp();
      case SignSymbol.oneWayArrow:
        _oneWayArrow();
      case SignSymbol.priorityRoad:
        _priorityRoad();
      case SignSymbol.train:
        _train();
      case SignSymbol.children:
        _children();
      case SignSymbol.trafficLight:
        _trafficLight();
      case SignSymbol.roadNarrows:
        _roadNarrows();
      case SignSymbol.rightCurve:
        _rightCurve();
      case SignSymbol.slippery:
        _slippery();
      case SignSymbol.pedestrian:
        _pedestrian(-0.04, 0.02, 1.12, _fillPaint, _stroke);
      case SignSymbol.bicycle:
        _bicycle();
      case SignSymbol.turnRightArrow:
        _turnArrow(1, 0.26);
      case SignSymbol.arrowLeft:
        _turnArrow(-1, 0.4);
      case SignSymbol.arrowStraightRight:
        _arrowStraightRight();
      case SignSymbol.speedUnderline:
        _rrect(-0.72, 0.62, 0.72, 0.8, 0.02, _fillPaint);
      case SignSymbol.heightMarkers:
        _heightMarkers();
      case SignSymbol.horn:
        _horn();
      case SignSymbol.crosswalk:
        _crosswalk();
      case SignSymbol.stopLineBar:
        _rrect(-1.2, 0.5, 1.2, 0.82, 0.02, _fillPaint);
      case SignSymbol.crossroad:
        _rrect(-0.17, -0.95, 0.17, 0.95, 0, _fillPaint);
        _rrect(-0.95, -0.17, 0.95, 0.17, 0, _fillPaint);
      case SignSymbol.tJunction:
        _rrect(-0.95, -0.62, 0.95, -0.28, 0, _fillPaint);
        _rrect(-0.17, -0.62, 0.17, 0.95, 0, _fillPaint);
      case SignSymbol.leftCurve:
        _rightCurve(mirror: true);
      case SignSymbol.twoWayTraffic:
        _twoWayTraffic();
      case SignSymbol.roadWorks:
        _roadWorks();
      case SignSymbol.deer:
        _deer();
      case SignSymbol.exclamation:
        canvas.drawPath(
          _poly([
            [-0.17, -0.92],
            [0.17, -0.92],
            [0.08, 0.36],
            [-0.08, 0.36],
          ]),
          _fillPaint,
        );
        _circle(0, 0.7, 0.16, _fillPaint);
      case SignSymbol.carFront:
        _carFront();
      case SignSymbol.bicycleCrossing:
        _bicycleCrossing();
      case SignSymbol.safetyZoneMarkers:
        _safetyZoneMarkers();
      case SignSymbol.laneArrows:
        _laneArrows();
      case SignSymbol.hornZone:
        _hornZone();
      case SignSymbol.overtakingProtrusion:
        _overtakingProtrusion();
    }
  }

  /// 自転車＋足もとに横断帯の縞（自転車横断帯）。
  void _bicycleCrossing() {
    _bicycle();
    final black = Paint()..color = SignColors.black;
    for (var i = -2; i <= 2; i++) {
      final x = i * 0.36;
      _rrect(x - 0.12, 0.78, x + 0.12, 0.94, 0.01, black);
    }
  }

  /// 縦に並んだ2つの三角マーカー（安全地帯）。
  void _safetyZoneMarkers() {
    canvas.drawPath(
      _poly([
        [-0.32, -0.92],
        [0.32, -0.92],
        [0, -0.3],
      ]),
      _fillPaint,
    );
    canvas.drawPath(
      _poly([
        [-0.32, 0.1],
        [0.32, 0.1],
        [0, 0.72],
      ]),
      _fillPaint,
    );
  }

  /// 並んだ2本の上向き矢印（車両通行区分）。
  void _laneArrows() {
    void arrow(double dx) {
      final shaft = _stroke(0.14, cap: StrokeCap.butt);
      _line(dx, 0.9, dx, -0.3, shaft);
      canvas.drawPath(
        _poly([
          [dx, -0.95],
          [dx + 0.26, -0.3],
          [dx - 0.26, -0.3],
        ]),
        _fillPaint,
      );
    }

    arrow(-0.4);
    arrow(0.4);
  }

  /// ラッパ形の警笛＋区間の両端を示す縦線（警笛区間）。
  void _hornZone() {
    _horn();
    final bar = _stroke(0.09, cap: StrokeCap.butt);
    _line(-1.05, -0.5, -1.05, 0.5, bar);
    _line(1.05, -0.5, 1.05, 0.5, bar);
  }

  /// 並んだ2台の車＋右側へはみ出す矢印（追越しのための右側部分はみ出し通行禁止）。
  void _overtakingProtrusion() {
    _twoCars();
    final shaft = _stroke(0.08, cap: StrokeCap.butt);
    _line(0, 0.3, 0.5, 0.3, shaft);
    canvas.drawPath(
      _poly([
        [0.68, 0.3],
        [0.42, 0.16],
        [0.42, 0.44],
      ]),
      _fillPaint,
    );
  }

  /// 正面から見た乗用車（青地に白。窓とライトは地色の青で抜く）。
  void _carFront() {
    final paint = _fillPaint;
    final cut = Paint()..color = SignColors.blue;
    // キャビン
    canvas.drawPath(
      _poly([
        [-0.66, -0.12],
        [-0.46, -0.62],
        [0.46, -0.62],
        [0.66, -0.12],
      ]),
      paint,
    );
    // ボディ
    _rrect(-0.95, -0.16, 0.95, 0.42, 0.1, paint);
    // タイヤ
    _rrect(-0.86, 0.36, -0.5, 0.66, 0.05, paint);
    _rrect(0.5, 0.36, 0.86, 0.66, 0.05, paint);
    // フロントガラス
    canvas.drawPath(
      _poly([
        [-0.52, -0.2],
        [-0.38, -0.52],
        [0.38, -0.52],
        [0.52, -0.2],
      ]),
      cut,
    );
    // ライトとグリル
    _circle(-0.64, 0.12, 0.11, cut);
    _circle(0.64, 0.12, 0.11, cut);
    _rrect(-0.3, 0.06, 0.3, 0.18, 0.02, cut);
  }

  /// 右向きに歩く人。中心 ([cx],[cy])、倍率 [sc]。
  void _pedestrian(
    double cx,
    double cy,
    double sc,
    Paint fill,
    Paint Function(double w, {Color? paintColor, StrokeCap cap}) stroke,
  ) {
    double x(double v) => cx + v * sc;
    double y(double v) => cy + v * sc;
    _circle(x(0.1), y(-0.78), 0.17 * sc, fill);
    // 胴体
    _line(x(0.06), y(-0.5), x(0), y(0.12), stroke(0.26 * sc));
    // 腕（前後に振る）
    _line(x(0.06), y(-0.42), x(0.36), y(-0.02), stroke(0.11 * sc));
    _line(x(0.04), y(-0.42), x(-0.3), y(-0.06), stroke(0.11 * sc));
    // 脚（前後に開く）
    final leg = stroke(0.14 * sc);
    _line(x(0), y(0.1), x(0.3), y(0.5), leg);
    _line(x(0.3), y(0.5), x(0.34), y(0.9), leg);
    _line(x(0), y(0.1), x(-0.34), y(0.88), leg);
  }

  /// 横から見た自転車（右向き、乗員なし）。
  void _bicycle() {
    final tube = _stroke(0.09);
    _circle(-0.62, 0.35, 0.38, tube);
    _circle(0.62, 0.35, 0.38, tube);
    final frame = Path();
    void to(double px, double py, {bool move = false}) {
      final o = p(px, py);
      move ? frame.moveTo(o.dx, o.dy) : frame.lineTo(o.dx, o.dy);
    }

    to(-0.62, 0.35, move: true);
    to(-0.04, 0.35); // 後輪ハブ→クランク
    to(0.42, -0.22); // ダウンチューブ
    to(-0.26, -0.22); // トップチューブ
    to(-0.62, 0.35); // シートステー
    to(-0.26, -0.22, move: true);
    to(-0.04, 0.35); // シートチューブ
    to(0.42, -0.22, move: true);
    to(0.62, 0.35); // フロントフォーク
    to(0.42, -0.22, move: true);
    to(0.36, -0.42); // ハンドルポスト
    to(0.56, -0.46); // ハンドル
    to(-0.3, -0.22, move: true);
    to(-0.34, -0.36); // シートポスト
    canvas.drawPath(frame, _stroke(0.09));
    _rrect(-0.5, -0.44, -0.18, -0.34, 0.04, _fillPaint); // サドル
    _circle(-0.04, 0.35, 0.08, _fillPaint); // クランク
  }

  /// 上がってから右（dir=1）／左（dir=-1）へ曲がる太い矢印。
  void _turnArrow(double dir, double width) {
    final path = Path();
    final a = p(-0.3 * dir, 0.95);
    final b = p(-0.3 * dir, 0);
    final ctrl = p(-0.3 * dir, -0.4);
    final d = p(0.2 * dir, -0.4);
    path
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, d.dx, d.dy);
    canvas.drawPath(path, _stroke(width, cap: StrokeCap.butt));
    final hh = 0.3 + width * 0.6;
    canvas.drawPath(
      _poly([
        [0.9 * dir, -0.4],
        [0.18 * dir, -0.4 - hh],
        [0.18 * dir, -0.4 + hh],
      ]),
      _fillPaint,
    );
  }

  /// 直進と右折の2方向を示す太い矢印。
  void _arrowStraightRight() {
    const x0 = -0.4;
    final shaft = _stroke(0.34, cap: StrokeCap.butt);
    // 直進の軸と矢じり
    _line(x0, 0.95, x0, -0.4, shaft);
    canvas.drawPath(
      _poly([
        [x0, -1.0],
        [x0 + 0.5, -0.38],
        [x0 - 0.5, -0.38],
      ]),
      _fillPaint,
    );
    // 右折の枝と矢じり
    final branch = Path();
    final s0 = p(x0, 0.6);
    final ctrl = p(x0, 0.2);
    final e = p(x0 + 0.62, 0.2);
    branch
      ..moveTo(s0.dx, s0.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, e.dx, e.dy);
    canvas.drawPath(branch, shaft);
    canvas.drawPath(
      _poly([
        [x0 + 1.3, 0.2],
        [x0 + 0.6, -0.3],
        [x0 + 0.6, 0.7],
      ]),
      _fillPaint,
    );
  }

  /// 文字の上下に置く、文字へ向かい合う三角（高さ制限）。
  void _heightMarkers() {
    canvas.drawPath(
      _poly([
        [-0.3, -1.02],
        [0.3, -1.02],
        [0, -0.66],
      ]),
      _fillPaint,
    );
    canvas.drawPath(
      _poly([
        [-0.3, 1.02],
        [0.3, 1.02],
        [0, 0.66],
      ]),
      _fillPaint,
    );
  }

  /// ラッパ形の警笛（右側が開いた朝顔）。
  void _horn() {
    // マウスピース
    _rrect(-1, -0.18, -0.86, 0.18, 0.03, _fillPaint);
    // 管
    _rrect(-0.9, -0.09, -0.05, 0.09, 0, _fillPaint);
    // 朝顔（ベル）
    final bell = Path();
    final a = p(-0.1, -0.09);
    final c1 = p(0.45, -0.12);
    final b = p(0.8, -0.62);
    final d = p(0.8, 0.62);
    final c2 = p(0.45, 0.12);
    final e = p(-0.1, 0.09);
    bell
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c1.dx, c1.dy, b.dx, b.dy)
      ..lineTo(d.dx, d.dy)
      ..quadraticBezierTo(c2.dx, c2.dy, e.dx, e.dy)
      ..close();
    canvas.drawPath(bell, _fillPaint);
  }

  /// 白い正三角形の中に、横断歩道の縞の上を歩く黒い人。
  void _crosswalk() {
    canvas.drawPath(
      _poly([
        [0, -1.38],
        [1.42, 1.08],
        [-1.42, 1.08],
      ]),
      _fillPaint,
    );
    final black = Paint()..color = SignColors.black;
    Paint blackStroke(double w, {Color? paintColor, StrokeCap cap = StrokeCap.round}) =>
        _stroke(w, paintColor: SignColors.black, cap: cap);
    _pedestrian(0, 0.05, 0.62, black, blackStroke);
    // 横断歩道の縞（足もとに横一列）
    for (var i = -2; i <= 2; i++) {
      final x = i * 0.36;
      _rrect(x - 0.12, 0.72, x + 0.12, 0.9, 0.01, black);
    }
  }

  /// 左側に上向き、右側に下向きの矢印（左側通行の対面交通）。
  void _twoWayTraffic() {
    final shaft = _stroke(0.2, cap: StrokeCap.butt);
    _line(-0.36, 0.92, -0.36, -0.3, shaft);
    canvas.drawPath(
      _poly([
        [-0.36, -0.92],
        [-0.02, -0.3],
        [-0.7, -0.3],
      ]),
      _fillPaint,
    );
    _line(0.36, -0.92, 0.36, 0.3, shaft);
    canvas.drawPath(
      _poly([
        [0.36, 0.92],
        [0.02, 0.3],
        [0.7, 0.3],
      ]),
      _fillPaint,
    );
  }

  /// スコップで土を掘る作業員（右側）と土の山（左側）。
  void _roadWorks() {
    final paint = _fillPaint;
    // 土の山
    final mound = Path();
    final m0 = p(-1, 0.9);
    final mc = p(-0.62, 0.05);
    final m1 = p(-0.2, 0.9);
    mound
      ..moveTo(m0.dx, m0.dy)
      ..quadraticBezierTo(mc.dx, mc.dy, m1.dx, m1.dy)
      ..close();
    canvas.drawPath(mound, paint);
    // 作業員（左へ前かがみ）
    _circle(0.12, -0.68, 0.16, paint);
    canvas.drawPath(
      _poly([
        [0.0, -0.5],
        [0.26, -0.42],
        [0.42, 0.14],
        [0.16, 0.18],
      ]),
      paint,
    );
    final limb = _stroke(0.13);
    _line(0.3, 0.12, 0.12, 0.9, limb); // 前脚
    _line(0.34, 0.12, 0.62, 0.9, limb); // 後脚
    _line(0.08, -0.4, -0.2, -0.16, _stroke(0.1)); // 腕
    _line(0.16, -0.34, -0.08, 0.02, _stroke(0.1)); // 腕
    // スコップ
    _line(0.08, -0.46, -0.44, 0.34, _stroke(0.07));
    canvas.drawPath(
      _poly([
        [-0.38, 0.26],
        [-0.56, 0.22],
        [-0.66, 0.52],
        [-0.46, 0.56],
      ]),
      paint,
    );
  }

  /// 右へ跳ねるシカ。
  void _deer() {
    final paint = _fillPaint;
    // 胴体
    canvas.drawPath(
      _poly([
        [-0.62, -0.02],
        [-0.3, -0.16],
        [0.3, -0.2],
        [0.56, -0.32],
        [0.6, -0.08],
        [0.32, 0.18],
        [-0.3, 0.2],
        [-0.64, 0.16],
      ]),
      paint,
    );
    // 首と頭
    canvas.drawPath(
      _poly([
        [0.44, -0.26],
        [0.56, -0.62],
        [0.74, -0.66],
        [0.92, -0.52],
        [0.88, -0.44],
        [0.72, -0.46],
        [0.62, -0.12],
      ]),
      paint,
    );
    // 角
    final antler = _stroke(0.06);
    _line(0.62, -0.62, 0.5, -0.95, antler);
    _line(0.54, -0.84, 0.4, -0.92, antler);
    _line(0.68, -0.64, 0.72, -0.96, antler);
    _line(0.71, -0.84, 0.84, -0.92, antler);
    // 尾
    _line(-0.6, -0.02, -0.76, -0.12, _stroke(0.08));
    // 前脚（前へ伸ばす）
    final leg = _stroke(0.09);
    _line(0.38, 0.08, 0.72, 0.28, leg);
    _line(0.72, 0.28, 0.8, 0.5, leg);
    _line(0.28, 0.12, 0.56, 0.4, leg);
    _line(0.56, 0.4, 0.58, 0.6, leg);
    // 後脚（後ろへ蹴る）
    _line(-0.42, 0.12, -0.7, 0.42, leg);
    _line(-0.7, 0.42, -0.96, 0.56, leg);
    _line(-0.5, 0.14, -0.62, 0.52, leg);
    _line(-0.62, 0.52, -0.86, 0.72, leg);
  }

  /// 横から見た二輪車（右向き）と乗員。
  void _motorcycle({required bool withPassenger}) {
    final wheel = _stroke(0.1);
    _circle(-0.62, 0.5, 0.26, wheel);
    _circle(0.62, 0.5, 0.26, wheel);

    // 車体
    canvas.drawPath(
      _poly([
        [-0.62, 0.5],
        [-0.35, 0.12],
        [0.3, 0.12],
        [0.62, 0.5],
        [0.2, 0.42],
        [-0.3, 0.42],
      ]),
      _fillPaint,
    );
    // フロントフォーク・ハンドル
    _line(0.62, 0.5, 0.4, -0.12, _stroke(0.1));
    _line(0.4, -0.12, 0.3, -0.18, _stroke(0.1));

    // 運転者
    _circle(0.08, -0.7, 0.14, _fillPaint);
    canvas.drawPath(
      _poly([
        [0.02, -0.54],
        [0.18, -0.52],
        [0.12, 0.1],
        [-0.18, 0.1],
      ]),
      _fillPaint,
    );
    _line(0.12, -0.4, 0.34, -0.16, _stroke(0.1)); // 腕
    _line(0, 0.08, 0.2, 0.36, _stroke(0.11)); // 脚

    if (withPassenger) {
      _circle(-0.3, -0.58, 0.13, _fillPaint);
      canvas.drawPath(
        _poly([
          [-0.36, -0.43],
          [-0.2, -0.42],
          [-0.2, 0.1],
          [-0.5, 0.1],
        ]),
        _fillPaint,
      );
      _line(-0.24, -0.32, 0.02, -0.3, _stroke(0.09)); // 運転者につかまる腕
      _line(-0.38, 0.08, -0.25, 0.36, _stroke(0.1));
    }
  }

  /// 正面から見た2台の車。
  void _twoCars() {
    _car(-0.46, 0.05, 0.72, color == SignColors.black ? SignColors.red : color);
    _car(0.46, 0.05, 0.72, color);
  }

  void _car(double cx, double cy, double w, Color carColor) {
    final paint = Paint()..color = carColor;
    final hw = w / 2;
    // キャビン
    canvas.drawPath(
      _poly([
        [cx - hw * 0.62, cy - 0.05],
        [cx - hw * 0.45, cy - 0.45],
        [cx + hw * 0.45, cy - 0.45],
        [cx + hw * 0.62, cy - 0.05],
      ]),
      paint,
    );
    // ボディ
    _rrect(cx - hw, cy - 0.08, cx + hw, cy + 0.3, 0.08, paint);
    // タイヤ
    _rrect(cx - hw * 0.9, cy + 0.25, cx - hw * 0.45, cy + 0.45, 0.04, paint);
    _rrect(cx + hw * 0.45, cy + 0.25, cx + hw * 0.9, cy + 0.45, 0.04, paint);
    // 窓（地色で抜く）
    _rrect(cx - hw * 0.45, cy - 0.36, cx + hw * 0.45, cy - 0.12, 0.03,
        Paint()..color = SignColors.white);
    // ライト
    _circle(cx - hw * 0.66, cy + 0.1, 0.06, Paint()..color = SignColors.white);
    _circle(cx + hw * 0.66, cy + 0.1, 0.06, Paint()..color = SignColors.white);
  }

  /// U字の矢印（右側から上がって左側へ下りる）。
  void _uTurn() {
    final path = Path();
    final start = p(0.42, 0.85);
    path.moveTo(start.dx, start.dy);
    final a = p(0.42, -0.2);
    path.lineTo(a.dx, a.dy);
    path.arcTo(
      Rect.fromCircle(center: p(0, -0.2), radius: 0.42 * k),
      0,
      -math.pi,
      false,
    );
    final b = p(-0.42, 0.28);
    path.lineTo(b.dx, b.dy);
    canvas.drawPath(path, _stroke(0.24, cap: StrokeCap.butt));
    // 矢じり（下向き）
    canvas.drawPath(
      _poly([
        [-0.42, 0.8],
        [-0.8, 0.26],
        [-0.04, 0.26],
      ]),
      _fillPaint,
    );
  }

  /// 上向きの太い矢印。
  void _arrowUp() {
    canvas.drawPath(
      _poly([
        [0.0, -0.95],
        [0.62, -0.2],
        [0.22, -0.2],
        [0.22, 0.95],
        [-0.22, 0.95],
        [-0.22, -0.2],
        [-0.62, -0.2],
      ]),
      _fillPaint,
    );
  }

  /// 右向きの太い矢印（軸に「一方通行」の文字が載る）。
  void _oneWayArrow() {
    canvas.drawPath(
      _poly([
        [-1.25, -0.28],
        [0.55, -0.28],
        [0.55, -0.62],
        [1.3, 0.0],
        [0.55, 0.62],
        [0.55, 0.28],
        [-1.25, 0.28],
      ]),
      _fillPaint,
    );
  }

  /// 太い縦線と細い横線の交差。
  void _priorityRoad() {
    _rrect(-0.28, -1.3, 0.28, 1.3, 0, _fillPaint);
    _rrect(-1.3, -0.06, 1.3, 0.06, 0, _fillPaint);
  }

  /// 左向きの機関車。
  void _train() {
    final paint = _fillPaint;
    // ボイラー
    _rrect(-0.85, -0.12, 0.2, 0.32, 0.12, paint);
    // 煙突
    _rrect(-0.66, -0.45, -0.46, -0.08, 0.03, paint);
    _rrect(-0.72, -0.52, -0.4, -0.42, 0.02, paint);
    // 運転室
    _rrect(0.15, -0.5, 0.78, 0.32, 0.02, paint);
    _rrect(0.08, -0.6, 0.86, -0.48, 0.02, paint);
    // 窓
    _rrect(0.3, -0.36, 0.62, -0.1, 0.02, Paint()..color = SignColors.yellow);
    // 車輪
    for (final x in [-0.62, -0.18, 0.5]) {
      _circle(x, 0.5, 0.17, paint);
    }
    // 排障器
    canvas.drawPath(
      _poly([
        [-0.85, 0.32],
        [-1.0, 0.62],
        [-0.8, 0.62],
      ]),
      paint,
    );
  }

  /// 手をつないで歩く子ども2人。
  void _children() {
    _child(-0.35, 0, 1);
    _child(0.4, 0.12, 0.8);
    _line(-0.12, -0.12, 0.2, -0.02, _stroke(0.08));
  }

  void _child(double cx, double cy, double scale) {
    double sx(double v) => cx + v * scale;
    double sy(double v) => cy + v * scale;
    _circle(sx(0), sy(-0.62), 0.17 * scale, _fillPaint);
    // 胴体（スカート形）
    canvas.drawPath(
      _poly([
        [sx(-0.13), sy(-0.42)],
        [sx(0.13), sy(-0.42)],
        [sx(0.28), sy(0.25)],
        [sx(-0.28), sy(0.25)],
      ]),
      _fillPaint,
    );
    // 脚
    _line(sx(-0.1), sy(0.2), sx(-0.2), sy(0.72), _stroke(0.11 * scale));
    _line(sx(0.1), sy(0.2), sx(0.2), sy(0.72), _stroke(0.11 * scale));
    // 腕
    _line(sx(-0.12), sy(-0.34), sx(-0.3), sy(0), _stroke(0.09 * scale));
  }

  /// 縦型の信号機（赤・黄・青）。
  void _trafficLight() {
    _rrect(-0.32, -0.92, 0.32, 0.92, 0.16, _fillPaint);
    _circle(0, -0.56, 0.2, Paint()..color = SignColors.signalRed);
    _circle(0, 0, 0.2, Paint()..color = SignColors.signalYellow);
    _circle(0, 0.56, 0.2, Paint()..color = SignColors.signalGreen);
  }

  /// 両側から狭まる道路の縁線。
  void _roadNarrows() {
    final paint = _stroke(0.16, cap: StrokeCap.butt);
    for (final side in [-1.0, 1.0]) {
      final path = Path();
      final a = p(0.62 * side, 0.95);
      final b = p(0.62 * side, 0.2);
      final c2 = p(0.26 * side, -0.25);
      final d = p(0.26 * side, -0.95);
      path
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c2.dx, c2.dy)
        ..lineTo(d.dx, d.dy);
      canvas.drawPath(path, paint);
    }
  }

  /// 下から上がって右へ曲がる矢印（[mirror] で左へ曲がる）。
  void _rightCurve({bool mirror = false}) {
    final m = mirror ? -1.0 : 1.0;
    final path = Path();
    final a = p(-0.3 * m, 0.95);
    final b = p(-0.3 * m, 0.05);
    final ctrl = p(-0.3 * m, -0.38);
    final d = p(0.2 * m, -0.38);
    path
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, d.dx, d.dy);
    canvas.drawPath(path, _stroke(0.26, cap: StrokeCap.butt));
    canvas.drawPath(
      _poly([
        [0.78 * m, -0.38],
        [0.18 * m, -0.82],
        [0.18 * m, 0.06],
      ]),
      _fillPaint,
    );
  }

  /// 後ろから見た車と、くねったタイヤ跡。
  void _slippery() {
    final paint = _fillPaint;
    // 車（後ろ姿）
    canvas.drawPath(
      _poly([
        [-0.3, -0.62],
        [-0.22, -0.9],
        [0.22, -0.9],
        [0.3, -0.62],
      ]),
      paint,
    );
    _rrect(-0.46, -0.66, 0.46, -0.36, 0.06, paint);
    _rrect(-0.42, -0.4, -0.24, -0.26, 0.02, paint);
    _rrect(0.24, -0.4, 0.42, -0.26, 0.02, paint);

    // S字のタイヤ跡2本
    final track = _stroke(0.1);
    for (final x in [-0.33, 0.33]) {
      final path = Path();
      final s0 = p(x, -0.2);
      final c1 = p(x - 0.45, 0.1);
      final c2 = p(x + 0.45, 0.45);
      final e = p(x - 0.1, 0.92);
      path
        ..moveTo(s0.dx, s0.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, e.dx, e.dy);
      canvas.drawPath(path, track);
    }
  }
}
