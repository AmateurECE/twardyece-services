interface DockerComposePluginExtension {
    val filename: Property<String>
}

class DockerComposePlugin : Plugin<Project> {
    @Inject
    public constructor() {}

    override fun apply(project: Project) {
        val extension = project.extensions
            .create<DockerComposePluginExtension>("docker-compose.yaml")
        extension.filename.convention("docker-compose.yaml")
        val dockerCompose by configurations.creating {
            isCanBeConsumed = true
            isCanBeResolved = false
        }
    }
}

apply<DockerComposePlugin>()

artifacts {
    add("dockerCompose", layout.buildDirectory.file(
        extension.filename.get()))
}
