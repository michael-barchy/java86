package ui;

import io.File;
import platform.Native;
import util.StringUtils;

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

        int dat = File.open("FONTS.DAT", 0);
        byte[] record = new byte[236]; // 236 = LF
        while (-1 != File.readBytes(dat, record)) {
            String fontName = Native.toString(record);
            if (StringUtils.startsWith(fontName, path)) {
                for (int c = 12; c < 236; c++) {
                    int i = c - 9; // 12 - 9 = 3 (font start index)
                    font[i] = record[c] - 48;
                }
                break;
            }
        }
        File.close(dat);

        return font;
    }

    public static int getWidth(int[] font) {
        return font[1];
    }

    public static int getHeight(int[] font) {
        return font[2] / 223;
    }

    public static void copyChar(int[] font, byte[] dest, int destWidth, int c, int x, int y) {
        int fontHandle = font[0];
        int charWidth = font[1];
        int charHeight = font[2] / 223;

        if (-1 == fontHandle) {
            return;
        }

        int charIndex = c - 33;
        if (charIndex < 0) {
            return;
        }

        // Font is a vertical sprite image from char 33-255
        int sourceY = charIndex * charHeight;

        BMP.copy(font, dest, destWidth, x, y, charWidth, 0, sourceY, charHeight);
    }

    public static void close(int[] font) {
        int fontHandle = font[0];

        if (-1 == fontHandle) {
            return;
        }

        File.close(fontHandle);
    }
}
