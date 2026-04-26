plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fem_psychmonitor"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    // compileSdk = 34
    // ndkVersion = "26.1.10909125"

    val cmakeListsFile = file("src/main/cpp/CMakeLists.txt")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.fem_psychmonitor"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // minSdk = flutter.minSdkVersion
        // targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += setOf("armeabi-v7a", "arm64-v8a")
        }

        if (cmakeListsFile.exists()) {
            externalNativeBuild {
                cmake {
                    cppFlags += "-std=c++17 -O3 -ffast-math"
                    abiFilters += setOf("arm64-v8a", "x86_64")
                }
            }
        }
    }

    if (cmakeListsFile.exists()) {
        externalNativeBuild {
            cmake {
                path = cmakeListsFile
                version = "3.22.1"
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
