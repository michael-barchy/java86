import driver.Mouse;
import platform.Native;
import ui.Button;
import ui.Font;
import ui.UI;

public class MooUI {
    public static void main(String[] args) {
        UI.create();
        for (int y = 0; y < 200; y++) {
            UI.hLine(0, y, 320, y);
        }

        // UI.fillRect(50, 50, 100, 100, 4);
        // UI.drawRect(50, 50, 100, 100, 15);
        // UI.drawLine(50, 50, 149, 149, 15);
        // UI.drawLine(50, 149, 149, 50, 15);

        byte[] hello = Native.getBytes("Hello");
        int l = hello.length;
        int[] font = Font.open("SSERIF12.BMP");
        int x = 0;
        int space = font[1] / 8;
        if (-1 != font[0]) {
            for (int c = 0; c < l; c++) {
                int w = Font.drawChar(font, hello[c], x, 0);
                int wOffset = (c - 33) + 3;
                if (0 == font[wOffset]) {
                    font[wOffset] = w;
                }
                x += w + space;
            }
            Font.close(font);
        } else {
            Native.print("Could not load font\r\n");
        }

        int[] closeButton = Button.draw(300, 5, 15, 15);
        UI.drawLine(302, 7, 312, 17, 0);
        UI.drawLine(302, 17, 312, 7, 0);

        int mouse = Native.newProcess("driver/Mouse");
        int button = 0;
        int prevButton = 0;

        while (true) {
            button = Mouse.button();
            if (1 == button) {
                if (Button.mousedown(closeButton)) {
                    Button.state(closeButton, true);
                }
            }
            if (Mouse.pressed(prevButton)) {
                prevButton = 0;
                Button.state(closeButton, false);
                if (Button.mouseup(closeButton)) {
                    Native.killProcess(mouse);
                    break;
                }
            }
            prevButton = button;
        }

        UI.destroy();
    }
}
