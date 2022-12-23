package com.twardyece.containers

import org.gradle.api.Plugin
import org.gradle.api.Project

public class ContainerPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        project.configurations.create("dockerCompose")
        project.tasks.create("buildDockerCompose",
            BuildDockerCompose::class.java)

        // To then set things, provide a closure:
        // project.tasks.create("taskName", TaskType::class.java, {
        //     it.property.set("value")
        // })
    }
}
