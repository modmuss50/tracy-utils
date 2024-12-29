package me.modmuss50.tracyutils;

import net.fabricmc.loader.api.ModContainer;

import java.nio.file.Path;
import java.util.Optional;

public class NativeLocator {
    // E.g linux-aarch64
    public static final String OS_ID = getOsName();

    public static Optional<Path> getJtracy() {
        return getPath("jtracy" + getSharedLibExt());
    }

    public static Optional<Path> getTracyCapture() {
        return getPath("tracy-capture" + getExecutableExt());
    }

    public static Optional<Path> getTracyProfiler() {
        return getPath("tracy-profiler" + getExecutableExt());
    }

    private static Optional<Path> getPath(String name) {
        ModContainer modContainer = TracyUtils.getModContainer();
        return modContainer.findPath("tracyutils/%s-%s".formatted(OS_ID, name));
    }

    private static String getOsName() {
        String os = System.getProperty("os.name").toLowerCase();
        String osName = "unknown";

        if (os.contains("win")) {
            osName = "windows";
        } else if (os.contains("mac")) {
            osName = "macos";
        } else if (os.contains("linux")) {
            osName = "linux";
        }

        String arch = System.getProperty("os.arch").toLowerCase();
        String archName = "unknown";

        if ((arch.contains("arm") || arch.contains("aarch")) && arch.contains("64")) {
            archName = "aarch64";
        } else if (arch.contains("x86")) {
            archName = "x86";
        } else if (arch.contains("amd64") || arch.contains("x86_64")) {
            archName = "x86_64";
        } else if (arch.contains("riscv")) {
            archName = "riscv64";
        }

        return osName + "-" + archName;
    }

    private static String getExecutableExt() {
        return System.getProperty("os.name").toLowerCase().contains("win") ? ".exe" : "";
    }

    private static String getSharedLibExt() {
        String os = System.getProperty("os.name").toLowerCase();

        if (os.contains("win")) {
            return ".dll";
        } else if (os.contains("mac")) {
            return ".dylib";
        } else {
            return ".so";
        }
    }
}
