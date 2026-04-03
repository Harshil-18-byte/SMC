buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:deprecation")
    }
}

// Redirect build directories to project root/build/<subproject_name>
// This ensures Flutter CLI can find build artifacts at the expected location
val newBuildDir = rootProject.layout.projectDirectory.dir("../build")
subprojects {
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
}

// Standard build directory configuration
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    plugins.withId("com.android.application") {
        val android = project.extensions.getByName("android")
        try {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
            if (getNamespace.invoke(android) == null) {
                val fallbackNamespace = "smc.generated.${project.name.replace("-", ".").replace("_", ".")}"
                setNamespace.invoke(android, fallbackNamespace)
                println("Setting fallback namespace for ${project.name}: $fallbackNamespace")
            }
        } catch (e: Exception) { }
    }
    plugins.withId("com.android.library") {
        val android = project.extensions.getByName("android")
        try {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
            if (getNamespace.invoke(android) == null) {
                val fallbackNamespace = "smc.generated.${project.name.replace("-", ".").replace("_", ".")}"
                setNamespace.invoke(android, fallbackNamespace)
                println("Setting fallback namespace for ${project.name}: $fallbackNamespace")
            }
        } catch (e: Exception) { }
    }
}
