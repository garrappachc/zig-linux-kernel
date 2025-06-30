const std = @import("std");

const kernel_version = "6.15.3-arch1-1";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{
        .cpu_model = .baseline,
        .os_tag = .freestanding,
        .abi = .gnu,
    } });
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addObject(.{
        .name = "root",
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .kernel,
    });

    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/arch/x86/include" });
    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/arch/x86/include/generated" });
    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/include" });
    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/arch/x86/include/uapi" });
    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/arch/x86/include/generated/uapi" });
    module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/include/uapi" });
    // module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/include/generated" });
    // module.addIncludePath(.{ .cwd_relative = "/usr/lib/modules/" ++ kernel_version ++ "/build/include/generated/uapi" });

    const orc = b.addSystemCommand(&.{
        "/lib/modules/" ++ kernel_version ++ "/build/tools/objtool/objtool",
        // "--verbose",
        "--hacks=jump_label",
        "--hacks=noinstr",
        "--hacks=skylake",
        "--ibt",
        "--orc",
        "--retpoline",
        "--rethunk",
        "--sls",
        "--static-call",
        "--prefix=16",
        "--link",
        "--uaccess",
        "--module",
    });
    orc.addArtifactArg(module);

    const ldm = b.addSystemCommand(&.{ "/usr/bin/ld", "-r", "-m", "elf_x86_64", "-z", "noexecstack", "--no-warn-rwx-segments", "--build-id=sha1", "-T", "/usr/lib/modules/" ++ kernel_version ++ "/build/scripts/module.lds", "-o", "zigmodule.ko" });
    ldm.addArtifactArg(module);
    ldm.step.dependOn(&orc.step);

    const pahole = b.addSystemCommand(&.{ "/usr/bin/pahole", "-J", "-j", "btf_features=encode_force,var,float,enum64,decl_tag,type_tag,optimized_func,consistent_func,decl_tag_kfuncs", "--lang_exclude=rust", "--btf_features=distilled_base", "--btf_base", "/usr/lib/modules/" ++ kernel_version ++ "/build/vmlinux", "zigmodule.ko" });
    pahole.step.dependOn(&ldm.step);

    const resolveBtfids = b.addSystemCommand(&.{ "/usr/lib/modules/" ++ kernel_version ++ "/build/tools/bpf/resolve_btfids/resolve_btfids", "-b", "/usr/lib/modules/" ++ kernel_version ++ "/build/vmlinux", "zigmodule.ko" });
    resolveBtfids.step.dependOn(&pahole.step);

    // b.installArtifact(module);
    b.default_step.dependOn(&module.step);
    b.default_step.dependOn(&orc.step);
    b.default_step.dependOn(&ldm.step);
}
