const linux = @import("linux.zig");

fn hello() i32 {
    linux.printk("hello\n", .{});
    return 0;
}

fn bye() void {
    linux.printk("bye\n", .{});
}

comptime {
    _ = linux.makeModule("zigmodule", hello, bye);
    linux.moduleInfo("name", "zigmodule");
    linux.moduleInfo("license", "GPL");
    linux.moduleInfo("author", "Michał Garapich");
    linux.moduleInfo("description", "Writing linux kernel module in zig");
    linux.moduleInfo("version", "0.0.0");
}
