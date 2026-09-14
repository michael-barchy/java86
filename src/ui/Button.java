package ui;

public class Button {
    public static void draw(int x, int y, int w, int h) {
        UI.fillRect(x, y, w, h, 7);
        UI.hLine(x, y, w, 15);
        UI.vLine(x, y, h, 15);
        UI.hLine(x, y + h - 1, w, 8);
        UI.vLine(x + w - 1, y, h, 8);
    }

    public static void state(int x, int y, int w, int h, boolean pressed) {
        int color1 = pressed ? 8 : 15;
        int color2 = pressed ? 15 : 8;

        UI.hLine(x, y, w, color1);
        UI.vLine(x, y, h, color1);
        UI.hLine(x, y + h - 1, w, color2);
        UI.vLine(x + w - 1, y + 1, h - 1, color2);
    }
}
