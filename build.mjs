import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { V86 } from 'v86';
import { fdisk, mkfsvfat, mount } from 'libmount';
import { copyFileSync, existsSync, readFileSync, readdirSync, writeFileSync } from 'fs';
import readline from 'readline';
import fetch from 'node-fetch';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

globalThis.__dirname = __dirname;

if (!existsSync(join(__dirname, 'freedos722.img'))) {
    writeFileSync(join(__dirname, 'freedos722.img'), Buffer.from(await (await fetch('https://i.copy.sh/freedos722.img')).arrayBuffer()));
}

if (!existsSync(join(__dirname, 'seabios.bin'))) {
    writeFileSync(join(__dirname, 'seabios.bin'), Buffer.from(await (await fetch('https://copy.sh/v86/bios/seabios.bin')).arrayBuffer()));
}

const bootBuffer = readFileSync(join(__dirname, 'freedos722.img'));
const bootDisk = mount(bootBuffer, { type: 'fat12' });
const bootFS = bootDisk.getFileSystem().getRoot();

const autoExec = [
    '@ECHO OFF',
    'CTTY COM1',
    'C:',
    'MAKE.BAT'
];

const autoexecFile = bootFS.makeFile('AUTOEXEC.BAT', { size: 0 });
autoexecFile.open().writeData(Buffer.from(autoExec.join('\r\n') + '\r\n', 'utf8'));

const applySectors = function applySectors(image, diskSectors, sectorOffset = 0) {
  const bytsPerSec = diskSectors.bytsPerSec || 512;

  for (const region of diskSectors.zeroRegions) {
    const start = (sectorOffset + region.i) * bytsPerSec;
    const length = region.count * bytsPerSec;
    image.fill(0, start, start + length);
  }

  for (const sec of diskSectors.dataSectors) {
    const start = (sectorOffset + sec.i) * bytsPerSec;
    image.set(sec.data, start);
  }
}

const SECTOR_SIZE = 512;
const TOTAL_SECTORS = 65536;
const PARTITION_START = 63;
const PARTITION_SECTORS = TOTAL_SECTORS - PARTITION_START;

const partition = {
  active: true,
  type: 0x06,
  relativeSectors: PARTITION_START,
  totalSectors: PARTITION_SECTORS,
};

const mbrSectors = fdisk([partition]);

const partitionCapacityBytes = PARTITION_SECTORS * SECTOR_SIZE;
const vfatResult = mkfsvfat(partitionCapacityBytes, {
  type: 'FAT16'
});

if (!vfatResult) {
  throw new Error("Impossible d'initialiser le système de fichiers FAT16.");
}

const diskImage = new Uint8Array(TOTAL_SECTORS * SECTOR_SIZE);
applySectors(diskImage, mbrSectors, 0);
applySectors(diskImage, vfatResult.sectors, partition.relativeSectors);

const disk = mount(diskImage, { partition });

const fileSystem = disk.getFileSystem().getRoot();

if (!existsSync('MRLINK.COM')) {
    copyFileSync(join(__dirname, 'moonrock', 'MRLINK.COM'), join(__dirname, 'MRLINK.COM'));
}

const compilerFiles = [
    'MRC.EXE',
    'MOONROCK.ALB',
    'MOONROCK.PTR',
    'MRLINK.COM'
];

compilerFiles.forEach(file => {
    const filePath = join(__dirname, 'moonrock', file);
    const fileData = readFileSync(filePath);
    const newFile = fileSystem.makeFile(file.replaceAll('/', '\\'), { size: 0 });
    newFile.open().writeData(fileData);
});

const files = [
    'MAKE.BAT',
    'ASM.EXE',
    'JAVA.MOO',
    'JAVA.H',
    'NATIVE.JAR',
    'HELLO.JAR'
];

readdirSync(join(__dirname, 'src')).forEach(file => {
    if (file.endsWith('.moo') || file.endsWith('.h')) {
        files.push('src/' + file);
    }
});

files.forEach(file => {
    const filePath = join(__dirname, file);
    const fileData = readFileSync(filePath);
    const newFile = fileSystem.makeFile(file.replaceAll('/', '\\'), { size: 0 });
    newFile.open().writeData(fileData);
});

const emulator = new V86({
    wasm_path: 'node_modules/v86/build/v86.wasm',
    bios: { url: 'seabios.bin' },
    fda: { buffer: bootBuffer.buffer },
    hda: { buffer: diskImage.buffer },
    autostart: true,
});

emulator.add_listener('serial0-output-byte', function(byte) {
    process.stdout.write(String.fromCharCode(byte));
});

readline.emitKeypressEvents(process.stdin);

process.stdin.setRawMode(true);
process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('keypress', (str, key) => {
    if (key.ctrl && key.name === 'c') {
        process.exit();
    }

    if (key.name === 'backspace') {
        emulator.serial0_send('\x08');
        return;
    }

    if (str) {
        emulator.serial0_send(str);
    }
});
