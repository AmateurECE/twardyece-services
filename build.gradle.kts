tasks.register("hello") {
    doLast {
        println("Parent: $buildDir")
    }
}
