const std = @import("std");
const bytecode = @import("./bytecode.zig");
const OpCode = bytecode.OpCode;
const debug = @import("./debug.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var chunk = bytecode.Chunk.init(allocator);
    defer chunk.deinit();

    const constant = try chunk.addConstant(1.2);
    try chunk.write(@intFromEnum(OpCode.op_constant));
    try chunk.write(@intCast(constant));

    try chunk.write(@intFromEnum(OpCode.op_return));

    var disassembler = debug.Disassembler.init(chunk, "test chunk");
    disassembler.disassemble();
}
