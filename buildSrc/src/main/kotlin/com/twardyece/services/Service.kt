package com.twardyece.services

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.TaskAction
import org.gradle.api.provider.Property

public abstract class Service : DefaultTask() {
    @get:Input
    abstract val service: Property<String>

    @TaskAction
    fun run() {
        println("Building " + service.get())
    }
}
