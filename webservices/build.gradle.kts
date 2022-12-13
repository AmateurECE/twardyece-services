tasks.getByPath(":hello").doLast({
    println("Child: $buildDir")
})
