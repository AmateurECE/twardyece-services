import com.twardyece.services.Service

plugins {
    id("com.twardyece.services")
}

tasks.register<Service>("getstuff") {
    service.set("Stuff")
}
