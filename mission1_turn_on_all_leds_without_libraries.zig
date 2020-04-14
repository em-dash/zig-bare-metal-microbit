fn main() callconv(.C) noreturn {
    turnOnAllLeds: {
        const gpio_direction_set = @intToPtr(*volatile u32, 0x50000518);
        const gpio_out_clear = @intToPtr(*volatile u32, 0x5000050c);
        const gpio_out_set = @intToPtr(*volatile u32, 0x50000508);
        const all_three_led_anode_pins_active_high: u32 = 0xe000;
        const all_nine_led_cathode_pins_active_low: u32 = 0x1ff0;
        gpio_direction_set.* = all_three_led_anode_pins_active_high | all_nine_led_cathode_pins_active_low;
        gpio_out_set.* = all_three_led_anode_pins_active_high;
        gpio_out_clear.* = all_nine_led_cathode_pins_active_low;
    }
    while (true) {}
}

pub fn panic(message: []const u8, trace: ?*@import("std").builtin.StackTrace) noreturn {
    while (true) {}
}

pub const mission_number: u32 = 1;

const initial_sp = @intToPtr(fn () callconv(.C) noreturn, 0x20004000);
pub const vector_table linksection(".vector_table") = [1 + 1]fn () callconv(.C) noreturn{
    initial_sp, main,
};

comptime {
    @export(vector_table, .{ .name = "vector_table_mission1" });
    if (@import("root").mission_number == mission_number) {
        @export(__sync_lock_test_and_set_4, .{ .name = "__sync_lock_test_and_set_4" });
    }
}

fn __sync_lock_test_and_set_4(ptr: *u32, val: u32) callconv(.C) u32 {
    // disable the IRQ
    const old_val = ptr.*;
    ptr.* = val;
    // enable the IRQ
    return old_val;
}