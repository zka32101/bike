import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mascot.dart';

/// 推しの設定（端末内）。選択キャラは全アプリ共通キー、Lvはこのアプリの習熟度。
class MascotSettings {
  const MascotSettings({
    this.selected,
    this.visible = true,
    this.costume = true,
    this.maxLevel = 1,
  });

  final Mascot? selected;
  final bool visible;

  /// バイク免許のヘルメット衣装を着せる。
  final bool costume;

  /// これまでに到達した最大Lv（下がらない）。
  final int maxLevel;

  MascotSettings copyWith({
    Mascot? selected,
    bool clearSelected = false,
    bool? visible,
    bool? costume,
    int? maxLevel,
  }) =>
      MascotSettings(
        selected: clearSelected ? null : (selected ?? this.selected),
        visible: visible ?? this.visible,
        costume: costume ?? this.costume,
        maxLevel: maxLevel ?? this.maxLevel,
      );
}

class MascotSettingsNotifier extends StateNotifier<MascotSettings> {
  MascotSettingsNotifier() : super(const MascotSettings()) {
    _load();
  }

  // 選択キャラはうかラボ共通キー（他のうかラボアプリと名前をそろえる）。
  static const _kSelected = 'ukalab.mascot.selected';
  static const _kVisible = 'ukalab.mascot.visible';
  static const _kCostume = 'bike.mascot.costume';
  static const _kMaxLevel = 'bike.mascot.maxLevel';

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = MascotSettings(
        selected: Mascot.fromId(p.getString(_kSelected)),
        visible: p.getBool(_kVisible) ?? true,
        costume: p.getBool(_kCostume) ?? true,
        maxLevel: (p.getInt(_kMaxLevel) ?? 1).clamp(1, 5),
      );
    } catch (_) {
      // 読めなければ既定値のまま（推しなし）。
    }
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = state.selected;
      if (s == null) {
        await p.remove(_kSelected);
      } else {
        await p.setString(_kSelected, s.id);
      }
      await p.setBool(_kVisible, state.visible);
      await p.setBool(_kCostume, state.costume);
      await p.setInt(_kMaxLevel, state.maxLevel);
    } catch (_) {}
  }

  Future<void> select(Mascot? m) async {
    state = m == null
        ? state.copyWith(clearSelected: true)
        : state.copyWith(selected: m, visible: true);
    await _save();
  }

  Future<void> setVisible(bool v) async {
    state = state.copyWith(visible: v);
    await _save();
  }

  Future<void> setCostume(bool v) async {
    state = state.copyWith(costume: v);
    await _save();
  }

  /// 習熟度から求めたLvを反映する（下がらない）。反映後のLvを返す。
  Future<int> reachLevel(int level) async {
    if (level <= state.maxLevel) return state.maxLevel;
    state = state.copyWith(maxLevel: level.clamp(1, 5));
    await _save();
    return state.maxLevel;
  }
}

final mascotSettingsProvider =
    StateNotifierProvider<MascotSettingsNotifier, MascotSettings>(
  (ref) => MascotSettingsNotifier(),
);
