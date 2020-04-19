const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const lib_cflags = [_][]const u8{"-std=c99"};

    const exe = b.addExecutable("zig-tracer", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.addCSourceFile("src/pixel.c", &lib_cflags);
    exe.addIncludeDir("src/");
    exe.linkSystemLibrary("c");

    if (exe.target.isDarwin()) {
        exe.addIncludeDir("/Library/Frameworks/SDL2.framework/Headers");
        exe.linkFramework("SDL2");
    } else {
        exe.linkSystemLibrary("SDL2");
    }

    exe.install();

    const run = b.step("run", "Run the project");
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    run.dependOn(&run_cmd.step);
}
