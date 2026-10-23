import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// リリース署名の入力: android/key.properties（優先）→ 環境変数 UPLOAD_*。
val keystoreProperties = Properties()
rootProject.file("key.properties").takeIf { it.exists() }?.let {
    FileInputStream(it).use { stream -> keystoreProperties.load(stream) }
}
fun signingProp(key: String, env: String): String? =
    keystoreProperties.getProperty(key) ?: System.getenv(env)?.takeIf { it.isNotBlank() }

val hasReleaseSigning: Boolean =
    listOf(
        "storeFile" to "UPLOAD_STORE_FILE",
        "storePassword" to "UPLOAD_STORE_PASSWORD",
        "keyAlias" to "UPLOAD_KEY_ALIAS",
        "keyPassword" to "UPLOAD_KEY_PASSWORD",
    ).all { (k, e) -> signingProp(k, e) != null }

// AdMob App ID（注入式）。-PADMOB_APP_ID または環境変数 ADMOB_APP_ID。
val admobAppId: String? =
    (findProperty("ADMOB_APP_ID") as String?)?.takeIf { it.isNotBlank() }
        ?: System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() }
// Google 公式のテスト App ID（debug 用フォールバック）
val ADMOB_TEST_APP_ID = "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.yourwish.bikelicense"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.yourwish.bikelicense"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // AdMob App ID は注入式（ソースに本番IDを置かない）。
        // gradle プロパティ -PADMOB_APP_ID または環境変数 ADMOB_APP_ID。
        // 未設定時は Google 公式のテスト App ID（debug 用）。release で未設定なら
        // 下の taskGraph チェックで失敗する。
        manifestPlaceholders["admobAppId"] = admobAppId ?: ADMOB_TEST_APP_ID
    }

    signingConfigs {
        // release 署名の入力は android/key.properties（ローカル、gitignore対象）または
        // 環境変数 UPLOAD_*（CI の GitHub Secrets）。両方無い場合 release ビルドは失敗する。
        create("release") {
            if (hasReleaseSigning) {
                storeFile = file(signingProp("storeFile", "UPLOAD_STORE_FILE")!!)
                storePassword = signingProp("storePassword", "UPLOAD_STORE_PASSWORD")
                keyAlias = signingProp("keyAlias", "UPLOAD_KEY_ALIAS")
                keyPassword = signingProp("keyPassword", "UPLOAD_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // debug 署名へのフォールバックはしない（鍵が無ければ下の taskGraph チェックで失敗）。
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// release 系タスクが実行される場合のみ署名入力を必須にする（debug ビルド/analyze/test には影響しない）。
gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any {
        it.project == project && Regex("^(assemble|bundle|package)(.*)Release$").matches(it.name)
    }
    if (releaseRequested) {
        if (admobAppId == null) {
            throw GradleException(
                "release ビルドには AdMob App ID が必要です。-PADMOB_APP_ID または環境変数 ADMOB_APP_ID を設定してください。"
            )
        }
        if (admobAppId.startsWith("ca-app-pub-3940256099942544")) {
            throw GradleException("release ビルドに Google のテスト AdMob App ID は使えません。")
        }
        if (!hasReleaseSigning) {
            throw GradleException(
                "release ビルドには署名鍵が必要です。android/key.properties " +
                    "(storeFile/storePassword/keyAlias/keyPassword) または環境変数 " +
                    "UPLOAD_STORE_FILE/UPLOAD_STORE_PASSWORD/UPLOAD_KEY_ALIAS/UPLOAD_KEY_PASSWORD を設定してください。"
            )
        }
        if (!file(signingProp("storeFile", "UPLOAD_STORE_FILE")!!).exists()) {
            throw GradleException("署名キーストアが見つかりません: " + signingProp("storeFile", "UPLOAD_STORE_FILE"))
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
