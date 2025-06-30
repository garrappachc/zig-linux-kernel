const std = @import("std");
const mem = std.mem;

pub const linux = @cImport({
    @cDefine("__KERNEL__", {});
    @cDefine("MODULE", {});
    @cDefine("KBUILD_BASENAME", "\"root\"");
    @cDefine("KBUILD_MODNAME", "\"zigmodule\"");

    @cDefine("__KBUILD_MODNAME", "\"kmod_zigmodule\"");
    @cInclude("linux/kconfig.h");

    @cInclude("linux/init.h");
    @cInclude("linux/module.h");
    @cInclude("linux/export-internal.h");
    @cInclude("linux/compiler.h");
    @cInclude("linux/kernel.h");
    @cInclude("linux/printk.h");

    @cDefine("INCLUDE_VERMAGIC", {});
    @cInclude("linux/build-salt.h");
    @cInclude("linux/elfnote-lto.h");
    @cInclude("linux/vermagic.h");
});

pub fn printk(comptime fmt: []const u8, args: anytype) void {
    // linux._printk(fmt, args);
    _ = @call(.auto, linux._printk, .{@as([*c]const u8, @ptrCast(fmt))} ++ args);
}

const LinuxKernelModule = struct {
    pub const kobject = extern struct {
        name: [*c]const u8 = mem.zeroes([*c]const u8),
        entry: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        parent: [*c]kobject = mem.zeroes([*c]kobject),
        kset: [*c]kset = mem.zeroes([*c]kset),
        ktype: ?*anyopaque = mem.zeroes(?*anyopaque),
        sd: ?*anyopaque = mem.zeroes(?*anyopaque),
        kref: [*c]linux.struct_kref = mem.zeroes([*c]linux.struct_kref),

        // unsigned int state_initialized:1;
        // unsigned int state_in_sysfs:1;
        // unsigned int state_add_uevent_sent:1;
        // unsigned int state_remove_uevent_sent:1;
        // unsigned int uevent_suppress:1;
        _rest: u8,
    };

    pub const module_kobject = extern struct {
        kobj: kobject = mem.zeroes(kobject),
        mod: ?*module = mem.zeroes(?*module),
        drivers_dir: ?*kobject = mem.zeroes(?*kobject),
        mp: ?*linux.struct_module_param_attrs_79 = mem.zeroes(?*linux.struct_module_param_attrs_79),
        kobj_completion: [*c]linux.struct_completion = mem.zeroes([*c]linux.struct_completion),
    };

    pub const module_attribute = extern struct {
        attr: linux.struct_attribute = mem.zeroes(linux.struct_attribute),
        show: ?*const fn ([*c]const module_attribute, ?*module_kobject, [*c]u8) callconv(.c) isize = mem.zeroes(?*const fn ([*c]const module_attribute, ?*module_kobject, [*c]u8) callconv(.c) isize),
        store: ?*const fn ([*c]const module_attribute, ?*module_kobject, [*c]const u8, usize) callconv(.c) isize = mem.zeroes(?*const fn ([*c]const module_attribute, ?*module_kobject, [*c]const u8, usize) callconv(.c) isize),
        setup: ?*const fn (?*module, [*c]const u8) callconv(.c) void = mem.zeroes(?*const fn (?*module, [*c]const u8) callconv(.c) void),
        @"test": ?*const fn (?*module) callconv(.c) c_int = mem.zeroes(?*const fn (?*module) callconv(.c) c_int),
        free: ?*const fn (?*module) callconv(.c) void = mem.zeroes(?*const fn (?*module) callconv(.c) void),
    };

    pub const kset = extern struct {
        list: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        list_lock: linux.spinlock_t = mem.zeroes(linux.spinlock_t),
        kobj: kobject = mem.zeroes(kobject),
        uevent_ops: [*c]const linux.struct_kset_uevent_ops = mem.zeroes([*c]const linux.struct_kset_uevent_ops),
    };

    const mod_tree_node = extern struct {
        mod: ?*module = mem.zeroes(?*module),
        node: linux.struct_latch_tree_node = mem.zeroes(linux.struct_latch_tree_node),
    };

    pub const module_memory = extern struct {
        base: ?*anyopaque = mem.zeroes(?*anyopaque),
        is_rox: bool = mem.zeroes(bool),
        size: c_uint = mem.zeroes(c_uint),
        mtn: mod_tree_node = mem.zeroes(mod_tree_node),
    };

    pub const module = extern struct {
        state: linux.enum_module_state = mem.zeroes(linux.enum_module_state),
        list: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        name: [56]u8 = mem.zeroes([56]u8),
        build_id: [20]u8 = mem.zeroes([20]u8),
        mkobj: module_kobject = mem.zeroes(module_kobject),
        modinfo_attrs: [*c]module_attribute = mem.zeroes([*c]module_attribute),
        version: [*c]const u8 = mem.zeroes([*c]const u8),
        srcversion: [*c]const u8 = mem.zeroes([*c]const u8),
        holders_dir: ?*kobject = mem.zeroes(?*kobject),
        syms: ?*const linux.struct_kernel_symbol_80 = mem.zeroes(?*const linux.struct_kernel_symbol_80),
        crcs: [*c]const u32 = mem.zeroes([*c]const u32),
        num_syms: c_uint = mem.zeroes(c_uint),
        param_lock: linux.struct_mutex = mem.zeroes(linux.struct_mutex),
        kp: ?*anyopaque = mem.zeroes(?*anyopaque),
        num_kp: c_uint = mem.zeroes(c_uint),
        num_gpl_syms: c_uint = mem.zeroes(c_uint),
        gpl_syms: ?*const linux.struct_kernel_symbol_80 = mem.zeroes(?*const linux.struct_kernel_symbol_80),
        gpl_crcs: [*c]const u32 = mem.zeroes([*c]const u32),
        using_gplonly_symbols: bool = mem.zeroes(bool),
        sig_ok: bool = mem.zeroes(bool),
        async_probe_requested: bool = mem.zeroes(bool),
        num_exentries: c_uint = mem.zeroes(c_uint),
        extable: [*c]linux.struct_exception_table_entry = mem.zeroes([*c]linux.struct_exception_table_entry),
        init: ?*const fn () callconv(.c) c_int = mem.zeroes(?*const fn () callconv(.c) c_int),
        mem: [7]module_memory align(64) = mem.zeroes([7]module_memory),
        arch: linux.struct_mod_arch_specific = mem.zeroes(linux.struct_mod_arch_specific),
        taints: c_ulong = mem.zeroes(c_ulong),
        num_bugs: c_uint = mem.zeroes(c_uint),
        bug_list: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        bug_table: [*c]linux.struct_bug_entry = mem.zeroes([*c]linux.struct_bug_entry),
        kallsyms: [*c]linux.struct_mod_kallsyms = mem.zeroes([*c]linux.struct_mod_kallsyms),
        core_kallsyms: linux.struct_mod_kallsyms = mem.zeroes(linux.struct_mod_kallsyms),
        sect_attrs: ?*linux.struct_module_sect_attrs_82 = mem.zeroes(?*linux.struct_module_sect_attrs_82),
        notes_attrs: ?*linux.struct_module_notes_attrs_83 = mem.zeroes(?*linux.struct_module_notes_attrs_83),
        args: [*c]u8 = mem.zeroes([*c]u8),
        percpu: ?*anyopaque = mem.zeroes(?*anyopaque),
        percpu_size: c_uint = mem.zeroes(c_uint),
        noinstr_text_start: ?*anyopaque = mem.zeroes(?*anyopaque),
        noinstr_text_size: c_uint = mem.zeroes(c_uint),
        num_tracepoints: c_uint = mem.zeroes(c_uint),
        tracepoints_ptrs: [*c]const linux.tracepoint_ptr_t = mem.zeroes([*c]const linux.tracepoint_ptr_t),
        num_srcu_structs: c_uint = mem.zeroes(c_uint),
        srcu_struct_ptrs: [*c][*c]linux.struct_srcu_struct = mem.zeroes([*c][*c]linux.struct_srcu_struct),
        num_bpf_raw_events: c_uint = mem.zeroes(c_uint),
        bpf_raw_events: [*c]linux.struct_bpf_raw_event_map = mem.zeroes([*c]linux.struct_bpf_raw_event_map),
        btf_data_size: c_uint = mem.zeroes(c_uint),
        btf_base_data_size: c_uint = mem.zeroes(c_uint),
        btf_data: ?*anyopaque = mem.zeroes(?*anyopaque),
        btf_base_data: ?*anyopaque = mem.zeroes(?*anyopaque),
        jump_entries: [*c]linux.struct_jump_entry = mem.zeroes([*c]linux.struct_jump_entry),
        num_jump_entries: c_uint = mem.zeroes(c_uint),
        num_trace_bprintk_fmt: c_uint = mem.zeroes(c_uint),
        trace_bprintk_fmt_start: [*c][*c]const u8 = mem.zeroes([*c][*c]const u8),
        trace_events: [*c]?*linux.struct_trace_event_call_88 = mem.zeroes([*c]?*linux.struct_trace_event_call_88),
        num_trace_events: c_uint = mem.zeroes(c_uint),
        trace_evals: [*c]?*linux.struct_trace_eval_map_89 = mem.zeroes([*c]?*linux.struct_trace_eval_map_89),
        num_trace_evals: c_uint = mem.zeroes(c_uint),
        num_ftrace_callsites: c_uint = mem.zeroes(c_uint),
        ftrace_callsites: [*c]c_ulong = mem.zeroes([*c]c_ulong),
        kprobes_text_start: ?*anyopaque = mem.zeroes(?*anyopaque),
        kprobes_text_size: c_uint = mem.zeroes(c_uint),
        kprobe_blacklist: [*c]c_ulong = mem.zeroes([*c]c_ulong),
        num_kprobe_blacklist: c_uint = mem.zeroes(c_uint),
        num_static_call_sites: c_int = mem.zeroes(c_int),
        static_call_sites: [*c]linux.struct_static_call_site = mem.zeroes([*c]linux.struct_static_call_site),
        printk_index_size: c_uint = mem.zeroes(c_uint),
        printk_index_start: [*c][*c]linux.struct_pi_entry = mem.zeroes([*c][*c]linux.struct_pi_entry),
        source_list: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        target_list: linux.struct_list_head = mem.zeroes(linux.struct_list_head),
        exit: ?*const fn () callconv(.c) void = mem.zeroes(?*const fn () callconv(.c) void),
        refcnt: linux.atomic_t = mem.zeroes(linux.atomic_t),
        its_num_pages: c_int = mem.zeroes(c_int),
        its_page_array: [*c]?*anyopaque = mem.zeroes([*c]?*anyopaque),
        ei_funcs: [*c]linux.struct_error_injection_entry = mem.zeroes([*c]linux.struct_error_injection_entry),
        num_ei_funcs: c_uint = mem.zeroes(c_uint),
        // dyndbg_info: linux.struct__ddebug_info = mem.zeroes(linux.struct__ddebug_info),
    };
}.module;

pub fn makeModule(comptime name: []const u8, comptime init: fn () i32, comptime exit: fn () void) LinuxKernelModule {
    const fns = struct {
        fn initModule() callconv(.c) c_int {
            return @as(c_int, init());
        }

        fn cleanupModule() callconv(.c) void {
            exit();
        }
    };

    const module: LinuxKernelModule = .{
        .name = (name ++ [_]u8{0} ** (56 - name.len)).*,
        .init = fns.initModule,
        .exit = fns.cleanupModule,
        .arch = .{},
    };
    @export(&fns.initModule, .{ .name = "init_module", .section = ".init.text" });
    @export(&fns.cleanupModule, .{ .name = "cleanup_module", .section = ".exit.text" });
    @export(&module, .{ .name = "__this_module", .section = ".gnu.linkonce.this_module" });
    return module;
}

pub fn moduleInfo(comptime tag: []const u8, comptime info: []const u8) void {
    const c = (tag ++ "=" ++ info ++ "").*;
    @export(&c, .{ .name = "__UNIQUE_ID_" ++ tag, .section = ".modinfo" });
}
