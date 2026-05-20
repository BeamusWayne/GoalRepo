plugins {
    kotlin("jvm") version "1.9.24"
    application
}

group = "com.local"
version = "1.0.0"

application {
    mainClass.set("MainKt")
}

tasks.jar {
    manifest { attributes("Main-Class" to "MainKt") }
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    from(configurations.runtimeClasspath.get().map { if (it.isDirectory) it else zipTree(it) })
}

repositories {
    mavenCentral()
}
