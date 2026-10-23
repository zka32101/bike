import 'package:flutter/material.dart';

/// 資格色の単一定義箇所（決定CD-003）。
///
/// 色コードは直書きせず、共通テーマ（UkalabTheme・技術安全の分野色）の主色を返す。
/// 「解いた割合」の濃淡など、資格を表す色はすべてここ経由で取得する。
/// TODO: core 編入後に UkalabCert（bikeLicense）の色へ差し替える。
Color bikeCertColor(ThemeData theme) => theme.colorScheme.primary;
