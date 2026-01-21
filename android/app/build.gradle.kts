plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.ariq.pakisgo"
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
        applicationId = "com.ariq.pakisgo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // untuk prototype boleh pakai debug
            isMinifyEnabled = false   // jangan shrink agar Firebase tidak hilang
            isShrinkResources = false // jangan hilangkan resource penting
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    lint {
        checkReleaseBuilds = false // optional: hindari error lint saat release
    }
}

dependencies {
    // Firebase BoM agar semua library versi kompatibel
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))

    // Library Firebase yang dibutuhkan
    implementation("com.google.firebase:firebase-auth")      // login Google
    implementation("com.google.firebase:firebase-analytics") // optional
    implementation("com.google.firebase:firebase-firestore") // jika pakai Firestore

    // Tambahkan library lain yang dibutuhkan proyekmu
}

flutter {
    source = "../.."
}
