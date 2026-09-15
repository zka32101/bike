plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.yourwish.bikelicensekore"
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
        applicationId = "com.yourwish.bikelicensekore"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // AdMob App ID。ADMOB_APP_ID_ANDROID が未設定ならGoogle公式テストIDのまま。
        // 本番公開前に実際のAdMob App IDを環境変数（またはCIのSecret）で渡すこと。
        manifestPlaceholders["admobAppId"] =
            System.getenv("ADMOB_APP_ID_ANDROID") ?: "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        // storePassword / keyPassword come from the KEYSTORE_PASSWORD / KEY_PASSWORD
        // environment variables (set locally before a release build, or from
        // GitHub Secrets in CI) — never hardcode them here.
        create("release_test") {
            storeFile = file("../keystore/release_new.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD_TEST") ?: System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "bike_license_release"
            keyPassword = System.getenv("KEY_PASSWORD_TEST") ?: System.getenv("KEY_PASSWORD")
        }
        create("release_prod") {
            storeFile = file("../keystore/release_prod.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD_PROD")
            keyAlias = "bike_license_release_prod"
            keyPassword = System.getenv("KEY_PASSWORD_PROD")
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
            // Signing configuration priority:
            // 1. Production keystore + KEYSTORE_PASSWORD_PROD env var
            // 2. Test keystore + KEYSTORE_PASSWORD_TEST env var
            // 3. Debug signature (fallback)
            signingConfig = when {
                System.getenv("KEYSTORE_PASSWORD_PROD") != null &&
                file("../keystore/release_prod.jks").exists() -> {
                    signingConfigs.getByName("release_prod")
                }
                System.getenv("KEYSTORE_PASSWORD_TEST") != null &&
                file("../keystore/release_new.jks").exists() -> {
                    signingConfigs.getByName("release_test")
                }
                System.getenv("KEYSTORE_PASSWORD") != null &&
                file("../keystore/release_new.jks").exists() -> {
                    signingConfigs.getByName("release_test")
                }
                else -> {
                    signingConfigs.getByName("debug")
                }
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
