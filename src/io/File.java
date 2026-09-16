package io;

import platform.Native;

public class File {
    public static int open(String path, int mode) {
        byte[] dosPath = toDosPath(path);
        int pathAddr = Native.memptr(dosPath) + 2;

        int[] regs = new int[] { 0x3D00 | (mode & 3), 0, 0, pathAddr, 0, 0, 0, 0 };
        regs = Native.int86(0x21, regs);

        if ((regs[7] & 1) != 0) {
            return -1;
        }

        return regs[0];
    }

    public static int create(String path) {
        byte[] dosPath = toDosPath(path);
        int pathAddr = Native.memptr(dosPath) + 2;

        int[] regs = new int[] { 0x3C00, 0, 0, pathAddr, 0, 0, 0, 0 };
        regs = Native.int86(0x21, regs);

        if ((regs[7] & 1) != 0) {
            return -1;
        }

        return regs[0];
    }

    public static void close(int handle) {
        if (handle < 0) {
            return;
        }

        int[] regs = new int[] { 0x3E00, handle, 0, 0, 0, 0, 0, 0 };
        Native.int86(0x21, regs);
    }

    public static int read(int handle, byte[] buffer, int offset, int length) {
        if (handle < 0) {
            return -1;
        }

        int bufAddr = Native.memptr(buffer) + 2 + offset;
        int[] regs = new int[] { 0x3F00, handle, length, bufAddr, 0, 0, 0, 0 };
        regs = Native.int86(0x21, regs);

        if ((regs[7] & 1) != 0) {
            return -1;
        }

        return regs[0];
    }

    public static int readBytes(int handle, byte[] buffer) {
        return read(handle, buffer, 0, buffer.length);
    }

    public static int write(int handle, byte[] buffer, int offset, int length) {
        if (handle < 0) {
            return -1;
        }

        int bufAddr = Native.memptr(buffer) + 2 + offset;
        int[] regs = new int[] { 0x4000, handle, length, bufAddr, 0, 0, 0, 0 };
        regs = Native.int86(0x21, regs);

        if ((regs[7] & 1) != 0) {
            return -1;
        }

        return regs[0];
    }

    public static int seek(int handle, int origin, int offset) {
        if (handle < 0) {
            return -1;
        }

        int[] regs = new int[] { 0x4200 | (origin & 3), handle, 0, offset, 0, 0, 0, 0 };
        regs = Native.int86(0x21, regs);

        if ((regs[7] & 1) != 0) {
            return -1;
        }

        return regs[0];
    }

    public static int lof(int handle) {
        if (handle < 0) {
            return -1;
        }

        int currentPos = seek(handle, 1, 0);
        int size = seek(handle, 2, 0);
        seek(handle, 0, currentPos);

        return size;
    }

    public static byte[] toDosPath(String path) {
        byte[] b = Native.getBytes(path);
        byte[] dosPath = new byte[b.length + 1];

        for (int i = 0; i < b.length; i++) {
            dosPath[i] = b[i];
        }

        dosPath[b.length] = 0;

        return dosPath;
    }
}