plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.usa_id_photo"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.usa_id_photo"
        minSdk = 27
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            // 正式上线时再填写你的签名信息
            // keyAlias = ""
            // keyPassword = ""
            // storeFile = file("")
            // storePassword = ""
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
      //  jvmTarget = "17"
    }
}

dependencies {
    // Flutter 会自动注入依赖，此处保持空结构即可
}