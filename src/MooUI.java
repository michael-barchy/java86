import driver.Mouse;
import platform.Native;
import ui.Button;
import ui.UI;

public class MooUI {
    public static void main(String[] args) {
        UI.create();
        for (int y = 0; y < 200; y++) {
            UI.hLine(0, y, 320, y);
        }

        UI.fillRect(0, 0, 200, 20, 15);
        UI.drawRect(0, 0, 200, 20, 0);
        UI.drawString("Hello, world ! (print)", 5, 5, "SSERIF12.BMP");

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
