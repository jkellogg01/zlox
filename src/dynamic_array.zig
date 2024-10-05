const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn DynamicArray(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T,
        cap: usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return .{
                .items = &[_]T{},
                .cap = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.allocatedSlice());
        }

        pub fn write(self: *Self, value: T) Allocator.Error!void {
            if (self.cap < self.items.len + 1) {
                try self.grow();
            }

            self.items.len += 1;
            self.items[self.items.len - 1] = value;
        }

        fn grow(self: *Self) Allocator.Error!void {
            const new_cap: usize = if (self.cap >= 8) self.cap * 2 else 8;
            if (self.allocator.resize(self.items, new_cap)) {
                self.cap = new_cap;
            } else {
                const new_mem = try self.allocator.alloc(T, new_cap);
                @memcpy(new_mem[0..self.items.len], self.items);
                self.items.ptr = new_mem.ptr;
                self.cap = new_mem.len;
            }
        }

        fn allocatedSlice(self: Self) []T {
            return self.items.ptr[0..self.cap];
        }
    };
}

test "dynamic array grow" {
    const IntArray = DynamicArray(u32);
    const allocator = std.testing.allocator;
    var int_array = IntArray.init(allocator);
    defer int_array.deinit();

    try int_array.write(69);
    std.debug.assert(int_array.items.len == 1);
    std.debug.assert(int_array.cap == 8);
    try int_array.write(420);
    std.debug.assert(int_array.items.len == 2);
    std.debug.assert(int_array.cap == 8);
}
