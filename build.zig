const std = @import("std");

const tracy = "build/tracy/tracy-0.11.1/";

fn buildJtracy(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const lib = b.addSharedLibrary(.{ .name = "jtracy", .target = target, .optimize = optimize });

    const base_args = &[_][]const u8{ "--std=c++20", "-DTRACY_ENABLE" };
    const args = if (target.result.os.tag == .windows)
        base_args ++ &[_][]const u8{
            "-DJNIEXPORT=__declspec(dllexport)",
        }
    else
        base_args;

    const env = std.process.getEnvMap(b.allocator) catch unreachable;
    const java_home = env.get("JAVA_HOME") orelse unreachable;
    const java_include_path = std.fmt.allocPrint(b.allocator, "{s}/include", .{java_home}) catch unreachable;
    const java_darwin_include_path = std.fmt.allocPrint(b.allocator, "{s}/include/darwin", .{java_home}) catch unreachable;

    lib.addCSourceFiles(.{
        .files = &.{ "src/main/cpp/JTracy.cpp", tracy ++ "public/TracyClient.cpp" },
        .flags = args,
    });
    lib.addIncludePath(b.path(tracy ++ "public"));
    lib.addSystemIncludePath(.{ .cwd_relative = java_include_path });
    lib.addSystemIncludePath(.{ .cwd_relative = java_darwin_include_path });

    lib.linkLibC();
    lib.linkLibCpp();

    if (target.result.os.tag == .windows) {
        lib.linkSystemLibrary("dbghelp");
        lib.linkSystemLibrary("ws2_32");
    }

    b.installArtifact(lib);
}

