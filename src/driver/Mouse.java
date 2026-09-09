package driver;

import platform.Native;

public class Mouse {
    public static void main(String[] args) {
        if (0 == detect()) {
            Native.print("No mouse detected\r\n");
            return;
        }

        Native.print("Click anywhere to quit\r\n");

        int oldX = 9999;
        int oldY = 9999;

        byte[] mask = new byte[96];
        getMask(mask, 0, 0);

        byte[] cursor = {
             0, -1, -1, -1, -1, -1, -1, -1,
             0,  0, -1, -1, -1, -1, -1, -1,
             0, 15,  0, -1, -1, -1, -1, -1,
             0, 15, 15,  0, -1, -1, -1, -1,
             0, 15, 15, 15,  0, -1, -1, -1,
             0, 15, 15, 15, 15,  0, -1, -1,
             0, 15, 15, 15, 15, 15,  0, -1,
             0, 15, 15, 15, 15, 15, 15,  0,
             0, 15, 15,  0,  0,  0,  0, -1,
             0, 15,  0, -1, -1, -1, -1, -1,
             0,  0, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1
        };

        while (true) {
            if (0 != button()) {
                break;
            }

            int newX = x();
            int newY = y();

            if (newX == oldX) {
                if (newY == oldY) {
                    continue;
                }
            }

            drawCursor(cursor, newX, newY, mask, oldX, oldY);

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

    public static void drawCursor(byte[] cursor, int x, int y, byte[] mask, int oldX, int oldY) {
        int screenWidth = 320;
        int cursorWidth = 8;

        int offsetX = 0;
        int maskOffsetX = 0;

        if (oldX == 9999) {
            oldX = 0;
        }

        if (oldY == 9999) {
            oldY = 0;
        }

        maskOffsetX = oldX + (oldY * screenWidth);
        Native.farmemsetb(mask, 0xa0, 0x00, maskOffsetX, cursorWidth, screenWidth, false);

        offsetX = x + (y * screenWidth);
        Native.farmemgetb(mask, 0xa0, 0x00, offsetX, cursorWidth, screenWidth);
        Native.farmemsetb(cursor, 0xa0, 0x00, offsetX, cursorWidth, screenWidth, true);
    }

    public static void drawMask(byte[] mask, int x, int y) {
        int screenWidth = 320;
        int maskWidth = 8;

        int offsetX = x + (y  * screenWidth);
        Native.farmemsetb(mask, 0xa0, 0x00, offsetX, maskWidth, screenWidth, false);
    }

    public static void getMask(byte[] mask, int x, int y) {
        int screenWidth = 320;
        int maskWidth = 8;

        int offsetX = x + (y * screenWidth);
        Native.farmemgetb(mask, 0xa0, 0x00, offsetX, maskWidth, screenWidth);
    }
}
