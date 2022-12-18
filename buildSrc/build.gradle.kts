plugins {
    // Unfortunately, have to currently specify a version since this plugin
    // doesn't appear to be part of Gradle core plugins
    id("org.gradle.kotlin.kotlin-dsl") version "2.4.1"
}

repositories {
    // Enable mavenCentral to build dependencies of kotlin-dsl
    mavenCentral()
}

gradlePlugin {
    plugins {
        create("services") {
            id = "com.twardyece.services"
            implementationClass = "com.twardyece.services.ServicePlugin"
        }
    }
}