fn buildTracy(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const os = target.result.os.tag;
    const args = &[_][]const u8{
        "--std=c++20",
        "-fexperimental-library",
    };

    const tracyCommon = b.addStaticLibrary(.{ .name = "tracyCommon", .target = target, .optimize = optimize });
    tracyCommon.addCSourceFiles(.{
        .files = &.{
            tracy ++ "public/common/tracy_lz4.cpp",
            tracy ++ "public/common/tracy_lz4hc.cpp",
            tracy ++ "public/common/TracySocket.cpp",
            tracy ++ "public/common/TracyStackFrames.cpp",
            tracy ++ "public/common/TracySystem.cpp",
        },
        .flags = args,
    });
    tracyCommon.linkLibC();
    tracyCommon.linkLibCpp();

    const tracyClient = b.addStaticLibrary(.{ .name = "tracyClient", .target = target, .optimize = optimize });
    tracyClient.addCSourceFiles(.{
        .files = &.{
            tracy ++ "public/client/TracyAlloc.cpp",
            tracy ++ "public/client/TracyProfiler.cpp",
            tracy ++ "public/client/TracySysTime.cpp",
            tracy ++ "public/client/TracyCallstack.cpp",
            tracy ++ "public/client/TracyDxt1.cpp",
            tracy ++ "public/client/tracy_rpmalloc.cpp",
            tracy ++ "public/client/TracySysTrace.cpp",
            tracy ++ "public/client/TracySysPower.cpp",
            tracy ++ "public/client/TracyKCore.cpp",
        },
        .flags = args,
    });
    tracyClient.linkLibC();
    tracyClient.linkLibCpp();

    const tracyServer = b.addStaticLibrary(.{ .name = "tracyServer", .target = target, .optimize = optimize });
    tracyServer.addCSourceFiles(.{
        .files = &.{
            tracy ++ "server/TracyMemory.cpp",
            tracy ++ "server/TracyMmap.cpp",
            tracy ++ "server/TracyPrint.cpp",
            tracy ++ "server/TracySysUtil.cpp",
            tracy ++ "server/TracyTaskDispatch.cpp",
            tracy ++ "server/TracyTextureCompression.cpp",
            tracy ++ "server/TracyThreadCompress.cpp",
            tracy ++ "server/TracyWorker.cpp",
        },
        .flags = args,
    });
    tracyServer.linkLibC();
    tracyServer.linkLibCpp();

    const libbacktrace = b.addStaticLibrary(.{ .name = "libbacktrace", .target = target, .optimize = optimize });
    if (os != .windows) {
        libbacktrace.addCSourceFiles(.{
            .files = &.{
                tracy ++ "public/libbacktrace/alloc.cpp",
                tracy ++ "public/libbacktrace/dwarf.cpp",
                tracy ++ "public/libbacktrace/fileline.cpp",
                tracy ++ "public/libbacktrace/mmapio.cpp",
                tracy ++ "public/libbacktrace/posix.cpp",
                tracy ++ "public/libbacktrace/sort.cpp",
                tracy ++ "public/libbacktrace/state.cpp",
                tracy ++ "public/libbacktrace/macho.cpp",
            },
            .flags = args,
        });
        libbacktrace.linkLibC();
        libbacktrace.linkLibCpp();
    }

    // zstd
    const zstd = b.addStaticLibrary(.{ .name = "zstd", .target = target, .optimize = optimize });
    zstd.addCSourceFiles(.{ .files = &.{
        tracy ++ "zstd/decompress/zstd_ddict.c",
        tracy ++ "zstd/decompress/zstd_decompress_block.c",
        tracy ++ "zstd/decompress/huf_decompress.c",
        tracy ++ "zstd/decompress/zstd_decompress.c",
        tracy ++ "zstd/common/zstd_common.c",
        tracy ++ "zstd/common/error_private.c",
        tracy ++ "zstd/common/xxhash.c",
        tracy ++ "zstd/common/entropy_common.c",
        tracy ++ "zstd/common/debug.c",
        tracy ++ "zstd/common/threading.c",
        tracy ++ "zstd/common/pool.c",
        tracy ++ "zstd/common/fse_decompress.c",
        tracy ++ "zstd/compress/zstd_ldm.c",
        tracy ++ "zstd/compress/zstd_compress_superblock.c",
        tracy ++ "zstd/compress/zstd_opt.c",
        tracy ++ "zstd/compress/zstd_compress_sequences.c",
        tracy ++ "zstd/compress/fse_compress.c",
        tracy ++ "zstd/compress/zstd_double_fast.c",
        tracy ++ "zstd/compress/zstd_compress.c",
        tracy ++ "zstd/compress/zstd_compress_literals.c",
        tracy ++ "zstd/compress/hist.c",
        tracy ++ "zstd/compress/zstdmt_compress.c",
        tracy ++ "zstd/compress/zstd_lazy.c",
        tracy ++ "zstd/compress/huf_compress.c",
        tracy ++ "zstd/compress/zstd_fast.c",
        tracy ++ "zstd/dictBuilder/zdict.c",
        tracy ++ "zstd/dictBuilder/cover.c",
        tracy ++ "zstd/dictBuilder/divsufsort.c",
        tracy ++ "zstd/dictBuilder/fastcover.c",
    }, .flags = &.{"-DZSTD_DISABLE_ASM"} });
    zstd.linkLibC();

    // Capstone
    const capstone = b.addStaticLibrary(.{ .name = "capstone", .target = target, .optimize = optimize });
    const capstonePath = "build/capstone/capstone-5.0.3/";
    capstone.addCSourceFiles(.{
        .files = &.{
            capstonePath ++ "cs.c",
            capstonePath ++ "Mapping.c",
            capstonePath ++ "MCInst.c",
            capstonePath ++ "MCInstrDesc.c",
            capstonePath ++ "MCRegisterInfo.c",
            capstonePath ++ "SStream.c",
            capstonePath ++ "utils.c",
        },
    });
    capstone.addIncludePath(b.path(capstonePath ++ "include"));
    capstone.linkLibC();

    tracyServer.linkLibrary(capstone);
    tracyServer.addIncludePath(b.path(capstonePath ++ "include/capstone"));

    // Imgui
    const imgui = b.addStaticLibrary(.{ .name = "imgui", .target = target, .optimize = optimize });
    imgui.addCSourceFiles(.{
        .files = &.{
            tracy ++ "imgui/imgui.cpp",
            tracy ++ "imgui/imgui_draw.cpp",
            tracy ++ "imgui/imgui_widgets.cpp",
            tracy ++ "imgui/imgui_tables.cpp",
        },
        .flags = args,
    });
    imgui.linkLibC();
    imgui.linkLibCpp();

    // NFD
    const nfd = b.addStaticLibrary(.{ .name = "nfd", .target = target, .optimize = optimize });
    if (os == .macos) {
        nfd.addCSourceFiles(.{ .files = &.{
            tracy ++ "nfd/nfd_cocoa.m",
        } });

        nfd.linkLibC();
        nfd.linkFramework("AppKit");
    } else if (os == .windows) {
        nfd.addCSourceFiles(.{
            .files = &.{
                tracy ++ "nfd/nfd_win.cpp",
            },
            .flags = args,
        });
        nfd.linkLibC();
        nfd.linkLibCpp();
    }

    // GLFW
    const glfwPath = "build/glfw/glfw-3.4/";
    const glfw = b.addStaticLibrary(.{ .name = "glfw", .target = target, .optimize = optimize });

    const baseGlfwArgs = &[_][]const u8{};
    const glfwArgs = if (os == .windows)
        baseGlfwArgs ++ &[_][]const u8{
            "-D_GLFW_WIN32",
        }
    else if (os == .macos)
        baseGlfwArgs ++ &[_][]const u8{
            "-D_GLFW_COCOA",
        }
    else
        baseGlfwArgs;

    glfw.addCSourceFiles(.{
        .files = &.{
            glfwPath ++ "src/context.c",
            glfwPath ++ "src/init.c",
            glfwPath ++ "src/input.c",
            glfwPath ++ "src/monitor.c",
            glfwPath ++ "src/platform.c",
            glfwPath ++ "src/vulkan.c",
            glfwPath ++ "src/window.c",
            glfwPath ++ "src/egl_context.c",
            glfwPath ++ "src/osmesa_context.c",
            glfwPath ++ "src/null_init.c",
            glfwPath ++ "src/null_monitor.c",
            glfwPath ++ "src/null_window.c",
            glfwPath ++ "src/null_joystick.c",
        },
        .flags = glfwArgs,
    });

    glfw.linkLibC();

    if (os == .macos) {
        glfw.addCSourceFiles(.{
            .files = &.{
                glfwPath ++ "src/cocoa_time.c",
                glfwPath ++ "src/posix_module.c",
                glfwPath ++ "src/posix_thread.c",
                glfwPath ++ "src/cocoa_init.m",
                glfwPath ++ "src/cocoa_joystick.m",
                glfwPath ++ "src/cocoa_monitor.m",
                glfwPath ++ "src/cocoa_window.m",
                glfwPath ++ "src/nsgl_context.m",
            },
            .flags = glfwArgs,
        });

        glfw.linkFramework("CoreFoundation");
        glfw.linkFramework("IOKit");
        glfw.linkFramework("Cocoa");
        glfw.linkFramework("UniformTypeIdentifiers");
        glfw.linkSystemLibrary("objc");
    } else if (os == .windows) {
        glfw.addCSourceFiles(.{
            .files = &.{
                glfwPath ++ "src/win32_init.c",
                glfwPath ++ "src/win32_joystick.c",
                glfwPath ++ "src/win32_monitor.c",
                glfwPath ++ "src/win32_window.c",
                glfwPath ++ "src/wgl_context.c",
                glfwPath ++ "src/win32_module.c",
                glfwPath ++ "src/win32_time.c",
                glfwPath ++ "src/win32_thread.c",
            },
            .flags = glfwArgs,
        });
    }

    { // Capture
        const catpure = b.addExecutable(.{ .name = "capture", .target = target, .optimize = optimize });
        catpure.addCSourceFiles(.{
            .files = &.{
                tracy ++ "capture/src/capture.cpp",
            },
            .flags = args,
        });
        catpure.linkLibC();
        catpure.linkLibCpp();
        catpure.linkLibrary(tracyCommon);
        catpure.linkLibrary(tracyClient);
        catpure.linkLibrary(tracyServer);
        catpure.linkLibrary(zstd);

        if (os != .windows) {
            catpure.linkLibrary(libbacktrace);
        }

        if (os == .windows) {
            catpure.linkSystemLibrary("dbghelp");
            catpure.linkSystemLibrary("ws2_32");
        }

        catpure.addIncludePath(b.path(tracy ++ "server"));
        catpure.addIncludePath(b.path(tracy ++ "public"));
        catpure.addIncludePath(b.path(tracy ++ "zstd"));

        b.installArtifact(catpure);
    }

    { // Profiler
        const profiler = b.addExecutable(.{ .name = "profiler", .target = target, .optimize = optimize });
        profiler.addCSourceFiles(.{
            .files = &.{
                tracy ++ "profiler/src/imgui/imgui_impl_opengl3.cpp",
                tracy ++ "profiler/src/imgui/imgui_impl_glfw.cpp",
                tracy ++ "profiler/src/ConnectionHistory.cpp",
                tracy ++ "profiler/src/Filters.cpp",
                tracy ++ "profiler/src/Fonts.cpp",
                tracy ++ "profiler/src/HttpRequest.cpp",
                tracy ++ "profiler/src/ImGuiContext.cpp",
                tracy ++ "profiler/src/IsElevated.cpp",
                tracy ++ "profiler/src/main.cpp",
                tracy ++ "profiler/src/ResolvService.cpp",
                tracy ++ "profiler/src/RunQueue.cpp",
                tracy ++ "profiler/src/WindowPosition.cpp",
                // tracy ++ "profiler/src/winmain.cpp",
                tracy ++ "profiler/src/winmainArchDiscovery.cpp",
                tracy ++ "profiler/src/BackendGlfw.cpp",
                tracy ++ "profiler/src/profiler/TracyAchievementData.cpp",
                tracy ++ "profiler/src/profiler/TracyAchievements.cpp",
                tracy ++ "profiler/src/profiler/TracyBadVersion.cpp",
                tracy ++ "profiler/src/profiler/TracyColor.cpp",
                tracy ++ "profiler/src/profiler/TracyEventDebug.cpp",
                tracy ++ "profiler/src/profiler/TracyFileselector.cpp",
                tracy ++ "profiler/src/profiler/TracyFilesystem.cpp",
                tracy ++ "profiler/src/profiler/TracyImGui.cpp",
                tracy ++ "profiler/src/profiler/TracyMicroArchitecture.cpp",
                tracy ++ "profiler/src/profiler/TracyMouse.cpp",
                tracy ++ "profiler/src/profiler/TracyProtoHistory.cpp",
                tracy ++ "profiler/src/profiler/TracySourceContents.cpp",
                tracy ++ "profiler/src/profiler/TracySourceTokenizer.cpp",
                tracy ++ "profiler/src/profiler/TracySourceView.cpp",
                tracy ++ "profiler/src/profiler/TracyStorage.cpp",
                tracy ++ "profiler/src/profiler/TracyTexture.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineController.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineItem.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineItemCpuData.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineItemGpu.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineItemPlot.cpp",
                tracy ++ "profiler/src/profiler/TracyTimelineItemThread.cpp",
                tracy ++ "profiler/src/profiler/TracyUserData.cpp",
                tracy ++ "profiler/src/profiler/TracyUtility.cpp",
                tracy ++ "profiler/src/profiler/TracyView.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Annotations.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Callstack.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Compare.cpp",
                tracy ++ "profiler/src/profiler/TracyView_ConnectionState.cpp",
                tracy ++ "profiler/src/profiler/TracyView_ContextSwitch.cpp",
                tracy ++ "profiler/src/profiler/TracyView_CpuData.cpp",
                tracy ++ "profiler/src/profiler/TracyView_FindZone.cpp",
                tracy ++ "profiler/src/profiler/TracyView_FrameOverview.cpp",
                tracy ++ "profiler/src/profiler/TracyView_FrameTimeline.cpp",
                tracy ++ "profiler/src/profiler/TracyView_FrameTree.cpp",
                tracy ++ "profiler/src/profiler/TracyView_GpuTimeline.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Locks.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Memory.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Messages.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Navigation.cpp",
                tracy ++ "profiler/src/profiler/TracyView_NotificationArea.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Options.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Playback.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Plots.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Ranges.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Samples.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Statistics.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Timeline.cpp",
                tracy ++ "profiler/src/profiler/TracyView_TraceInfo.cpp",
                tracy ++ "profiler/src/profiler/TracyView_Utility.cpp",
                tracy ++ "profiler/src/profiler/TracyView_ZoneInfo.cpp",
                tracy ++ "profiler/src/profiler/TracyView_ZoneTimeline.cpp",
                tracy ++ "profiler/src/profiler/TracyWeb.cpp",
            },
            .flags = args,
        });
        profiler.addCSourceFiles(.{
            .files = &.{
                tracy ++ "profiler/src/ini.c",
            },
        });

        profiler.linkLibC();
        profiler.linkLibCpp();

        profiler.linkLibrary(tracyCommon);
        profiler.linkLibrary(tracyClient);
        profiler.linkLibrary(tracyServer);
        profiler.linkLibrary(zstd);
        profiler.linkLibrary(imgui);
        profiler.linkLibrary(capstone);
        profiler.linkLibrary(nfd);
        profiler.linkLibrary(glfw);

        if (os != .windows) {
            profiler.linkLibrary(libbacktrace);
        }

        profiler.addIncludePath(b.path(tracy ++ "profiler"));
        profiler.addIncludePath(b.path(tracy ++ "server"));
        profiler.addIncludePath(b.path(tracy ++ "public"));

        profiler.addIncludePath(b.path(tracy ++ "imgui"));
        profiler.addIncludePath(b.path(tracy ++ "nfd"));
        profiler.addIncludePath(b.path(capstonePath ++ "include/capstone"));
        profiler.addIncludePath(b.path(glfwPath ++ "include"));

        if (os == .windows) {
            profiler.linkSystemLibrary("dbghelp");
            profiler.linkSystemLibrary("ws2_32");
            profiler.linkSystemLibrary("gdi32");
            profiler.linkSystemLibrary("ole32");
        }

        if (target.result.os.tag == .windows or (target.result.os.tag == .macos and target.result.cpu.arch == .aarch64)) {
            b.installArtifact(profiler);
        }
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    buildJtracy(b, target, optimize);
    buildTracy(b, target, optimize);
}
