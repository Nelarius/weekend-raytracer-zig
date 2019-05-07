const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const lib_cflags = [][]const u8{"-std=c99"};

    var sdl_wrapper = b.addStaticLibrary("pixel", null);
    sdl_wrapper.addCSourceFile("src/pixel.c", lib_cflags);
    sdl_wrapper.addIncludeDir("src/");
    sdl_wrapper.addIncludeDir("/Library/Frameworks/SDL2.framework/Headers");

    const exe = b.addExecutable("zig-tracer", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.addIncludeDir("src/");
    exe.linkLibrary(sdl_wrapper);
    exe.linkSystemLibrary("c");
    if (exe.target.isDarwin()) {
        exe.addIncludeDir("/Library/Frameworks/SDL2.framework/Headers");
        exe.linkFramework("SDL2");
    }

    const run = b.step("run", "Run the project");
    const run_cmd = exe.run();
    run.dependOn(&run_cmd.step);
}
