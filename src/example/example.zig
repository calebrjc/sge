const std = @import("std");
const sge = @import("sge");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("We leaked memory!");
    }

    sge.init(allocator);
    defer sge.deinit();

    try sge.run();
}
