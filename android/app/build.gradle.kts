plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

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
        // Passwords from environment variables (GitHub Secrets in CI, or local env vars)
        create("release") {
            storeFile = file("../keystore/release_prod.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "bike_license_release_prod"
            // keytool defaults to PKCS12 (not JKS) since Java 9, regardless of the
            // .jks file extension. AGP assumes JKS unless told otherwise, which
            // causes signing to fail with a cryptic padding error.
            storeType = "PKCS12"
            // PKCS12 keystores encrypt the whole store with a single password;
            // there is no separate per-key password. AGP's signing code still
            // tries KEY_PASSWORD as a distinct key password, which fails to
            // decrypt (BadPaddingException) whenever it differs from the store
            // password. Force it to match the store password to match the
            // actual PKCS12 format.
            keyPassword = System.getenv("KEYSTORE_PASSWORD")
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
            // Use production keystore if KEYSTORE_PASSWORD env var is set
            // Fallback to debug signature if keystore is not available
            signingConfig =
                if (System.getenv("KEYSTORE_PASSWORD") != null &&
                    file("../keystore/release_prod.jks").exists()) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

afterEvaluate {
    val releaseConfig = android.signingConfigs.getByName("release")
    println("DEBUG signingConfig[release]: storeType=${releaseConfig.storeType}, storeFile=${releaseConfig.storeFile}, keyAlias=${releaseConfig.keyAlias}, storePassword.isNullOrEmpty=${releaseConfig.storePassword.isNullOrEmpty()}, keyPassword.isNullOrEmpty=${releaseConfig.keyPassword.isNullOrEmpty()}")
    val appliedConfig = android.buildTypes.getByName("release").signingConfig
    println("DEBUG buildType[release].signingConfig: name=${appliedConfig?.name}, storeType=${appliedConfig?.storeType}")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
