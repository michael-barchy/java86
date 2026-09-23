package ui;

import io.File;
import platform.Native;

public class Font {

    /**
     * Load font file and intialize charWidth cache
     *
     * @return [fontHandle, bmpWidth, bmpHeight, charWidth x 223]
     */
    public static int[] open(String path) {
        int[] bmp = BMP.open(path);

        int[] font = new int[] {
                bmp[0],
                bmp[1],
                bmp[2],
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0
        };

        return font;
    }

    public static int getWidth(int[] font) {
        return font[1];
    }

    public static int getHeight(int[] font) {
        return font[2] / 223;
    }

    public static int copyChar(int[] font, byte[] dest, int destWidth, int c, int x, int y) {
        int fontHandle = font[0];
        int charWidth = font[1];
        int charHeight = font[2] / 223;

        if (-1 == fontHandle) {
            return charWidth;
        }

        int charIndex = c - 33;
        if (charIndex < 0) {
            return charWidth;
        }

        // Font is a vertical sprite image from char 33-255
        int charSize = charWidth * charHeight;
        int sourceY = charIndex * charHeight;
        int wOffset = charIndex + 3;
        int w = font[wOffset];

        if (0 == w) {
            byte[] charBuffer = new byte[charSize];
            BMP.copy(font, charBuffer, charWidth, 0, 0, charWidth, 0, sourceY, charHeight);
            for (int y1 = 0; y1 < charHeight; y1++) {
                for (int x1 = charWidth - 1; x1 >= 0; x1--) {
                    int offset = x1 + (y1 * charWidth);
                    if (x1 > w && 0 == charBuffer[offset]) {
                        w = x1;
                        break;
                    }
                }
            }
        }

        BMP.copy(font, dest, destWidth, x, y, charWidth, 0, sourceY, charHeight);

        return w;
    }

    public static void close(int[] font) {
        int fontHandle = font[0];

        if (-1 == fontHandle) {
            return;
        }

        File.close(fontHandle);
    }
}
