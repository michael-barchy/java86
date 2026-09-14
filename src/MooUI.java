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

        UI.fillRect(50, 50, 100, 100, 4);
        UI.drawRect(50, 50, 100, 100, 15);
        UI.drawLine(50, 50, 149, 149, 15);
        UI.drawLine(50, 149, 149, 50, 15);

        Button.draw(300, 5, 15, 15);
        UI.drawLine(302, 7, 312, 17, 0);
        UI.drawLine(302, 17, 312, 7, 0);

        int mouse = Native.newProcess("driver/Mouse");
        int button = 0;
        int prevButton = 0;
        boolean pressed = false;

        while (true) {
            button = Mouse.button();
            if (1 == button) {
                int x = Mouse.x();
                int y = Mouse.y();
                if (x >= 300) {
                    if (y <= 20) {
                        Button.state(300, 5, 15, 15, true);
                    }
                }
            }
            pressed = 0 == button && 1 == prevButton;
            if (pressed) {
                Button.state(300, 5, 15, 15, false);
                int x = Mouse.x();
                int y = Mouse.y();
                if (x >= 300) {
                    if (y <= 20) {
                        Native.killProcess(mouse);
                        break;
                    }
                }
            }
            prevButton = button;
        }

        UI.destroy();
    }
}
