import { mount, fdisk, mkfsvfat } from 'https://cdn.jsdelivr.net/npm/libmount@0.6.0/dist/libmount.mjs';
import { V86 } from 'https://cdn.jsdelivr.net/npm/v86';

const binFiles = {
    'freedos722.img': 'simulator/freedos722.img',
    'seabios.bin': 'simulator/seabios.bin',
    'vgabios.bin': 'simulator/vgabios.bin'
}

for (const binFile of Object.keys(binFiles)) {
    const remoteFile = binFiles[binFile];
    binFiles[binFile] = new Uint8Array(await (await fetch(remoteFile)).arrayBuffer());
}

console.debug(binFiles);

// freedos bootdisk

const bootBuffer = binFiles['freedos722.img'];
const bootDisk = mount(bootBuffer, { type: 'fat12' });
const bootFS = bootDisk.getFileSystem().getRoot();

const script = (document.currentScript ?? document.getElementById('simulator'));
const bat = [script.getAttribute('data-bat')].filter((s) => null !== s);

const autoExec = [
    '@ECHO OFF',
    'C:',
    ...(bat.map((s) => `CALL ${s}`))
];

console.debug(autoExec);

const autoexecFile = bootFS.makeFile('AUTOEXEC.BAT', { size: 0 });
const autoexecStr = autoExec.join('\r\n') + '\r\n';
const autoexecData = [...autoexecStr].map((c) => c.charCodeAt(0));
autoexecFile.open().writeData(new Uint8Array(autoexecData));

// build image

const applySectors = function (image, diskSectors, sectorOffset = 0) {
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

for (const f of bat) {
    const batData = await (await fetch(f)).arrayBuffer();
    const batFile = fileSystem.makeFile(f, { size: 0 });
    batFile.open().writeData(new Uint8Array(batData));
}

// release files
const releaseFiles = [
    'VBMOUSE.EXE',
    'JAVA.COM',
    'NATIVE.JAR',
    'HELLO.JAR',
    'UTILS.JAR',
    'SHELL.JAR',
    'DEMO.JAR',
    'UI.JAR',
    'DRIVER.JAR',
    'MOOUI.JAR'
];

for (const file of releaseFiles) {
    const filePath = `release/${file}`;
    const fileData = await (await fetch(filePath)).arrayBuffer();
    const newFile = fileSystem.makeFile(file, { size: 0 });
    newFile.open().writeData(new Uint8Array(fileData));
}

const newFile = fileSystem.makeFile('CTMOUSE.EXE', { size: 0 });
newFile.open().writeData(new Uint8Array(binFiles['ctmouse.exe']));

new V86({
    screen_container: document.getElementById('screen'),
    bios: binFiles['seabios.bin'],
    vga_bios: binFiles['vgabios.bin'],
    fda: bootBuffer,
    hda: diskImage,
    autostart: true,
});
