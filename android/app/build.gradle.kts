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

        // AdMob App ID。「原付・バイク免許コレ！」用に発行済み（2026-09-28）。
        // App IDはアプリ識別用の公開情報のためデフォルト値として埋め込み、
        // 環境変数 ADMOB_APP_ID_ANDROID で上書きも可能にしておく。
        manifestPlaceholders["admobAppId"] =
            System.getenv("ADMOB_APP_ID_ANDROID") ?: "ca-app-pub-5058227312086483~9215678835"
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
