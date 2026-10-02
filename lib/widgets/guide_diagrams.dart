import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/guide_article.dart';

/// 「役立つ情報」の図。道路を真上から見た形を CustomPainter で描く。
/// 色は標識令 別表第六の色彩（黄・白）に合わせる。
class GuideDiagramView extends StatelessWidget {
  const GuideDiagramView({super.key, required this.figure});

  final GuideFigure figure;

  @override
  Widget build(BuildContext context) {
    final wide = figure.diagram == GuideDiagram.twoStageRightTurn;
    return Semantics(
      label: figure.caption,
      image: true,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: wide ? 1.4 : 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: GuideDiagramPainter(figure.diagram),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            figure.caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class GuideDiagramPainter extends CustomPainter {
  GuideDiagramPainter(this.kind);

  final GuideDiagram kind;

  static const _asphalt = Color(0xFF4A4F55);
  static const _curb = Color(0xFFB8BDC2);
  static const _white = Color(0xFFFFFFFF);
  static const _yellow = Color(0xFFF5C400);
  static const _red = Color(0xFFD7282F);

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case GuideDiagram.centerWhite:
        _road(canvas, size);
        _vline(canvas, size, 0.5, _white, dashed: true);
      case GuideDiagram.centerYellow:
        _road(canvas, size);
        _vline(canvas, size, 0.5, _yellow);
      case GuideDiagram.kerbYellowSolid:
        _kerbRoad(canvas, size);
        _vline(canvas, size, 0.78, _yellow);
      case GuideDiagram.kerbYellowBroken:
        _kerbRoad(canvas, size);
        _vline(canvas, size, 0.78, _yellow, dashed: true);
      case GuideDiagram.stripSingle:
        _stripRoad(canvas, size);
        _vline(canvas, size, 0.74, _white);
      case GuideDiagram.stripSolidBroken:
        _stripRoad(canvas, size);
        _vline(canvas, size, 0.70, _white);
        _vline(canvas, size, 0.78, _white, dashed: true);
      case GuideDiagram.stripDouble:
        _stripRoad(canvas, size);
        _vline(canvas, size, 0.70, _white);
        _vline(canvas, size, 0.78, _white);
      case GuideDiagram.twoStageRightTurn:
        _twoStage(canvas, size);
    }
  }

  void _road(Canvas c, Size s) =>
      c.drawRect(Offset.zero & s, Paint()..color = _asphalt);

  /// 右端に縁石と歩道（薄い灰色）がある道路。
  void _kerbRoad(Canvas c, Size s) {
    _road(c, s);
    c.drawRect(
      Rect.fromLTWH(s.width * 0.86, 0, s.width * 0.14, s.height),
      Paint()..color = _curb,
    );
  }

  /// 右端が路側帯（歩道のない道路）。路側帯の外側は路肩（薄い灰色）。
  void _stripRoad(Canvas c, Size s) {
    _road(c, s);
    c.drawRect(
      Rect.fromLTWH(s.width * 0.88, 0, s.width * 0.12, s.height),
      Paint()..color = _curb,
    );
  }

  void _vline(Canvas c, Size s, double fx, Color color, {bool dashed = false}) {
    final x = s.width * fx;
    final w = s.width * 0.035;
    final paint = Paint()..color = color;
    if (!dashed) {
      c.drawRect(Rect.fromLTWH(x - w / 2, 0, w, s.height), paint);
      return;
    }
    final seg = s.height * 0.12;
    final gap = s.height * 0.08;
    for (var y = gap / 2; y < s.height; y += seg + gap) {
      c.drawRect(Rect.fromLTWH(x - w / 2, y, w, math.min(seg, s.height - y)), paint);
    }
  }

  // ---- 二段階右折 ---------------------------------------------------------

  void _twoStage(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    _road(c, s);
    // 交差点（縦の道路と横の道路が交わる）をアスファルト以外の背景で区切る
    final bg = Paint()..color = const Color(0xFF8FAF7A);
    final roadX0 = w * 0.30, roadX1 = w * 0.70;
    final roadY0 = h * 0.28, roadY1 = h * 0.72;
    c.drawRect(Offset.zero & s, bg);
    final asphalt = Paint()..color = _asphalt;
    c.drawRect(Rect.fromLTRB(roadX0, 0, roadX1, h), asphalt);
    c.drawRect(Rect.fromLTRB(0, roadY0, w, roadY1), asphalt);
    // 中央線
    final dash = Paint()..color = _white;
    for (var y = 0.0; y < roadY0 - 4; y += 18) {
      c.drawRect(Rect.fromLTWH(w * 0.5 - 1.5, y, 3, 10), dash);
    }
    for (var y = roadY1 + 4; y < h; y += 18) {
      c.drawRect(Rect.fromLTWH(w * 0.5 - 1.5, y, 3, 10), dash);
    }
    for (var x = 0.0; x < roadX0 - 4; x += 18) {
      c.drawRect(Rect.fromLTWH(x, h * 0.5 - 1.5, 10, 3), dash);
    }
    for (var x = roadX1 + 4; x < w; x += 18) {
      c.drawRect(Rect.fromLTWH(x, h * 0.5 - 1.5, 10, 3), dash);
    }
    // 進路（左側通行。南から北へ進む左側の車線 → 向こう側で右へ向き直り東へ）
    final lx = w * 0.40;
    final ty = h * 0.37;
    final p = Paint()
      ..color = _yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(lx, h * 0.97), Offset(lx, ty + 6), p);
    // 向こう側で止まって右に向きを変える（点線の弧）
    final turn = Path()
      ..moveTo(lx, ty + 6)
      ..quadraticBezierTo(lx, ty, lx + 14, ty);
    c.drawPath(turn, Paint()
      ..color = _red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round);
    c.drawLine(Offset(lx + 14, ty), Offset(w * 0.96, ty), p);
    _arrowHead(c, Offset(lx, h * 0.86), -math.pi / 2, _yellow);
    _arrowHead(c, Offset(w * 0.96, ty), 0, _yellow);
    // 停止点
    c.drawCircle(Offset(lx, ty + 4), 6, Paint()..color = _red);
    // 番号
    _badge(c, Offset(lx - 20, h * 0.80), '1');
    _badge(c, Offset(lx - 20, ty + 22), '2');
    _badge(c, Offset(w * 0.78, ty - 22), '3');
  }

  void _arrowHead(Canvas c, Offset tip, double angle, Color color) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(-12, -7)
      ..lineTo(-12, 7)
      ..close();
    c.save();
    c.translate(tip.dx, tip.dy);
    c.rotate(angle);
    c.drawPath(path, Paint()..color = color);
    c.restore();
  }

  void _badge(Canvas c, Offset center, String text) {
    c.drawCircle(center, 11, Paint()..color = _white);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _asphalt,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant GuideDiagramPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
