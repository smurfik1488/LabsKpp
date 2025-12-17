plugins {
    id("com.android.application")
    id("kotlin-android")

    // Firebase Crashlytics
    id("com.google.firebase.crashlytics")

    // Flutter plugin — має бути до google-services
    id("dev.flutter.flutter-gradle-plugin")

    // Google services plugin – завжди ОСТАННІЙ
    id("com.google.gms.google-services")
}

android {
    namespace = "mycompany.trezo"
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
        applicationId = "mycompany.trezo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Додаємо це (обов'язково для Firebase)
    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
