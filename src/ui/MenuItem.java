package ui;

import driver.Mouse;

public class MenuItem {
    public static int[] create(int[] menu, int pos, int[] font) {
        int x = menu[0] + 2;
        int y = menu[1] + 2 + (pos * Font.getHeight(font));
        int w = menu[2] - 4;
        int h = Font.getHeight(font) + 4;

        return new int[] { x, y, w, h };
    }

    public static int[] draw(int[] menuItem, String s, int[] font, boolean hover) {
        int[] mouseHide = Mouse.hide();

        int x = menuItem[0];
        int y = menuItem[1];
        int w = menuItem[2];
        int h = menuItem[3];
        UI.fillRect(x, y, w, h, hover ? 1 : 7);
        UI.drawString(s, x + 4, y + 2, font, true, hover);

        Mouse.show(mouseHide);

        return new int[] { x, y, w, h };
    }
}
