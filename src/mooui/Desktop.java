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
        int[] startMenu = TaskBar.startMenu(taskbar);
        int[] shutdownMenu = TaskBar.shutdownMenu(startMenu);
        byte[] maskStartMenu = TaskBar.maskStartMenu(startMenu);
        TaskBar.hideStartMenu(startMenu, maskStartMenu);

        int mouse = Native.newProcess("driver/Mouse");
        int button = 0;
        int prevButton = 0;
        boolean startMenuOpen = false;
        boolean shutdownMenuDown = false;

        while (true) {
            button = Mouse.button();
            if (1 == button) {
                shutdownMenuDown = Button.mousedown(shutdownMenu);
                if (Button.mousedown(startButton)) {
                    shutdownMenuDown = false;
                    Button.state(startButton, true);
                }
            }
            if (Mouse.pressed(prevButton)) {
                prevButton = 0;
                Button.state(startButton, false);
                if (Button.mouseup(startButton)) {
                    if (!startMenuOpen) {
                        startMenuOpen = true;
                        shutdownMenuDown = false;
                        TaskBar.showStartMenu(startMenu);
                    } else {
                        startMenuOpen = false;
                        shutdownMenuDown = false;
                        TaskBar.hideStartMenu(startMenu, maskStartMenu);
                    }
                }
                if (startMenuOpen && shutdownMenuDown && Button.mouseup(shutdownMenu)) {
                    shutdownMenuDown = false;
                    Native.killProcess(mouse);
                    break;
                }
            }
            prevButton = button;
        }

        UI.destroy();
    }
}
