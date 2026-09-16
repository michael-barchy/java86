package ui;

import driver.Mouse;

public class Button {
    public static int[] draw(int x, int y, int w, int h) {
        UI.fillRect(x, y, w, h, 7);
        UI.hLine(x, y, w, 15);
        UI.vLine(x, y, h, 15);
        UI.hLine(x, y + h - 1, w, 8);
        UI.vLine(x + w - 1, y, h, 8);

        return new int[] { x, y, w, h };
    }

    public static void state(int[] button, boolean pressed) {
        int color1 = pressed ? 8 : 15;
        int color2 = pressed ? 15 : 8;
        int x = button[0];
        int y = button[1];
        int w = button[2];
        int h = button[3];

        UI.hLine(x, y, w, color1);
        UI.vLine(x, y, h, color1);
        UI.hLine(x, y + h - 1, w, color2);
        UI.vLine(x + w - 1, y + 1, h - 1, color2);
    }

    public static boolean mouseevent(int[] button, int mouseButton) {
        if (mouseButton != Mouse.button()) {
            return false;
        }

        int x = Mouse.x();
        int x1 = button[0];

        if (x < x1) {
            return false;
        }

        int y = Mouse.y();
        int y1 = button[1];

        if (y < y1) {
            return false;
        }

        int w = button[2];
        int x2 = x1 + w;

        if (x > x2) {
            return false;
        }

        int h = button[3];
        int y2 = y1 + h;

        if (y > y2) {
            return false;
        }

        return true;
    }

    public static boolean mousedown(int[] button) {
        return mouseevent(button, 1);
    }

    public static boolean mouseup(int[] button) {
        return mouseevent(button, 0);
    }
}
