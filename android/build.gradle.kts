buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 适配旧项目结构，不会报第 X 行错
        classpath("com.android.tools.build:gradle:3.6.4")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 清理任务
tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}