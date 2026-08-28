package driver;

import platform.Native;
import ui.UI;

public class Mouse {
    public static void main(String[] args) {
        if (0 == detect()) {
            Native.print("No mouse detected\r\n");
            return;
        }

        Native.print("Click anywhere to quit\r\n");

        int oldX = 9999;
        int oldY = 9999;
        int oldColor = 999;

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

            if (oldColor != 999) {
                UI.putPixel(oldX, oldY, oldColor);
            }
            oldColor = UI.getPixel(newX, newY);

            UI.putPixel(newX, newY, 15);

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
}
