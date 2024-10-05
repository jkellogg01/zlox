const std = @import("std");
const bytecode = @import("./bytecode.zig");
const OpCode = bytecode.OpCode;

pub const Disassembler = struct {
    const Self = @This();

    chunk: bytecode.Chunk,
    name: []const u8,

    pub fn init(chunk: bytecode.Chunk, name: []const u8) Self {
        return .{ .chunk = chunk, .name = name };
    }

    pub fn disassemble(self: Self) void {
        std.debug.print("== {s} ==\n", .{self.name});

        var offset: usize = 0;
        while (offset < self.chunk.code.items.len) {
            std.debug.print("{d:0>4} ", .{offset});

            const instruction = self.chunk.code.items[offset];
            offset = switch (instruction) {
                OpCode.op_return => simpleInstruction("RETURN", offset),
            };
        }
    }
};

fn simpleInstruction(name: []const u8, offset: usize) usize {
    std.debug.print("{s}\n", .{name});
    return offset + 1;
}
