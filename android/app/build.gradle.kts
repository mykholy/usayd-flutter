plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "academy.usayd.usayd_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        // AGP 9 disables resValue by default; the flavors below use it for app_name.
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "academy.usayd.learner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Usayd Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "Usayd Staging")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "أكاديمية أُسَيْد")
        }
    }

    buildTypes {
        release {
            // Release signing is supplied by the publishing pipeline. Never use debug keys.
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
