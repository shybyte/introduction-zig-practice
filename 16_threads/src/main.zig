const std = @import("std");
const Thread = std.Thread;
const Pool = std.Thread.Pool;
const Mutex = std.Thread.Mutex;
const RwLock = std.Thread.RwLock;

pub fn main() !void {
    std.log.debug("Chapter 16 Threads", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // try basicStuff();

    // 16.5 Thread pools
    {
        const opt = Pool.Options{
            .n_jobs = 4,
            .allocator = allocator,
        };
        var pool: Pool = undefined;
        try pool.init(opt);
        defer pool.deinit();

        const id1: u8 = 1;
        const id2: u8 = 2;
        try pool.spawn(print_id_pool, .{&id1});
        try pool.spawn(print_id_pool, .{&id2});
    }

    // 16.6.3 Data races and race conditions
    {
        const thr1 = try Thread.spawn(.{}, increment, .{});
        const thr2 = try Thread.spawn(.{}, increment, .{});
        thr1.join();
        thr2.join();
        std.log.debug("Couter value: {d}\n", .{counter});
    }

    // 16.6.4 Using mutexes in Zig
    {
        var mutex: Mutex = .{};
        const thr1 = try Thread.spawn(.{}, incrementWithMutex, .{&mutex});
        const thr2 = try Thread.spawn(.{}, incrementWithMutex, .{&mutex});
        thr1.join();
        thr2.join();
        std.log.debug("Couter value: {d}\n", .{counter_with_mutex});
    }

    // 16.7.2 Using read/write locks in Zig
    {
        var lock: RwLock = .{};
        const thr1 = try Thread.spawn(.{}, reader, .{&lock});
        const thr2 = try Thread.spawn(.{}, reader, .{&lock});
        const thr3 = try Thread.spawn(.{}, reader, .{&lock});
        const wthread = try Thread.spawn(.{}, writer, .{&lock});

        thr1.join();
        thr2.join();
        thr3.join();
        wthread.join();
    }

    // 16.9.3 Cancelling or killing a particular thread
    {
        std.log.debug("\nCancelling or killing a particular thread...", .{});
        const thread = try Thread.spawn(.{}, work, .{});
        std.Thread.sleep(500 * std.time.ns_per_ms);

        std.log.debug("Stopping thread", .{});
        running.store(false, .monotonic);

        thread.join();
    }

    std.log.debug("main finished", .{});
}

fn print_id_pool(id: *const u8) void {
    std.log.debug("Starting the work Thread ID: {d}\n", .{id.*});
    std.Thread.sleep(1000 * std.time.ns_per_ms);
    std.log.debug("Finishing the work {d}.\n", .{id.*});
}

var counter: usize = 0;

fn increment() void {
    for (0..100000) |_| {
        counter += 1;
    }
}

var counter_with_mutex: usize = 0;

fn incrementWithMutex(mutex: *Mutex) void {
    for (0..100000) |_| {
        mutex.lock();
        counter_with_mutex += 1;
        mutex.unlock();
    }
}

// 16.7.2 Using read/write locks in Zig

var counter_rw: u32 = 0;

fn reader(lock: *RwLock) !void {
    for (0..3) |_| {
        lock.lockShared();
        const v: u32 = counter_rw;
        std.log.debug("{d}", .{v});
        lock.unlockShared();
        std.Thread.sleep(10 * std.time.ns_per_ms);
    }
}

fn writer(lock: *RwLock) void {
    for (0..3) |_| {
        lock.lock();
        counter_rw += 1;
        lock.unlock();
        std.Thread.sleep(10 * std.time.ns_per_ms);
    }
}

// 16.9.3 Cancelling or killing a particular thread
var running = std.atomic.Value(bool).init(true);
var counter_cancel: u64 = 0;

fn do_more_work() void {
    std.log.debug("Do more work {}", .{counter_cancel});
    counter_cancel += 10;
    std.Thread.sleep(100 * std.time.ns_per_ms);
    std.log.debug("Increased counter to  {}", .{counter_cancel});
}

fn work() !void {
    std.log.debug("Starting to work...", .{});
    while (running.load(.monotonic) and counter_cancel < 15000) {
        do_more_work();
    }
    std.log.debug("Finished work.", .{});
}

// Basic Stuff

fn basicStuff() !void {
    // 16.3 Creating a thread
    {
        const thread = try Thread.spawn(.{}, do_some_work, .{});
        thread.join();
    }

    // 16.4.1 Joining a thread
    {
        const id1: u8 = 1;
        const id2: u8 = 2;
        const thread1 = try Thread.spawn(.{}, print_id, .{&id1});
        const thread2 = try Thread.spawn(.{}, print_id, .{&id2});

        std.log.debug("Joining thread 1\n");
        thread1.join();
        std.Thread.sleep(1 * std.time.ns_per_s);
        std.log.debug("Joining thread 2\n");
        thread2.join();
    }

    // 16.4.2 Detaching a thread
    {
        const id1: u8 = 10;
        const thread1 = try Thread.spawn(.{}, print_id, .{&id1});
        thread1.detach();
        // std.Thread.sleep(100 * std.time.ns_per_ms);
    }
}

fn do_some_work() !void {
    std.log.debug("Starting the work.\n");
    std.Thread.sleep(100 * std.time.ns_per_ms);
    std.log.debug("Finishing the work.\n");
}

fn print_id(id: *const u8) !void {
    _ = std.log.debug("Starting the work Thread ID: {d}\n", .{id.*});
    std.Thread.sleep(1000 * std.time.ns_per_ms);
    _ = std.log.debug("Finishing the work {d}.\n", .{id.*});
}
