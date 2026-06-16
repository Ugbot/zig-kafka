//! Zig 0.16 compatibility shims.
//!
//! Some host toolchains ship a stripped std without `std.time.milliTimestamp`.
//! This provides a drop-in using `clock_gettime(CLOCK_REALTIME)`, wired into
//! the SDK as the module-wide named import `ztime` so call sites read
//! `@import("ztime").milliTimestamp()` regardless of their directory depth.

const std = @import("std");

/// Wall-clock milliseconds since the Unix epoch.
pub fn milliTimestamp() i64 {
    var ts: std.c.timespec = undefined;
    _ = std.c.clock_gettime(std.c.CLOCK.REALTIME, &ts);
    return @as(i64, @intCast(ts.sec)) * 1000 + @divTrunc(@as(i64, @intCast(ts.nsec)), 1_000_000);
}

/// `std.Thread.sleep` shim.
///
/// `std.Thread.sleep` is absent from this stripped std. Sleep for `nanoseconds`
/// via libc `nanosleep`, restarting on EINTR so a signal can't shorten the
/// wait. Used by the producer/consumer poll loops for their inter-iteration
/// backoff.
pub fn sleepNs(nanoseconds: u64) void {
    var req: std.c.timespec = .{
        .sec = @intCast(nanoseconds / std.time.ns_per_s),
        .nsec = @intCast(nanoseconds % std.time.ns_per_s),
    };
    var rem: std.c.timespec = undefined;
    while (true) {
        const rc = std.c.nanosleep(&req, &rem);
        if (rc == 0) break;
        // Interrupted (EINTR): finish the remaining time; otherwise give up.
        if (std.c.errno(rc) != .INTR) break;
        req = rem;
    }
}

/// `std.io.fixedBufferStream` shim.
///
/// This stripped Zig 0.16 std has neither `std.io` nor `std.io.FixedBufferStream`
/// (the new I/O lives under `std.Io` with a different `Reader`/`Writer` model).
/// The SDK's generated codecs are written against the classic
/// fixed-buffer-stream API: a value-type stream exposing `.pos`, `.reader()`,
/// and `.writer()` whose reader/writer carry the old method set
/// (`readInt`/`readByte`/`readAll`/`readNoEof`/`skipBytes` and
/// `writeInt`/`writeByte`/`writeAll`). All codec entry points take `anytype`
/// writers/readers, so a duck-typed reimplementation slots in unchanged.
///
/// Tiger Style: no allocation — the stream is a thin cursor over a
/// caller-owned slice. Reader/writer are zero-cost views holding a pointer
/// back to the stream's `pos`.
pub fn fixedBufferStream(buffer: anytype) FixedBufferStream(@TypeOf(buffer)) {
    return .{ .buffer = buffer, .pos = 0 };
}

pub fn FixedBufferStream(comptime Buffer: type) type {
    // Buffer is either []u8 (read+write) or []const u8 (read only).
    return struct {
        const Self = @This();

        buffer: Buffer,
        pos: usize,

        pub const ReadError = error{};
        pub const WriteError = error{NoSpaceLeft};

        pub const Reader = struct {
            stream: *Self,

            /// Read up to `dest.len` bytes; returns the number read (0 at EOF).
            pub fn readAll(self: Reader, dest: []u8) ReadError!usize {
                const s = self.stream;
                const remaining = s.buffer.len - s.pos;
                const n = @min(remaining, dest.len);
                @memcpy(dest[0..n], s.buffer[s.pos .. s.pos + n]);
                s.pos += n;
                return n;
            }

            /// Read exactly `dest.len` bytes or error.
            pub fn readNoEof(self: Reader, dest: []u8) error{EndOfStream}!void {
                const n = self.readAll(dest) catch unreachable;
                if (n != dest.len) return error.EndOfStream;
            }

            pub fn readByte(self: Reader) error{EndOfStream}!u8 {
                const s = self.stream;
                if (s.pos >= s.buffer.len) return error.EndOfStream;
                const b = s.buffer[s.pos];
                s.pos += 1;
                return b;
            }

            pub fn readInt(self: Reader, comptime T: type, endian: std.builtin.Endian) error{EndOfStream}!T {
                const n = @divExact(@typeInfo(T).int.bits, 8);
                var tmp: [n]u8 = undefined;
                try self.readNoEof(&tmp);
                return std.mem.readInt(T, &tmp, endian);
            }

            /// Advance the cursor by `num_bytes`. `options` matches the old
            /// std signature (`.{}`); only the count is used.
            pub fn skipBytes(self: Reader, num_bytes: u64, comptime options: anytype) error{EndOfStream}!void {
                _ = options;
                const s = self.stream;
                const n: usize = @intCast(num_bytes);
                if (s.pos + n > s.buffer.len) return error.EndOfStream;
                s.pos += n;
            }
        };

        pub const Writer = struct {
            stream: *Self,

            pub fn writeAll(self: Writer, bytes: []const u8) WriteError!void {
                const s = self.stream;
                if (s.pos + bytes.len > s.buffer.len) return error.NoSpaceLeft;
                @memcpy(s.buffer[s.pos .. s.pos + bytes.len], bytes);
                s.pos += bytes.len;
            }

            pub fn writeByte(self: Writer, byte: u8) WriteError!void {
                const s = self.stream;
                if (s.pos >= s.buffer.len) return error.NoSpaceLeft;
                s.buffer[s.pos] = byte;
                s.pos += 1;
            }

            pub fn writeInt(self: Writer, comptime T: type, value: T, endian: std.builtin.Endian) WriteError!void {
                const n = @divExact(@typeInfo(T).int.bits, 8);
                var tmp: [n]u8 = undefined;
                std.mem.writeInt(T, &tmp, value, endian);
                try self.writeAll(&tmp);
            }
        };

        pub fn reader(self: *Self) Reader {
            return .{ .stream = self };
        }

        pub fn writer(self: *Self) Writer {
            return .{ .stream = self };
        }

        /// Bytes written/consumed so far (the classic `getWritten`/`getRead`).
        pub fn getWritten(self: *const Self) Buffer {
            return self.buffer[0..self.pos];
        }
    };
}
