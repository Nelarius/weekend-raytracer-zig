const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("zig-tracer", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.linkSystemLibrary("c");

    // if (exe.target.isDarwin()) {
    //     exe.addIncludeDir("/opt/homebrew/include/SDL2");
    //     exe.addLibPath("/opt/homebrew/lib");
    //     exe.linkFramework("SDL2");
    // } else {
    //     exe.linkSystemLibrary("SDL2");
    // }
    // exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("iconv");
    exe.linkFramework("AppKit");
    exe.linkFramework("AudioToolbox");
    exe.linkFramework("Carbon");
    exe.linkFramework("Cocoa");
    exe.linkFramework("CoreAudio");
    exe.linkFramework("CoreFoundation");
    exe.linkFramework("CoreGraphics");
    exe.linkFramework("CoreHaptics");
    exe.linkFramework("CoreVideo");
    exe.linkFramework("ForceFeedback");
    exe.linkFramework("GameController");
    exe.linkFramework("IOKit");
    exe.linkFramework("Metal");
    
    exe.install();

    const run = b.step("run", "Run the project");
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    run.dependOn(&run_cmd.step);
}
