package mooui;

import driver.Mouse;
import platform.Native;
import ui.Button;
import ui.MenuItem;
import ui.Font;
import ui.UI;
import util.StringUtils;

public class Desktop {
    public static void main(String[] args) {
        int screenWidth = 320;
        int screenHeight = 200;

        UI.create();
        UI.drawImage("PRAIRIE.BMP", 0, 0);

        int[] font = Font.open("SYSTEM12.BMP");

        int[] taskbar = TaskBar.draw(0, screenHeight - 24, screenWidth, 24, font);
        int[] startButton = TaskBar.startButton(taskbar);

        int[] startMenu = TaskBar.startMenu(taskbar);
        int[] shutdownMenu = TaskBar.shutdownMenu(startMenu, font);
        byte[] maskStartMenu = TaskBar.maskStartMenu(startMenu);
        TaskBar.hideStartMenu(startMenu, maskStartMenu);

        int mouse = Native.newProcess("driver/Mouse");
        boolean startMenuOpen = false;
        boolean shutdownMenuHover = false;

        int button = 0;
        int x = 0;
        int y = 0;

        int memPrev = Native.freemem(0) / 1000;
        showFreeMemory(screenWidth, screenHeight, font);

        while (true) {
            int mem = Native.freemem(0) / 1000;
            if (mem != memPrev) {
                showFreeMemory(screenWidth, screenHeight, font);
                memPrev = mem;
            }
            button = Mouse.button();
            if (startMenuOpen) {
                boolean mouseMove = Mouse.x() != x || Mouse.y() != y;
                x = Mouse.x();
                y = Mouse.y();
                if (!shutdownMenuHover && Mouse.enter(shutdownMenu) && mouseMove) {
                    shutdownMenuHover = !shutdownMenuHover;
                    MenuItem.draw(shutdownMenu, "Shutdown", font, shutdownMenuHover);
                } else {
                    if (shutdownMenuHover && Mouse.exit(shutdownMenu) && mouseMove) {
                        shutdownMenuHover = !shutdownMenuHover;
                        MenuItem.draw(shutdownMenu, "Shutdown", font, shutdownMenuHover);
                    }
                }
                if (Mouse.click(shutdownMenu) && 1 == button) {
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

    public static void showFreeMemory(int screenWidth, int screenHeight, int[] font) {
        int mem = Native.freemem(0) / 1000;
        UI.fillRect(screenWidth - 54, screenHeight - 22, 50, 18, 15);
        UI.drawString(StringUtils.concat(StringUtils.valueOf(mem), " KB"), screenWidth - 50, screenHeight - 20, font, true, false);
    }
}
