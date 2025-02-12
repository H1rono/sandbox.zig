const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("dirent.h");
});

/// https://manpages.debian.org/bookworm/manpages-dev/write.2.en.html#ERRORS
const WriteError = error{
    Again, // EAGAIN
    WouldBlock, // EWOULDBLOCK
    BadF, // EBADF
    DestAddrEq, // EDESTADDRREQ
    Dquot, // EDQUOT
    Fault, // EFAULT
    Fbig, // EFBIG
    Intr, // EINTR
    Inval, // EINVAL
    Io, // EIO
    NoSpc, // ENOSPC
    Perm, // EPERM
    Pipe, // EPIPE
};

/// https://manpages.debian.org/bookworm/freebsd-manpages/getdirentries.2freebsd.en.html#ERRORS
const DirectoryError = error{
    BadF, // EBADF
    Fault, // EFAULT
    Inval, // EINVAL
    Io, // EIO
    Integrity, // EINTEGRITY
};

/// https://manpages.debian.org/bookworm/manpages-dev/write.2.en.html#ERRORS
const OpenError = error{
    NotDir, // ENOTDIR
    NameTooLong, // ENAMETOOLONG
    NoEnt, // ENOENT
    Acces, // EACCES
    Perm, // EPERM
    Loop, // ELOOP
    IsDir, // EISDIR
    RoFs, // EROFS
    MFile, // EMFILE
    NFile, // ENFILE
    MLink, // EMLINK
    NxIo, // ENXIO
    Intr, // EINTR
    OpNotSupp, // EOPNOTSUPP
    WouldBlock, // EWOULDBLOCK
    NoSpc, // ENOSPC
    Dquot, // EDQUOT
    Io, // EIO
    Integrity, // EINTEGRITY
    TxtBsy, // ETXTBSY
    Fault, // EFAULT
    Exist, // EEXIST
    Inval, // EINVAL
    BadF, // EBADF
    CapMode, // ECAPMODE
    NotCapable, // ENOTCAPABLE
};

/// https://manpages.debian.org/bookworm/freebsd-manpages/close.2freebsd.en.html#ERRORS
const CloseError = error{
    BadF, // EBADF
    Intr, // EINTR
    NoSpc, // ENOSPC
    ConnReset, // ECONNRESET
};

const IoError = WriteError || DirectoryError || OpenError || CloseError;

fn fromErrno(e: std.c.E) IoError!void {
    if (e == .SUCCESS) return;
    std.debug.print("Received errno: {}\n", .{e});
    switch (e) {
        .AGAIN => return error.Again,
        .BADF => return error.BadF,
        .DESTADDRREQ => return error.DestAddrEq,
        .DQUOT => return error.Dquot,
        .FAULT => return error.Fault,
        .FBIG => return error.Fbig,
        .INTR => return error.Intr,
        .INVAL => return error.Inval,
        .IO => return error.Io,
        .NOSPC => return error.NoSpc,
        .PERM => return error.Perm,
        .PIPE => return error.Pipe,
        .NOTDIR => return error.NotDir,
        .NAMETOOLONG => return error.NameTooLong,
        .NOENT => return error.NoEnt,
        .ACCES => return error.Acces,
        .LOOP => return error.Loop,
        .ISDIR => return error.IsDir,
        .ROFS => return error.RoFs,
        .MFILE => return error.MFile,
        .NFILE => return error.NFile,
        .MLINK => return error.MLink,
        .NXIO => return error.NxIo,
        .OPNOTSUPP => return error.OpNotSupp,
        .TXTBSY => return error.TxtBsy,
        .EXIST => return error.Exist,
        .CONNRESET => return error.ConnReset,
        else => {
            if (builtin.os.tag == .linux) {
                return switch (e) {
                    .WOULD_BLOCK => error.WouldBlock,
                    .INTEGRITY => error.Integrity,
                    .CAPMODE => return error.CapMode,
                    .NOTCAPABLE => return error.NotCapable,
                    else => error.Inval,
                };
            } else {
                return error.Inval;
            }
        },
    }
}

fn errno() IoError!void {
    const e = std.posix.errno(-1);
    return fromErrno(e);
}

const allocator = std.heap.page_allocator;

fn writeStdout(buf: []const u8) void {
    const ptr = &buf[0];
    const size = c.write(1, ptr, buf.len);
    if (size < 0) {
        const err = std.c._errno().*;
        std.debug.panic("writing to stdout failed with errno {d}\n", .{err});
    }
}

fn writeStderr(buf: []const u8) void {
    const ptr = &buf[0];
    const size = c.write(2, ptr, buf.len);
    if (size < 0) {
        const err = std.c._errno().*;
        std.debug.panic("writing to stderr failed with errno {d}\n", .{err});
    }
}

pub fn main() anyerror!void {
    var argDir: ?[]const u8 = null;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    for (0..2) |i| {
        const arg = args.next() orelse break;
        if (i == 1) {
            argDir = arg;
            break;
        }
    }
    const dir = argDir orelse {
        writeStderr("Usage: tiny-ls <directory>\n");
        std.process.exit(1);
    };

    const message = try std.fmt.allocPrint(allocator, "Directory: {s}\n", .{dir});
    defer allocator.free(message);
    writeStdout(message);
}
