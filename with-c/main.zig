const c = @cImport({
    @cInclude("unistd.h");
});

pub fn main() void {
    const buf = "Hello, world!\n";
    _ = c.write(1, buf, buf.len);
}
