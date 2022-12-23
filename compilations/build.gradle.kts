val dockerCompose by configurations.creating {
    isCanBeConsumed = true
    isCanBeResolved = false
}

artifacts {
    add("dockerCompose", layout.buildDirectory.file(
        "docker-compose.yaml"))
}
