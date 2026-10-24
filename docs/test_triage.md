# テスト失敗トリアージ（ci/test_failure_baseline.txt = 124）

作成: 2026-10-24 / 方法: **静的解析のみ**（この環境に flutter/dart が無く、`flutter test` は未実行）。
失敗件数の実測はできていないため、**ベースラインは変更していない**。

## 分類基準

- **(A)** テスト側の import/参照ミスのみで、修正すれば確実に直る
- **(B)** 参照先の lib コードがこのリポジトリに存在せず、削除候補（**削除・変更は運営の事前承認が必要。本PRでは一切触らない**）
- **(C)** lib 側に同名ファイルはあるが API がテストと不一致。実装バグかテスト陳腐化か要調査（触らない）

## 件数（テストファイル単位）

| 区分 | ファイル数 | 確度 |
|---|---|---|
| (A) 確実に直せる | 0 | - |
| (B) 削除候補 | 90 | 高（import 先ファイルの不在を `git ls-files` で確認。コンパイル不能のため必ず失敗） |
| (C) 要調査 | 9 | 中〜低（シンボル名の突き合わせによる静的判断のみ） |
| 対象外（import は全て解決。未実行のため通過/失敗は未確認） | 31 | - |

(A) が 0 件の理由: パッケージ名が誤り（`project_040`/`your_app_name`、正しくは `bike_license_kore`）のテストは、
直した先の lib 側にもシンボルが無い（B/C）ため、import 修正だけでは直らない。確実に直ると言えるものが無かった。

1ファイルが複数テストケースを持つため、ファイル数と失敗数(124)は一致しない。

## (A) テスト側ミスで直せる

なし。

## (B) 参照先コードが存在しない（削除候補・要承認）

