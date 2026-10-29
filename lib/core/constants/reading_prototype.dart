/// 「読み物(試作)」機能のフラグ。既定は無効で、既存ユーザーの画面・動作は変わらない。
///
/// 試作の確認時だけ `--dart-define=READING_PROTOTYPE=true` で有効にする。
/// ブランチ proto/reading-explanation の試作用で、main へは入れない。
const bool kReadingPrototypeEnabled = bool.fromEnvironment('READING_PROTOTYPE');
