package com.twardyece.containers

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.TaskAction
import org.gradle.api.provider.Property

public abstract class BuildDockerCompose : DefaultTask() {
    @get:Input
    abstract val filename: Property<String>

    init {
        filename.convention("docker-compose.yaml")
    }

    @TaskAction
    fun run() {
        println("Building " + filename.get())
    }
}
