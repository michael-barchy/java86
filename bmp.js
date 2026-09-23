function bmp(imgData, transparency) {
    var width = imgData.width;
    var height = imgData.height;
    var data = imgData.data;

    var palette = [{ r: 0, g: 0, b: 0 }];
    var paletteMap = new Map();
    paletteMap.set(0, 0);
    if (true === transparency) {
        var rgbKey = (255 << 16) | (255 << 8) | 255;
        paletteMap.set(rgbKey, 15);
    }
    var pixelIndices = new Uint8Array(width * height);

    for (var i = 0; i < data.length; i += 4) {
        var r = data[i];
        var g = data[i + 1];
        var b = data[i + 2];
        var pixelPos = i / 4;

        if (true === transparency && (255 !== r && 255 !== g && 255 !== b)) {
            r = r < 0xaa ? 0 : 255;
            g = g < 0xaa ? 0 : 255;
            b = b < 0xaa ? 0 : 255;
        }

        var rgbKey = (r << 16) | (g << 8) | b;

        if (!paletteMap.has(rgbKey)) {
            if (palette.length < 256) {
                palette.push({ r, g, b });
                paletteMap.set(rgbKey, palette.length - 1);
            } else {
                var closestIndex = 0;
                var minDistance = Infinity;
                for (var p = 0; p < palette.length; p++) {
                    var dist = Math.pow(r - palette[p].r, 2) + Math.pow(g - palette[p].g, 2) + Math.pow(b - palette[p].b, 2);
                    if (dist < minDistance) {
                        minDistance = dist;
                        closestIndex = p;
                    }
                }
                paletteMap.set(rgbKey, closestIndex);
            }
        }
        pixelIndices[pixelPos] = paletteMap.get(rgbKey);
    }

    while (palette.length < 256) {
        if (true === transparency && 15 === palette.length) {
            palette.push({ r: 255, g: 255, b: 255 });
        } else {
            palette.push({ r: 0, g: 0, b: 0 });
        }
    }

    var rowSize = Math.floor((8 * width + 31) / 32) * 4;
    var pixelArraySize = rowSize * height;
    var paletteSize = 256 * 4;
    var fileOffset = 14 + 40 + paletteSize;
    var fileSize = fileOffset + pixelArraySize;

    var buffer = new ArrayBuffer(fileSize);
    var view = new DataView(buffer);

    view.setUint8(0, 0x42);
    view.setUint8(1, 0x4D);
    view.setUint32(2, fileSize, true);
    view.setUint32(6, 0, true);
    view.setUint32(10, fileOffset, true);

    view.setUint32(14, 40, true);
    view.setInt32(18, width, true);
    view.setInt32(22, height, true);
    view.setUint16(26, 1, true);
    view.setUint16(28, 8, true);
    view.setUint32(30, 0, true);
    view.setUint32(34, pixelArraySize, true);
    view.setInt32(38, 2835, true);
    view.setInt32(42, 2835, true);
    view.setUint32(46, 256, true);
    view.setUint32(50, 256, true);

    var paletteOffset = 54;
    for (var i = 0; i < 256; i++) {
        view.setUint8(paletteOffset++, palette[i].b);
        view.setUint8(paletteOffset++, palette[i].g);
        view.setUint8(paletteOffset++, palette[i].r);
        view.setUint8(paletteOffset++, 0);
    }

    var dataOffset = fileOffset;
    for (var y = height - 1; y >= 0; y--) {
        for (var x = 0; x < width; x++) {
            var index = pixelIndices[y * width + x];
            view.setUint8(dataOffset++, index);
        }
        while ((dataOffset - fileOffset) % 4 !== 0) {
            view.setUint8(dataOffset++, 0);
        }
    }

    return new Blob([buffer], { type: 'image/bmp' });
}
