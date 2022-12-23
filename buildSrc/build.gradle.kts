plugins {
    // Unfortunately, have to currently specify a version since this plugin
    // doesn't appear to be part of Gradle core plugins
    kotlin("jvm") version "1.7.0"
    id("java-gradle-plugin")
}

repositories {
    // Enable mavenCentral to build dependencies of kotlin-dsl
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib", "1.7.0"))
}

gradlePlugin {
    plugins {
        create("services") {
            id = "com.twardyece.containers"
            implementationClass = "com.twardyece.containers.ContainerPlugin"
        }
    }
}
