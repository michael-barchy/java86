package mooui;

import driver.Mouse;
import platform.Native;
import ui.Button;
import ui.UI;

public class Desktop {
    public static void main(String[] args) {
        int screenWidth = 320;
        int screenHeight = 200;

        UI.create();
        UI.drawImage("CIRCUIT.BMP", 0, 0);

        int[] taskbar = TaskBar.draw(0, screenHeight - 24, screenWidth, 24);
        int[] startButton = TaskBar.startButton(taskbar);

        int mouse = Native.newProcess("driver/Mouse");
        int button = 0;
        int prevButton = 0;

        while (true) {
            button = Mouse.button();
            if (1 == button) {
                if (Button.mousedown(startButton)) {
                    Button.state(startButton, true);
                }
            }
            if (Mouse.pressed(prevButton)) {
                prevButton = 0;
                Button.state(startButton, false);
                if (Button.mouseup(startButton)) {
                    Native.killProcess(mouse);
                    break;
                }
            }
            prevButton = button;
        }

        UI.destroy();
    }
}
