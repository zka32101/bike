# 問題と標識の対応表（監査用）

`lib/data/question_signs.dart` の `kQuestionSigns`。登録 122 問（mode=question 122 / explanationOnly 0）、標識 33 種。

登録ルール: 問題本文に「X」の標識（または「X」の規制標識）の形で標識名が1つだけあり、X が標識データの名称と対応する。補助標識・時間の言及なし。
除外: 最高速度、追越し禁止（絵が公式未確認）、車両通行区分・追越しのための右側部分はみ出し通行禁止（描き直し中）、警笛区間（補助板の文字が未確認）、指定方向外進行禁止（左折禁止・右折禁止。絵は進行してよい方向を示すため意味が逆に見える）、アプリに無い標識。
備考欄の「表記差」は、本文の名称と標識データの名称が句読点・「一般」の有無だけ違うもの。

| 問題ID | 標識ID | 標識名（データ） | mode | 本文 | 備考 |
|---|---|---|---|---|---|
| at030 | sign_stop | 一時停止 | question | 「一時停止」の標識がある交差点での義務として正しいのはどれか。 |  |
| at118 | sign_no_motorcycles | 二輪の自動車・一般原動機付自転車通行止め | question | AT限定普通二輪免許で250ccのスクーターを運転中、「二輪の自動車・一般原動機付自転車通行止め」の標識がある道路に差しかかった。正しい行動はどれか。 |  |
| at184 | sign_one_way | 一方通行 | question | 一方通行の標識がある道路を、二輪車で標識の示す方向と逆向きに走行することについて正しいのはどれか。 |  |
| at222 | sign_stop | 一時停止 | question | 信号のない交差点に近づいている。交差する道路には「一時停止」の標識があり、そちらから車が近づいてくる。適切な考え方はどれか。 |  |
| at301 | sign_slow | 徐行 | question | 「徐行」の標識が意味するものとして正しいのはどれか。 |  |
| at303 | sign_pedestrian_crossing | 横断歩道 | question | 「横断歩道」の標識の意味として正しいのはどれか。 |  |
| at306 | sign_no_motorcycles | 二輪の自動車・一般原動機付自転車通行止め | question | 「二輪の自動車・原動機付自転車通行止め」の標識の意味として正しいのはどれか。 | 表記差: 二輪の自動車・原動機付自転車通行止め |
| at307 | sign_parking_angled | 斜め駐車 | question | 「斜め駐車」の標識が意味するものとして正しいのはどれか。 |  |
| at309 | sign_slippery | すべりやすい | question | 「すべりやすい」の標識の意味として正しいのはどれか。 |  |
| at310 | sign_safety_zone | 安全地帯 | question | 「安全地帯」の標識が意味するものとして正しいのはどれか。 |  |
| at312 | sign_tram_track_ok | 軌道敷内通行可 | question | 「軌道敷内通行可」の標識の意味として正しいのはどれか。 |  |
| at313 | sign_min_speed_30 | 最低速度（30km/h） | question | 「最低速度」の標識が意味するものとして正しいのはどれか。 |  |
| at316 | sign_roundabout_ahead | ロータリーあり | question | 「ロータリーあり」の標識が意味するものとして正しいのはどれか。 |  |
| at318 | sign_motorway | 自動車専用 | question | 「自動車専用」の標識の意味として正しいのはどれか。 |  |
| at319 | sign_straight_only | 指定方向外進行禁止（直進） | question | 「指定方向外進行禁止（直進のみ）」の標識が意味するものとして正しいのはどれか。 | 表記差: 指定方向外進行禁止（直進のみ） |
| at322 | sign_no_crossing_vehicles | 車両横断禁止 | question | 「車両横断禁止」の標識が意味するものとして正しいのはどれか。 |  |
| at327 | sign_school_zone | 学校、幼稚園、保育所等あり | question | 「学校・幼稚園・保育所等あり」の標識の意味として正しいのはどれか。 | 表記差: 学校・幼稚園・保育所等あり |
| at330 | sign_no_u_turn | 転回禁止 | question | 「転回禁止」の標識の意味として正しいのはどれか。 |  |
| at331 | sign_stop | 一時停止 | question | 「一時停止」の標識が意味するものとして正しいのはどれか。 |  |
| at333 | sign_parking_right | 直角駐車 | question | 「直角駐車」の標識の意味として正しいのはどれか。 |  |
| at334 | sign_no_parking | 駐車禁止 | question | 「駐車禁止」の標識が意味するものとして正しいのはどれか。 |  |
| at336 | sign_no_large_buses | 大型乗用自動車等通行止め | question | 「大型乗用自動車等通行止め」の標識の意味として正しいのはどれか。 |  |
| at339 | sign_parking_parallel | 平行駐車 | question | 「平行駐車」の標識の意味として正しいのはどれか。 |  |
| at343 | sign_right_curve | 右方屈曲あり | question | 「右方屈曲あり」の標識が意味するものとして正しいのはどれか。 |  |
| at345 | sign_bicycle_crossing | 自転車横断帯 | question | 「自転車横断帯」の標識の意味として正しいのはどれか。 |  |
| at346 | sign_one_way | 一方通行 | question | 「一方通行」の標識が意味するものとして正しいのはどれか。 |  |
| f283 | sign_no_parking | 駐車禁止 | question | 「駐車禁止」の規制標識がある道路について正しいのはどれか。 |  |
| f284 | sign_no_stopping | 駐停車禁止 | question | 「駐停車禁止」の規制標識がある道路について正しいのはどれか。 |  |
| f303 | sign_no_entry | 車両進入禁止 | question | 「車両進入禁止」の標識の意味として正しいのはどれか。 |  |
| f304 | sign_pedestrian_crossing | 横断歩道 | question | 「横断歩道」の標識が意味するものとして正しいのはどれか。 |  |
| f306 | sign_no_u_turn | 転回禁止 | question | 「転回禁止」の標識の意味として正しいのはどれか。 |  |
| f307 | sign_no_stopping | 駐停車禁止 | question | 「駐停車禁止」の標識が意味するものとして正しいのはどれか。 |  |
| f309 | sign_one_way | 一方通行 | question | 「一方通行」の標識の意味として正しいのはどれか。 |  |
| f315 | sign_parking_angled | 斜め駐車 | question | 「斜め駐車」の標識の意味として正しいのはどれか。 |  |
| f318 | sign_side_by_side_ok | 並進可 | question | 「並進可」の標識の意味として正しいのはどれか。 |  |
| f322 | sign_min_speed_30 | 最低速度（30km/h） | question | 「最低速度」の標識が意味するものとして正しいのはどれか。 |  |
| f325 | sign_no_crossing_vehicles | 車両横断禁止 | question | 「車両横断禁止」の標識が意味するものとして正しいのはどれか。 |  |
| f328 | sign_no_motorcycles | 二輪の自動車・一般原動機付自転車通行止め | question | 「二輪の自動車・原動機付自転車通行止め」の標識が意味するものとして正しいのはどれか。 | 表記差: 二輪の自動車・原動機付自転車通行止め |
| f330 | sign_priority_road | 優先道路 | question | 「優先道路」の標識の意味として正しいのはどれか。 |  |
| f331 | sign_school_zone | 学校、幼稚園、保育所等あり | question | 「学校・幼稚園・保育所等あり」の標識が意味するものとして正しいのはどれか。 | 表記差: 学校・幼稚園・保育所等あり |
| f334 | sign_stop_line | 停止線 | question | 「停止線」の標識が意味するものとして正しいのはどれか。 |  |
| f336 | sign_no_large_buses | 大型乗用自動車等通行止め | question | 「大型乗用自動車等通行止め」の標識の意味として正しいのはどれか。 |  |
| f337 | sign_right_curve | 右方屈曲あり | question | 「右方屈曲あり」の標識が意味するものとして正しいのはどれか。 |  |
| f343 | sign_bicycle_crossing | 自転車横断帯 | question | 「自転車横断帯」の標識が意味するものとして正しいのはどれか。 |  |
| f345 | sign_bus_lane | 専用通行帯 | question | 「専用通行帯」の標識の意味として正しいのはどれか。 |  |
| f346 | sign_slippery | すべりやすい | question | 「すべりやすい」の標識が意味するものとして正しいのはどれか。 |  |
| f349 | sign_no_pedestrians | 歩行者通行止め | question | 「歩行者通行止め」の標識が意味するものとして正しいのはどれか。 |  |
| g216 | sign_stop | 一時停止 | question | 一時停止の標識がある交差点で発進する際の正しい手順はどれか。 |  |
| g301 | sign_min_speed_30 | 最低速度（30km/h） | question | 「最低速度」の標識が意味するものとして正しいのはどれか。 |  |
| g303 | sign_parking_right | 直角駐車 | question | 「直角駐車」の標識の意味として正しいのはどれか。 |  |
| g304 | sign_straight_only | 指定方向外進行禁止（直進） | question | 「指定方向外進行禁止（直進のみ）」の標識が意味するものとして正しいのはどれか。 | 表記差: 指定方向外進行禁止（直進のみ） |
| g306 | sign_right_curve | 右方屈曲あり | question | 「右方屈曲あり」の標識の意味として正しいのはどれか。 |  |
| g307 | sign_motorway | 自動車専用 | question | 「自動車専用」の標識が意味するものとして正しいのはどれか。 |  |
| g309 | sign_one_way | 一方通行 | question | 「一方通行」の標識の意味として正しいのはどれか。 |  |
| g310 | sign_bus_lane | 専用通行帯 | question | 「専用通行帯」の標識が意味するものとして正しいのはどれか。 |  |
| g312 | sign_parking_allowed | 駐車可 | question | 「駐車可」の標識の意味として正しいのはどれか。 |  |
| g315 | sign_pedestrian_crossing | 横断歩道 | question | 「横断歩道」の標識の意味として正しいのはどれか。 |  |
| g316 | sign_stop_line | 停止線 | question | 「停止線」の標識が意味するものとして正しいのはどれか。 |  |
| g319 | sign_tram_track_ok | 軌道敷内通行可 | question | 「軌道敷内通行可」の標識が意味するものとして正しいのはどれか。 |  |
| g322 | sign_parking_parallel | 平行駐車 | question | 「平行駐車」の標識が意味するものとして正しいのはどれか。 |  |
| g324 | sign_slippery | すべりやすい | question | 「すべりやすい」の標識の意味として正しいのはどれか。 |  |
| g325 | sign_safety_zone | 安全地帯 | question | 「安全地帯」の標識が意味するものとして正しいのはどれか。 |  |
| g327 | sign_no_pedestrians | 歩行者通行止め | question | 「歩行者通行止め」の標識の意味として正しいのはどれか。 |  |
| g328 | sign_parking_angled | 斜め駐車 | question | 「斜め駐車」の標識が意味するものとして正しいのはどれか。 |  |
| g331 | sign_railroad_crossing | 踏切あり | question | 「踏切あり」の標識が意味するものとして正しいのはどれか。 |  |
| g333 | sign_slow | 徐行 | question | 「徐行」の標識の意味として正しいのはどれか。 |  |
| g334 | sign_roundabout_ahead | ロータリーあり | question | 「ロータリーあり」の標識が意味するものとして正しいのはどれか。 |  |
| g337 | sign_school_zone | 学校、幼稚園、保育所等あり | question | 「学校・幼稚園・保育所等あり」の標識が意味するものとして正しいのはどれか。 | 表記差: 学校・幼稚園・保育所等あり |
| g339 | sign_pedestrian_only | 歩行者専用 | question | 「歩行者専用」の標識の意味として正しいのはどれか。 |  |
| g342 | sign_side_by_side_ok | 並進可 | question | 「並進可」の標識の意味として正しいのはどれか。 |  |
| g348 | sign_no_entry | 車両進入禁止 | question | 「車両進入禁止」の標識の意味として正しいのはどれか。 |  |
| g349 | sign_no_crossing_vehicles | 車両横断禁止 | question | 「車両横断禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg018 | sign_no_parking | 駐車禁止 | question | 駐車禁止の道路標識がある区間での自動二輪車の扱いについて正しいのはどれか。 |  |
| kg020 | sign_stop | 一時停止 | question | 「一時停止」の標識がある場所での正しい行動はどれか。 |  |
| kg119 | sign_motorway | 自動車専用 | question | 「自動車専用」の標識がある道路の通行について、総排気量125ccの二輪車の場合として正しいのはどれか。 |  |
| kg120 | sign_no_tandem | 大型自動二輪車及び普通自動二輪車二人乗り通行禁止 | question | 「大型自動二輪車及び普通自動二輪車二人乗り通行禁止」の標識がある道路で、250ccの二輪車に同乗者を乗せて走行することについて正しいのはどれか。 |  |
| kg301 | sign_no_u_turn | 転回禁止 | question | 「転回禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg303 | sign_safety_zone | 安全地帯 | question | 「安全地帯」の標識の意味として正しいのはどれか。 |  |
| kg306 | sign_straight_only | 指定方向外進行禁止（直進） | question | 「指定方向外進行禁止（直進のみ）」の標識の意味として正しいのはどれか。 | 表記差: 指定方向外進行禁止（直進のみ） |
| kg307 | sign_stop_line | 停止線 | question | 「停止線」の標識が意味するものとして正しいのはどれか。 |  |
| kg309 | sign_bus_lane | 専用通行帯 | question | 「専用通行帯」の標識の意味として正しいのはどれか。 |  |
| kg310 | sign_no_stopping | 駐停車禁止 | question | 「駐停車禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg313 | sign_no_parking | 駐車禁止 | question | 「駐車禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg318 | sign_motorway | 自動車専用 | question | 「自動車専用」の標識の意味として正しいのはどれか。 |  |
| kg319 | sign_no_entry | 車両進入禁止 | question | 「車両進入禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg322 | sign_school_zone | 学校、幼稚園、保育所等あり | question | 「学校・幼稚園・保育所等あり」の標識が意味するものとして正しいのはどれか。 | 表記差: 学校・幼稚園・保育所等あり |
| kg324 | sign_slippery | すべりやすい | question | 「すべりやすい」の標識の意味として正しいのはどれか。 |  |
| kg325 | sign_no_crossing_vehicles | 車両横断禁止 | question | 「車両横断禁止」の標識が意味するものとして正しいのはどれか。 |  |
| kg327 | sign_no_pedestrians | 歩行者通行止め | question | 「歩行者通行止め」の標識の意味として正しいのはどれか。 |  |
| kg328 | sign_parking_right | 直角駐車 | question | 「直角駐車」の標識が意味するものとして正しいのはどれか。 |  |
| kg331 | sign_pedestrian_only | 歩行者専用 | question | 「歩行者専用」の標識が意味するものとして正しいのはどれか。 |  |
| kg333 | sign_priority_road | 優先道路 | question | 「優先道路」の標識の意味として正しいのはどれか。 |  |
| kg334 | sign_pedestrian_crossing | 横断歩道 | question | 「横断歩道」の標識が意味するものとして正しいのはどれか。 |  |
| kg336 | sign_stop | 一時停止 | question | 「一時停止」の標識の意味として正しいのはどれか。 |  |
| kg337 | sign_slow | 徐行 | question | 「徐行」の標識が意味するものとして正しいのはどれか。 |  |
| kg339 | sign_roundabout_ahead | ロータリーあり | question | 「ロータリーあり」の標識の意味として正しいのはどれか。 |  |
| kg340 | sign_bicycle_crossing | 自転車横断帯 | question | 「自転車横断帯」の標識が意味するものとして正しいのはどれか。 |  |
| kg342 | sign_parking_angled | 斜め駐車 | question | 「斜め駐車」の標識の意味として正しいのはどれか。 |  |
| kg343 | sign_right_curve | 右方屈曲あり | question | 「右方屈曲あり」の標識が意味するものとして正しいのはどれか。 |  |
| kg348 | sign_parking_parallel | 平行駐車 | question | 「平行駐車」の標識の意味として正しいのはどれか。 |  |
| o304 | sign_min_speed_30 | 最低速度（30km/h） | question | 「最低速度」の標識が意味するものとして正しいのはどれか。 |  |
| o306 | sign_pedestrian_crossing | 横断歩道 | question | 「横断歩道」の標識の意味として正しいのはどれか。 |  |
| o307 | sign_side_by_side_ok | 並進可 | question | 「並進可」の標識が意味するものとして正しいのはどれか。 |  |
| o309 | sign_no_large_buses | 大型乗用自動車等通行止め | question | 「大型乗用自動車等通行止め」の標識の意味として正しいのはどれか。 |  |
| o310 | sign_straight_only | 指定方向外進行禁止（直進） | question | 「指定方向外進行禁止（直進のみ）」の標識が意味するものとして正しいのはどれか。 | 表記差: 指定方向外進行禁止（直進のみ） |
| o313 | sign_parking_allowed | 駐車可 | question | 「駐車可」の標識が意味するものとして正しいのはどれか。 |  |
| o315 | sign_roundabout_ahead | ロータリーあり | question | 「ロータリーあり」の標識の意味として正しいのはどれか。 |  |
| o316 | sign_slow | 徐行 | question | 「徐行」の標識が意味するものとして正しいのはどれか。 |  |
| o319 | sign_right_curve | 右方屈曲あり | question | 「右方屈曲あり」の標識が意味するものとして正しいのはどれか。 |  |
| o321 | sign_no_u_turn | 転回禁止 | question | 「転回禁止」の標識の意味として正しいのはどれか。 |  |
| o322 | sign_safety_zone | 安全地帯 | question | 「安全地帯」の標識が意味するものとして正しいのはどれか。 |  |
| o325 | sign_school_zone | 学校、幼稚園、保育所等あり | question | 「学校・幼稚園・保育所等あり」の標識が意味するものとして正しいのはどれか。 | 表記差: 学校・幼稚園・保育所等あり |
| o327 | sign_no_stopping | 駐停車禁止 | question | 「駐停車禁止」の標識の意味として正しいのはどれか。 |  |
| o328 | sign_one_way | 一方通行 | question | 「一方通行」の標識が意味するものとして正しいのはどれか。 |  |
| o331 | sign_parking_parallel | 平行駐車 | question | 「平行駐車」の標識が意味するものとして正しいのはどれか。 |  |
| o333 | sign_pedestrian_only | 歩行者専用 | question | 「歩行者専用」の標識の意味として正しいのはどれか。 |  |
| o334 | sign_railroad_crossing | 踏切あり | question | 「踏切あり」の標識が意味するものとして正しいのはどれか。 |  |
| o336 | sign_no_pedestrians | 歩行者通行止め | question | 「歩行者通行止め」の標識の意味として正しいのはどれか。 |  |
| o340 | sign_bicycle_crossing | 自転車横断帯 | question | 「自転車横断帯」の標識が意味するものとして正しいのはどれか。 |  |
| o342 | sign_motorway | 自動車専用 | question | 「自動車専用」の標識の意味として正しいのはどれか。 |  |
| o343 | sign_tram_track_ok | 軌道敷内通行可 | question | 「軌道敷内通行可」の標識が意味するものとして正しいのはどれか。 |  |
| o348 | sign_priority_road | 優先道路 | question | 「優先道路」の標識の意味として正しいのはどれか。 |  |
