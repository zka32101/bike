import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ui.dart';

/// このアプリの資格。資格色（解いた割合の濃淡など）はすべてここから決まる（決定CD-003）。
///
/// 色コードはコアの `UkalabCert` が持つので、アプリ側には書かない。
/// 色の導出（`solveCoverageFill` など）もコア側（ukalab_core v0.84.0〜）。
const UkalabCert kAppCert = UkalabCert.bikeLicense;

/// 現在の資格。テストや別資格では override して差し替える。
final appCertProvider = Provider<UkalabCert>((ref) => kAppCert);
