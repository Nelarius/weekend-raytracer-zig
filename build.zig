const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("zig-tracer", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.linkSystemLibrary("c");

    if (exe.target.isDarwin()) {
        exe.addIncludeDir("/opt/homebrew/include/SDL2");
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
