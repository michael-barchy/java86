package mooui;

import driver.Mouse;
import platform.Native;
import ui.Button;
import ui.Font;
import ui.UI;

public class Desktop {
    public static void main(String[] args) {
        int screenWidth = 320;
        int screenHeight = 200;

        UI.create();
        UI.drawImage("CIRCUIT.BMP", 0, 0);

        int[] font = Font.open("SYSTEM12.BMP");

        int[] taskbar = TaskBar.draw(0, screenHeight - 24, screenWidth, 24, font);
        int[] startButton = TaskBar.startButton(taskbar);

        int[] startMenu = TaskBar.startMenu(taskbar);
        int[] shutdownMenu = TaskBar.shutdownMenu(startMenu);
        byte[] maskStartMenu = TaskBar.maskStartMenu(startMenu);
        TaskBar.hideStartMenu(startMenu, maskStartMenu);

        int mouse = Native.newProcess("driver/Mouse");
        boolean startMenuOpen = false;

        int button = 0;

        while (true) {
            button = Mouse.button();
            if (startMenuOpen) {
                if (Mouse.down(shutdownMenu)) {
                    Button.state(shutdownMenu, true); // @todo - menu state
                }
                if (Mouse.up(shutdownMenu)) {
                    break;
                }
            }
            if (Mouse.click(startButton) && 1 == button) {
                Button.state(startButton, !startMenuOpen);
                startMenuOpen = !startMenuOpen;
                TaskBar.toggleStartMenu(startMenu, maskStartMenu, font, startMenuOpen);
            }
        }

        Native.killProcess(mouse);
        Font.close(font);
        UI.destroy();
    }
}
