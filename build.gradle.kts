plugins {
    id("com.twardyece.containers")
}

dependencies {
    dockerCompose(project(":compilations"))
}
