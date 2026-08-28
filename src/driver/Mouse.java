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

        while (true) {
            if (0 != button()) {
                break;
            }
            UI.putPixel(x(), y(), 15);
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
