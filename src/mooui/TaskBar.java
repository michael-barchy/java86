package mooui;

import ui.Button;
import ui.UI;

public class TaskBar {
    public static int[] draw(int x, int y, int w, int h) {
        int[] taskbar = Button.draw(x, y, w, h);

        // Start button
        int[] startButton = startButton(taskbar);
        Button.draw(startButton[0], startButton[1], startButton[2], startButton[3]);
        UI.drawString("Start", x + 8, y + 5, "SYSTEM12.BMP");

        return taskbar;
    }

    public static int[] startButton(int[] taskbar) {
        return new int[] { taskbar[0] + 2, taskbar[1] + 2, 50, taskbar[3] - 4 };
    }
}
