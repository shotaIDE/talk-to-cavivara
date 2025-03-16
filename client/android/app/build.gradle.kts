plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.house_worker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // applicationId は flavorDimensions で上書きされます
        applicationId = "ide.shota.colomney.HouseWorker"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("emulator") {
            dimension = "environment"
            applicationIdSuffix = ".emulator"
            manifestPlaceholders["usesCleartextTraffic"] = "true"
            resValue("string", "app_name", "House Worker [Emulator]")
        }
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["usesCleartextTraffic"] = "true"
            resValue("string", "app_name", "House Worker [Dev]")
        }
        create("prod") {
            dimension = "environment"
            // 本番環境はサフィックスなし
            manifestPlaceholders["usesCleartextTraffic"] = "false"
            resValue("string", "app_name", "House Worker")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
