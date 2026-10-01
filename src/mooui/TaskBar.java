package mooui;

import platform.Native;
import ui.Button;
import ui.Menu;
import ui.UI;

public class TaskBar {
    public static int[] draw(int x, int y, int w, int h, int[] font) {
        int[] taskbar = Button.draw(x, y, w, h);

        // Start button
        int[] startButton = startButton(taskbar);
        Button.draw(startButton[0], startButton[1], startButton[2], startButton[3]);
        UI.drawString("Start", x + 8, y + 5, font, true);

        // Start menu
        int[] startMenu = startMenu(taskbar);
        maskStartMenu(startMenu);

        return taskbar;
    }

    public static int[] startButton(int[] taskbar) {
        return new int[] { taskbar[0] + 2, taskbar[1] + 2, 40, taskbar[3] - 4 };
    }

    public static int[] startMenu(int[] taskbar) {
        return new int[] { taskbar[0], taskbar[1] - 75, 75, 75 };
    }

    public static int[] shutdownMenu(int[] startMenu) {
        return new int[] { startMenu[0] + 5, startMenu[1] + 5, 65, 20 };
    }

    public static byte[] maskStartMenu(int[] startMenu) {
        int screenWidth = 320;
        int startMenuSize = startMenu[2] * startMenu[3];
        byte[] mask = new byte[startMenuSize];
        int offsetX = startMenu[0] + (startMenu[1] * screenWidth);
        Native.farmemgetb(mask, 0xa0, 0x00, offsetX, startMenu[2], screenWidth);

        return mask;
    }

    public static void hideStartMenu(int[] startMenu, byte[] mask) {
        int screenWidth = 320;
        int offsetX = startMenu[0] + (startMenu[1] * screenWidth);
        Native.farmemsetb(mask, 0xa0, 0x00, offsetX, startMenu[2], screenWidth, 0);
    }

    public static void showStartMenu(int[] startMenu, int[] font) {
        Menu.draw(startMenu[0], startMenu[1], startMenu[2], startMenu[3]);
        int[] shutdownMenu = shutdownMenu(startMenu);
        UI.drawString("Shutdown", shutdownMenu[0] + 4, shutdownMenu[1] + 2, font, true);
    }

    public static void toggleStartMenu(int[] startMenu, byte[] mask, int[] font, boolean show) {
        if (show) {
            showStartMenu(startMenu, font);
        } else {
            hideStartMenu(startMenu, mask);
        }
    }
}
