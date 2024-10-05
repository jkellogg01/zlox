const std = @import("std");
const Allocator = std.mem.Allocator;
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
    lines: LineInformation,

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return .{
            .code = DynamicArray(u8).init(allocator),
            .constants = ValueArray.init(allocator),
            .lines = LineInformation.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.code.deinit();
        self.constants.deinit();
        self.lines.deinit();
    }

    pub fn write(self: *Self, byte: u8, line: u32) !void {
        try self.code.write(byte);
        try self.lines.write(line);
    }

    pub fn addConstant(self: *Self, constant: Value) !usize {
        try self.constants.write(constant);
        return self.constants.items.len - 1;
    }
};

const LineInformation = struct {
    const Self = @This();

    head: ?*Node,
    tail: ?*Node,
    len: usize,
    allocator: Allocator,

    const Node = struct {
        number: u32,
        length: u32, // in bytes
        next: ?*Node,
    };

    pub fn init(allocator: Allocator) LineInformation {
        return .{
            .head = null,
            .tail = null,
            .len = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        var curr = self.head;
        while (curr) |node| : (curr = node.next) {
            defer self.allocator.destroy(node);
        }
    }

    pub fn write(self: *Self, line: u32) Allocator.Error!void {
        self.len += 1;
        if (self.tail == null) {
            const node = try self.allocator.create(Node);
            node.number = line;
            node.length = 1;
            node.next = null;
            self.head = node;
            self.tail = node;
            return;
        }

        var tail = self.tail.?;
        if (tail.number == line) {
            tail.length += 1;
            return;
        }
        const node = try self.allocator.create(Node);
        node.number = line;
        node.length = 1;
        node.next = null;
        tail.next = node;
        tail = node;
    }

    pub fn get(self: Self, operation: usize) ?u32 {
        if (operation >= self.len) {
            return null;
        }
        var curr = self.head;
        var offset: usize = 0;
        while (curr) |node| : (curr = node.next) {
            if (offset + node.length > operation) {
                return node.number;
            }
            offset += node.length;
        }
        return null;
    }
};
