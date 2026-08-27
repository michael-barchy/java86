public class MooUI {
    public static void main(String[] args) {
        UI.create();
        UI.fillRect(50, 50, 100, 100, 4);
        UI.drawRect(50, 50, 100, 100, 15);
        UI.hLine(0, 10, 320, 15);
        UI.putPixel(160, 100, 15);
        UI.putPixel(319, 199, 15);
        Button.drawButton(160, 160, 100, 30);
    }
}
