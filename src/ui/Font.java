package ui;

import io.File;
import platform.Native;

public class Font {

    /**
     * Load font file and intialize charWidth cache
     *
     * @return [fontHandle, charWidth, charHeight, charWidth x 222]
     */
    public static int[] open(String path) {
        int fontHandle = File.open(path, 0);
        int w = getWidth(fontHandle);
        int h = getHeight(fontHandle) / w;

        int[] font = new int[] {
                fontHandle,
                w,
                h,
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
                0, 0
        };

        return font;
    }

    public static int getWidth(int fontHandle) {
        byte[] widthBytes = new byte[4];
        File.seek(fontHandle, 0, 18);
        File.readBytes(fontHandle, widthBytes);

        return (widthBytes[0] & 0xFF) | ((widthBytes[1] & 0xFF) << 8);
    }

    public static int getHeight(int fontHandle) {
        byte[] heightBytes = new byte[4];
        File.seek(fontHandle, 0, 22);
        File.readBytes(fontHandle, heightBytes);
        int h = (heightBytes[0] & 0xFF) | ((heightBytes[1] & 0xFF) << 8);
        if (h < 0) {
            h = -h;
        }

        return h;
    }

    public static int drawChar(int[] font, int c, int x, int y) {
        int screenWidth = 320;
        int fontHandle = font[0];
        int charWidth = font[1];
        int charHeight = font[2];

        if (-1 == fontHandle) {
            return charWidth;
        }

        int charIndex = c - 32;
        if (charIndex < 0) {
            return charWidth;
        }

        int charSize = charWidth * charHeight;
        int charOffset = 1078 + (charIndex * charSize);
        int byteOffset = 0;
        int wOffset = (c - 33) + 3;
        int w = font[wOffset];

        byte[] pixelBuffer = new byte[charSize];

        for (int y1 = charHeight - 1; y1 >= 0; y1--) {
            int fileOffset = charOffset - (y1 * charWidth);

            File.seek(fontHandle, 0, fileOffset);
            File.read(fontHandle, pixelBuffer, byteOffset, charWidth);

            if (0 == w) {
                for (int n = charWidth - 1; n >= 0; n--) {
                    wOffset = byteOffset + n;
                    if (0 == pixelBuffer[wOffset]) {
                        if (n > w) {
                            w = n;
                        }
                        break;
                    }
                }
            }

            byteOffset += charWidth;
        }

        int offsetX = x + (y * screenWidth);
        Native.farmemsetb(pixelBuffer, 0xa0, 0x00, offsetX, charWidth, screenWidth, 15);

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
