package driver;

import platform.Native;
import ui.BMP;

public class Mouse {
    public static void main(String[] args) {
        if (0 == detect()) {
            Native.print("No mouse detected\r\n");
            return;
        }

        int oldX = 9999;
        int oldY = 9999;

        int[] bmp = BMP.open("CURSOR.BMP");
        int cursorWidth = bmp[1];
        int cursorHeight = bmp[2];

        int cursorSize = cursorWidth * cursorHeight;
        byte[] mask = new byte[cursorSize];
        getMask(mask, cursorWidth, 0, 0);


        byte[] cursor = new byte[cursorSize];
        // Load whole BMP as cursor
        BMP.copy(bmp, cursor, cursorWidth, 0, 0, cursorWidth, 0, 0, cursorHeight);
        BMP.close(bmp);

        while (true) {
            int newX = x();
            int newY = y();

            if (newX == oldX) {
                if (newY == oldY) {
                    continue;
                }
            }

            drawCursor(cursor, cursorWidth, newX, newY, mask, oldX, oldY);

            oldX = newX;
            oldY = newY;
        }
    }

    /**
     * Installs/detects mouse and returns number of buttons, returns 0 if not mouse
     */
    public static int detect() {
        int[] regs = { 0, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        return regs[1];
    }

    public static int button() {
        int[] regs = { 0x3, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        return regs[1];
    }

    public static int x() {
        int[] regs = { 0x3, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        return regs[2];
    }

    public static int y() {
        int[] regs = { 0x3, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        return regs[3];
    }

    public static boolean down(int[] coords) {
        int[] regs = { 0x5, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        int x = regs[2];
        if (x < coords[0]) {
            return false;
        }

        int y = regs[3];
        if (y < coords[1]) {
            return false;
        }

        if (x > coords[0] + coords[2]) {
            return false;
        }

        if (y > coords[1] + coords[3]) {
            return false;
        }

        return regs[1] > 0;
    }

    public static boolean up(int[] coords) {
        int[] regs = { 0x6, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        int x = regs[2];
        if (x < coords[0]) {
            return false;
        }

        int y = regs[3];
        if (y < coords[1]) {
            return false;
        }

        if (x > coords[0] + coords[2]) {
            return false;
        }

        if (y > coords[1] + coords[3]) {
            return false;
        }

        return regs[1] > 0;
    }

    public static boolean click(int[] coords) {
        int[] regs = { 0x3, 0, 0, 0, 0, 0, 0, 0 };
        regs = Native.int86(0x33, regs);

        int x = regs[2];
        if (x < coords[0]) {
            return false;
        }

        int y = regs[3];
        if (y < coords[1]) {
            return false;
        }

        if (x > coords[0] + coords[2]) {
            return false;
        }

        if (y > coords[1] + coords[3]) {
            return false;
        }

        return regs[1] > 0;
    }

    public static void drawCursor(byte[] cursor, int w, int x, int y, byte[] mask, int oldX, int oldY) {
        int screenWidth = 320;

        int offsetX = 0;
        int maskOffsetX = 0;

        if (oldX == 9999) {
            oldX = 0;
        }

        if (oldY == 9999) {
            oldY = 0;
        }

        maskOffsetX = oldX + (oldY * screenWidth);
        Native.farmemsetb(mask, 0xa0, 0x00, maskOffsetX, w, screenWidth, -1);

        offsetX = x + (y * screenWidth);
        Native.farmemgetb(mask, 0xa0, 0x00, offsetX, w, screenWidth);
        Native.farmemsetb(cursor, 0xa0, 0x00, offsetX, w, screenWidth, 5);
    }

    public static void drawMask(byte[] mask, int w, int x, int y) {
        int screenWidth = 320;

        int offsetX = x + (y  * screenWidth);
        Native.farmemsetb(mask, 0xa0, 0x00, offsetX, w, screenWidth, 0);
    }

    public static void getMask(byte[] mask, int w, int x, int y) {
        int screenWidth = 320;

        int offsetX = x + (y * screenWidth);
        Native.farmemgetb(mask, 0xa0, 0x00, offsetX, w, screenWidth);
    }
}
