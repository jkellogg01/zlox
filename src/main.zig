const std = @import("std");
const bytecode = @import("./bytecode.zig");
const debug = @import("./debug.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var chunk = bytecode.Chunk.init(allocator);
    defer chunk.deinit();

    try chunk.write(bytecode.OpCode.op_return);

    var disassembler = debug.Disassembler.init(chunk, "test chunk");
    disassembler.disassemble();
}
