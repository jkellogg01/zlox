const std = @import("std");
const Allocator = std.mem.Allocator;

pub const OpCode = enum(u8) {
    op_return,
};

pub const Chunk = struct {
    code: std.ArrayList(OpCode),

    pub fn init(allocator: Allocator) Chunk {
        const OpCodeArrayList = std.ArrayList(OpCode);
        return .{ .code = OpCodeArrayList.init(allocator) };
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
    }

    pub fn write(self: *Chunk, code: OpCode) Allocator.Error!void {
        return self.code.append(code);
    }
};
