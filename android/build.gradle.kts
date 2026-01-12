buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Esta línea permite que tu proyecto reconozca los servicios de Google
        // Nota los paréntesis y las comillas dobles, propios de Kotlin DSL
        classpath("com.google.gms:google-services:4.4.1")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
