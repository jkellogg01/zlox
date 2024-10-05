const std = @import("std");
const DynamicArray = @import("./dynamic_array.zig").DynamicArray;
const ValueArray = @import("./value.zig").ValueArray;
const Value = @import("./value.zig").Value;

pub const OpCode = enum(u8) {
    op_constant,
    op_return,
    _,
};

pub const Chunk = struct {
    const Self = @This();

    code: DynamicArray(u8),
    constants: ValueArray,

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return .{
            .code = DynamicArray(u8).init(allocator),
            .constants = ValueArray.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.code.deinit();
        self.constants.deinit();
    }

    pub fn write(self: *Self, byte: u8) !void {
        try self.code.write(byte);
    }

    pub fn addConstant(self: *Self, constant: Value) !usize {
        try self.constants.write(constant);
        return self.constants.items.len - 1;
    }
};
