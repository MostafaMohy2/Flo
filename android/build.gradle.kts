allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
