package ui;

import platform.Native;

public class UI {
    public static void create() {
        int[] regs = { 0x0013, 0, 0, 0, 0, 0, 0, 0 };
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
        if (x >= 320) {
            return;
        }

        int y2 = y + h;
        if (y2 >= 200) {
            y2 = 199;
        }

        for (int y1 = y; y1 < y2; y1++) {
            int offset = x + (y1 * 320);

            Native.farmemsetb(color, 0xa0, 0x00, offset, 1);
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
