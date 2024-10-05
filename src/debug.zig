const std = @import("std");
const bytecode = @import("./bytecode.zig");
const OpCode = bytecode.OpCode;
const Value = @import("./value.zig").Value;

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

            const instruction: OpCode = @enumFromInt(self.chunk.code.items[offset]);
            offset = switch (instruction) {
                .op_constant => self.constantInstruction(instruction, offset),
                .op_return => simpleInstruction(instruction, offset),
                else => blk: {
                    std.debug.print("unknown opcode: {d}\n", .{instruction});
                    break :blk offset + 1;
                },
            };
        }
    }

    fn constantInstruction(self: Self, code: OpCode, offset: usize) usize {
        const constant = self.chunk.code.items[offset + 1];
        std.debug.print("{s: <16} {d: >4} '", .{ @tagName(code), constant });
        printValue(self.chunk.constants.items[constant]);
        std.debug.print("'\n", .{});
        return offset + 2;
    }

    fn simpleInstruction(code: OpCode, offset: usize) usize {
        std.debug.print("{s}\n", .{@tagName(code)});
        return offset + 1;
    }
};

fn printValue(value: Value) void {
    std.debug.print("{d}", .{value});
}
