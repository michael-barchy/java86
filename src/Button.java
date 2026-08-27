public class Button {
    public static void drawButton(int x, int y, int w, int h) {
        UI.fillRect(x, y, w, h, 7);
        UI.hLine(x, y, w, 15);
        UI.vLine(x, y, h, 15);
        UI.hLine(x, y + h - 1, w, 8);
        UI.vLine(x + w - 1, y, h, 8);
    }
}
