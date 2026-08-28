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
        Button.draw(160, 160, 100, 30);
        Native.newProcess("driver/Mouse");
    }
}