| ファイル | 失敗理由 | 推奨対応 |
|---|---|---|
| `test/ab_testing_service_test.dart` | 参照先が存在しない: `models/ab_test_model.dart`, `services/ab_testing_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/adaptive_learning_test.dart` | 参照先が存在しない: `models/ai_recommendation_model.dart`, `services/adaptive_learning_service.dart`。別プロジェクト由来のパッケージ名 `your_app_name` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/admin_dashboard_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/advanced_messaging_service_test.dart` | 参照先が存在しない: `models/advanced_messaging_model.dart`, `services/advanced_messaging_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/analytics_dashboard_integration_test.dart` | 参照先が存在しない: `models/analytics_event.dart`, `services/analytics_tracking_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/analytics_dashboard_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/analytics_tracking_service_test.dart` | 参照先が存在しない: `models/analytics_event.dart`, `services/analytics_tracking_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/community_service_test.dart` | 参照先が存在しない: `services/community_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/content_management_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/gamification_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/group_matching_test.dart` | 参照先が存在しない: `services/group_matching_service.dart`。別プロジェクト由来のパッケージ名 `your_app_name` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/leaderboard_service_test.dart` | 参照先が存在しない: `models/leaderboard_model.dart`, `services/leaderboard_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/media_messaging_service_test.dart` | 参照先が存在しない: `models/media_messaging_model.dart`, `services/media_messaging_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/messaging_service_test.dart` | 参照先が存在しない: `models/messaging_model.dart`, `services/messaging_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/ml_prediction_test.dart` | 参照先が存在しない: `services/ml_predictor_service.dart`。別プロジェクト由来のパッケージ名 `your_app_name` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/notifications_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/partnership_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/performance_cache_service_test.dart` | 参照先が存在しない: `services/performance_cache_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_21_job_monitoring_test.dart` | 参照先が存在しない: `models/async_job_model.dart`, `models/job_monitoring_model.dart`, `services/cloud_functions_service.dart`, `providers/job_monitoring_provider.dart`。別プロジェクト由来のパッケージ名 `riverpod` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_22_job_monitoring_ui_test.dart` | 参照先が存在しない: `models/async_job_model.dart`, `models/job_monitoring_model.dart`, `widgets/job_progress_card.dart`, `widgets/job_monitoring_dashboard.dart`, `widgets/job_details_panel.dart`, `services/cloud_functions_service.dart`, `providers/job_monitoring_provider.dart`。別プロジェクト由来のパッケージ名 `riverpod` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_23_notifications_and_filtering_test.dart` | 参照先が存在しない: `models/async_job_model.dart`, `models/job_history_model.dart`, `services/fcm_notification_service.dart`, `providers/notification_provider.dart`。別プロジェクト由来のパッケージ名 `project_040/riverpod` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_24_optimization_accessibility_test.dart` | 参照先が存在しない: `models/async_job_model.dart`, `widgets/virtualized_job_list.dart`, `widgets/accessible_job_dashboard.dart`, `services/job_cache_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_25_analytics_search_export_test.dart` | 参照先が存在しない: `models/async_job_model.dart`, `models/analytics_model.dart`, `models/search_export_model.dart`, `services/search_export_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_26_ui_state_management_test.dart` | 参照先が存在しない: `models/analytics_model.dart`, `models/search_export_model.dart`, `models/async_job_model.dart`, `providers/analytics_provider.dart`, `providers/search_provider.dart`, `providers/export_provider.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_27_backend_integration_test.dart` | 参照先が存在しない: `models/api_models.dart`, `models/async_job_model.dart`, `models/analytics_model.dart`, `models/search_export_model.dart`, `services/api_service.dart`, `services/database_service.dart`, `services/scheduling_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_28_http_auth_test.dart` | 参照先が存在しない: `services/jwt_service.dart`, `services/http_api_client.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_29_33_integration_test.dart` | 参照先が存在しない: `services/security_service.dart`, `services/cache_service.dart`, `services/websocket_service.dart`, `services/advanced_auth_service.dart`, `services/monitoring_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_34_localization_test.dart` | 参照先が存在しない: `models/localization_models.dart`, `services/localization_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_35_api_documentation_test.dart` | 参照先が存在しない: `models/api_documentation_models.dart`, `services/api_documentation_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_36_testing_framework_test.dart` | 参照先が存在しない: `models/testing_models.dart`, `services/testing_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_37_deployment_test.dart` | 参照先が存在しない: `models/deployment_models.dart`, `services/deployment_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_38_feature_flag_test.dart` | 参照先が存在しない: `models/feature_flag_models.dart`, `services/feature_flag_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_39_rate_limit_test.dart` | 参照先が存在しない: `models/rate_limit_models.dart`, `services/rate_limit_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_40_webhook_test.dart` | 参照先が存在しない: `models/webhook_models.dart`, `services/webhook_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_41_cache_test.dart` | 参照先が存在しない: `models/cache_models.dart`, `services/cache_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_42_observability_test.dart` | 参照先が存在しない: `models/observability_models.dart`, `services/observability_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_43_database_test.dart` | 参照先が存在しない: `models/database_models.dart`, `services/database_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_44_error_tracking_test.dart` | 参照先が存在しない: `models/error_tracking_models.dart`, `services/error_tracking_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_45_feedback_test.dart` | 参照先が存在しない: `models/feedback_models.dart`, `services/feedback_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_48_audit_test.dart` | 参照先が存在しない: `models/audit_models.dart`, `services/audit_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_50_user_test.dart` | 参照先が存在しない: `models/user_models.dart`, `services/user_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_51_integration_test.dart` | 参照先が存在しない: `models/integration_models.dart`, `services/integration_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_52_database_test.dart` | 参照先が存在しない: `models/database_models.dart`, `services/database_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_53_performance_test.dart` | 参照先が存在しない: `models/performance_models.dart`, `services/performance_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_54_security_test.dart` | 参照先が存在しない: `models/security_models.dart`, `services/security_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_55_api_test.dart` | 参照先が存在しない: `models/api_models.dart`, `services/api_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_57_user_test.dart` | 参照先が存在しない: `models/user_models.dart`, `services/user_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_58_database_test.dart` | 参照先が存在しない: `models/database_models.dart`, `services/database_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_60_api_test.dart` | 参照先が存在しない: `models/api_models.dart`, `services/api_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_63_dashboard_test.dart` | 参照先が存在しない: `models/dashboard_models.dart`, `services/dashboard_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_64_audit_test.dart` | 参照先が存在しない: `models/audit_models.dart`, `services/audit_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_65_version_test.dart` | 参照先が存在しない: `models/version_models.dart`, `services/version_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_66_resource_test.dart` | 参照先が存在しない: `models/resource_models.dart`, `services/resource_service.dart`。別プロジェクト由来のパッケージ名 `test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_67_workflow_test.dart` | 参照先が存在しない: `models/workflow_models.dart`, `services/workflow_service.dart`。別プロジェクト由来のパッケージ名 `test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_68_discovery_test.dart` | 参照先が存在しない: `models/discovery_models.dart`, `services/discovery_service.dart`。別プロジェクト由来のパッケージ名 `test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_70_analytics_test.dart` | 参照先が存在しない: `services/analytics_models_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_71_cost_billing_test.dart` | 参照先が存在しない: `models/cost_models.dart`, `services/cost_billing_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_72_security_test.dart` | 参照先が存在しない: `models/security_models.dart`, `services/security_access_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_73_configuration_test.dart` | 参照先が存在しない: `models/configuration_models.dart`, `services/configuration_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_74_incident_management_test.dart` | 参照先が存在しない: `models/incident_models.dart`, `services/incident_management_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_75_deployment_test.dart` | 参照先が存在しない: `models/deployment_models.dart`, `services/deployment_release_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_76_observability_test.dart` | 参照先が存在しない: `models/observability_models.dart`, `services/observability_tracing_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_77_notification_test.dart` | 参照先が存在しない: `services/notification_messaging_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_78_security_test.dart` | 参照先が存在しない: `models/security_models.dart`, `services/security_access_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_79_integration_test.dart` | 参照先が存在しない: `models/integration_models.dart`, `services/integration_gateway_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_80_data_quality_test.dart` | 参照先が存在しない: `models/data_quality_models.dart`, `services/data_quality_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_81_sla_test.dart` | 参照先が存在しない: `models/sla_models.dart`, `services/sla_management_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_82_cost_optimization_test.dart` | 参照先が存在しない: `models/cost_optimization_models.dart`, `services/cost_optimization_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_83_finops_dashboard_test.dart` | 参照先が存在しない: `models/finops_dashboard_models.dart`, `services/finops_dashboard_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_84_multitenant_test.dart` | 参照先が存在しない: `models/multitenant_models.dart`, `services/multitenant_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_85_workflow_test.dart` | 参照先が存在しない: `models/workflow_orchestration_models.dart`, `services/workflow_orchestration_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_86_reporting_test.dart` | 参照先が存在しない: `models/advanced_reporting_models.dart`, `services/advanced_reporting_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_87_caching_test.dart` | 参照先が存在しない: `models/caching_models.dart`, `services/caching_service.dart`。別プロジェクト由来のパッケージ名 `project_040/test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_88_ml_test.dart` | 参照先が存在しない: `models/ml_models.dart`, `services/ml_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_89_security_test.dart` | 参照先が存在しない: `models/security_models.dart`, `services/security_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_91_compliance_test.dart` | 参照先が存在しない: `models/compliance_models.dart`, `services/compliance_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_92_incident_test.dart` | 参照先が存在しない: `models/incident_models.dart`, `services/incident_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_93_product_test.dart` | 参照先が存在しない: `models/product_models.dart`, `services/product_service.dart`。別プロジェクト由来のパッケージ名 `test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_94_experience_test.dart` | 参照先が存在しない: `models/experience_models.dart`, `services/experience_service.dart`。別プロジェクト由来のパッケージ名 `test` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_95_success_test.dart` | 参照先が存在しない: `models/success_models.dart`, `services/success_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_96_financial_test.dart` | 参照先が存在しない: `models/financial_models.dart`, `services/financial_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_97_hr_test.dart` | 参照先が存在しない: `models/hr_models.dart`, `services/hr_service.dart`。別プロジェクト由来のパッケージ名 `project_040` を import | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_98_supply_chain_test.dart` | 参照先が存在しない: `models/supply_chain_models.dart`, `services/supply_chain_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/phase_99_qa_testing_test.dart` | 参照先が存在しない: `models/qa_testing_models.dart`, `services/qa_testing_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/progress_tracker_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/readiness_prediction_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/remote_config_service_test.dart` | 参照先が存在しない: `models/remote_config_model.dart`, `services/remote_config_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/resources_test.dart` | 参照先が存在しない: `services/community_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/social_service_test.dart` | 参照先が存在しない: `models/social_model.dart`, `services/social_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |
| `test/user_profile_service_test.dart` | 参照先が存在しない: `models/user_profile_model.dart`, `services/user_profile_service.dart` | 削除候補。運営承認後に削除、または対応する lib の再実装 |

## (C) 実装バグ/テスト陳腐化の可能性（要調査）

| ファイル | 失敗理由（推定） | 推奨対応 |
|---|---|---|
| `test/export_service_test.dart` | `ExportService` は `export_service_impl.dart` にあり、`ExportConfig` は `export_models.dart` にある。テストは `report_model.dart`/`export_service.dart` を想定しており API が不一致（import パッケージ名 `your_app_name` も誤り） | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_46_notification_test.dart` | `NotificationManagerFacade` 等が lib に無く、`NotificationFacade` 等と API が不一致 | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_47_analytics_test.dart` | `AnalyticsMetricType`/`MemoryAnalyticsManager`/`AnalyticsManagerFacade` が lib に無い | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_49_export_test.dart` | `ReportType`/`MemoryReportEngine`/`ExportManagerFacade`、`ExportFormat.value` 等が lib に無い | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_56_export_test.dart` | `ExportConfiguration`/`ReportType`/`FilterType` が lib に無い（同名ファイルは存在するが別 API。パッケージ名 `project_040` も誤り） | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_59_notification_test.dart` | `NotificationType.info/success/warning/error`、`AlertType.performanceDegradation` が lib の enum に無い | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_61_analytics_test.dart` | `ReportType`/`AggregationType` が lib に無い | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_62_export_test.dart` | `ExportFormatConfig` 等のコンストラクタ/`ExportJob` のフィールドが lib 実装と不一致の可能性（`ExportJob` は lib に存在するため要照合） | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |
| `test/phase_90_analytics_test.dart` | `PredictionType.realtime` 等が lib の enum（regression/classification…）と不一致。`AnalyticsFacade`/`Manager` は存在（パッケージ名 `project_040` も誤り） | lib/テストどちらが正か調査。パッケージ名の誤りも併せて修正が必要 |

## 対象外（import 解決済み）

`ad_gate_service_test`, `app_theme_test`, `bike_zukan_test`, `conflict_resolution_service_test`, `connectivity_service_test`, `guide_test`, `hazard_scenario_test`, `hybrid_data_service_test`, `l10n_arb_keys_test`, `offline_sync_integration_test`, `oshi_card_test`, `oshi_kit_adoption_test`, `paywall_view_test`, `phase_18_integration_test`, `phase_18_reporting_ui_test`, `phase_18_ui_widget_test`, `phase_20_cloud_functions_test`, `prediction_score_service_test`, `premium_limits_test`, `question_data_test`, `question_model_test`, `question_signs_test`, `report_service_test`, `skill_exam_test`, `solve_coverage_test`, `startup_splash_test`, `study_analytics_topic_test`, `sync_queue_service_test`, `traffic_sign_data_test`, `traffic_sign_render_test`, `user_deletion_flow_test`

`phase_18_*`/`phase_20_*` など自己完結型（lib を import しない）もここに含む。実行結果での別途確認が必要。
