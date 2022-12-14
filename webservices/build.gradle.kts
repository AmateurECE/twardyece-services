tasks.register("service_definitions") {
    val servicesPath = "$buildDir/services"
}

tasks.getByPath(":build").dependsOn(
    tasks.register("build_compose_file") {
        dependsOn("service_definitions")

        doLast {
            println("build_compose_file")
        }
    }
)
