package ui;

import platform.Native;

public class UI {
    public static void create() {
        int[] regs = { 0x0013, 0, 0, 0, 0, 0, 0, 0 };
        Native.int86(0x10, regs);
    }

    public static void destroy() {
        int[] regs = { 0x0003, 0, 0, 0, 0, 0, 0, 0 };
        Native.int86(0x10, regs);
    }

    public static void putPixel(int x, int y, int color) {
        if (x >= 320) {
            return;
        }

        if (y >= 200) {
            return;
        }

        int offset = x + (y * 320);

        Native.farmemsetb(color, 0xa0, 0x00, offset, 1);
    }

    public static int getPixel(int x, int y) {
        if (x >= 320) {
            return 0;
        }

        if (y >= 200) {
            return 0;
        }

        int offset = x + (y * 320);

        return Native.farmemgetb(0xa0, 0x00, offset);
    }

    public static void hLine(int x, int y, int w, int color) {
        if (x >= 320) {
            x = 319;
        }

        if (y >= 200) {
            return;
        }

        int offset = x + (y * 320);
        if (x + w >= 320) {
            w = 319 - x;
        }

        Native.farmemsetb(color, 0xa0, 0x00, offset, w);
    }

    public static void vLine(int x, int y, int h, int color) {
        int screenWidth = 320;

        if (x >= screenWidth) {
            return;
        }

        int y2 = y + h;
        if (y2 >= screenWidth) {
            y2 = screenWidth - 1;
        }

        h = y2 - y;
        byte[] line = new byte[h];
        for (int i = 0; i < h; i++) {
            line[i] = (byte) color;
        }

        int offset = x + (y * screenWidth);
        Native.farmemsetb(line, 0xa0, 0x00, offset, 1, screenWidth, -1);
    }

    public static void drawLine(int x1, int y1, int x2, int y2, int color) {
        int screenWidth = 320;
        int screenHeight = 200;

        int dx = x2 - x1;
        int sx = 1;
        if (dx < 0) {
            dx = -dx;
            sx = -1;
        }

        int dy = y2 - y1;
        int sy = 1;
        if (dy < 0) {
            dy = -dy;
            sy = -1;
        }

        int err = dx - dy;

        while (true) {
            if (x1 >= 0 && x1 < screenWidth && y1 >= 0 && y1 < screenHeight) {
                int offset = (y1 * screenWidth) + x1;
                Native.farmemsetb(color, 0xa0, 0x00, offset, 1);
            }

            if (x1 == x2 && y1 == y2) {
                break;
            }

            int e2 = err * 2;

            if (e2 > -dy) {
                err = err - dy;
                x1 = x1 + sx;
            }

            if (e2 < dx) {
                err = err + dx;
                y1 = y1 + sy;
            }
        }
    }

    public static void fillRect(int x, int y, int w, int h, int color) {
        if (x >= 320) {
            x = 319;
        }

        if (y > 200) {
            return;
        }

        int y2 = y + h;
        if (y2 >= 200) {
            y2 = 199;
        }

        for (int y1 = y; y1 < y2; y1++) {
            int offset = x + (y1 * 320);

            Native.farmemsetb(color, 0xa0, 0x00, offset, w);
        }
    }

    public static void drawRect(int x, int y, int w, int h, int color) {
        if (x >= 320) {
            return;
        }

        if (y >= 200) {
            return;
        }

        int x2 = x + w;
        if (x2 >= 320) {
            w = 320 - x;
        }

        int y2 = y + h;
        if (y2 >= 200) {
            y2 = 199;
            h = 200 - y;
        }

        hLine(x, y, w, color);
        hLine(x, y2, w, color);
        vLine(x, y, h, color);
        vLine(x + w - 1, y, h, color);
    }
}
