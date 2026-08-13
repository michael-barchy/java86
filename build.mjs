import { fileURLToPath, pathToFileURL } from 'url';
import { dirname, join } from 'path';
import { V86 } from 'v86';
import { fdisk, mkfsvfat, mount } from 'libmount';
import { copyFileSync, existsSync, readFileSync, readdirSync, writeFileSync } from 'fs';
import { execSync } from 'child_process';
import { platform } from 'os';
import readline from 'readline';
import fetch from 'node-fetch';
import * as zip from 'zip-lib';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

globalThis.__dirname = __dirname;

// bin files

const binFiles = {
    'janino-3.1.9.jar': 'https://repo1.maven.org/maven2/org/codehaus/janino/janino/3.1.9/janino-3.1.9.jar',
    'commons-compiler-3.1.9.jar': 'https://repo1.maven.org/maven2/org/codehaus/janino/commons-compiler/3.1.9/commons-compiler-3.1.9.jar',
    'freedos722.img': 'https://i.copy.sh/freedos722.img',
    'seabios.bin': 'https://copy.sh/v86/bios/seabios.bin'
}

const binNames = Object.keys(binFiles);
for (const binFile of binNames) {
    const binPath = join(__dirname, 'bin', binFile);
    if (!existsSync(binPath)) {
        console.debug(`Downloading ${binFile}... ${binPath}`);
        const url = binFiles[binFile];
        writeFileSync(binPath, Buffer.from(await (await fetch(url)).arrayBuffer()));
    }
}

// compile classes

const sp = 'darwin' === platform() ? ':' : ';';
const cp = `./bin/janino-3.1.9.jar${sp}./bin/commons-compiler-3.1.9.jar`;
const javac = `java -classpath "${cp}" org.codehaus.commons.compiler.samples.CompilerDemo`;
execSync(`${javac} -d build src/Native.java`);
execSync(`${javac} -d build -classpath build src/Hello.java`);
execSync(`${javac} -d build -classpath build src/StringUtils.java`);
execSync(`${javac} -d build -classpath build src/Shell.java`);
await zip.archiveFile('build/Native.class', 'build/NATIVE.JAR', { compressionLevel: 0 });
await zip.archiveFile('build/Hello.class', 'build/HELLO.JAR', { compressionLevel: 0 });
await zip.archiveFile('build/StringUtils.class', 'build/UTILS.JAR', { compressionLevel: 0 });
await zip.archiveFile('build/Shell.class', 'build/SHELL.JAR', { compressionLevel: 0 });

// freedos bootdisk

const bootBuffer = readFileSync(join(__dirname, 'bin', 'freedos722.img'));
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

// build image

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

const buildFiles = {
    'MRC.EXE': 'https://github.com/DosWorld/moonrock/raw/refs/heads/master/MRC.EXE',
    'MOONROCK.ALB': 'https://github.com/DosWorld/moonrock/raw/refs/heads/master/MOONROCK.ALB',
    'MOONROCK.PTR' : 'https://github.com/DosWorld/moonrock/raw/refs/heads/master/MOONROCK.PTR',
    'MRLINK.COM': 'https://github.com/DosWorld/moonrock/raw/refs/heads/master/MRLINK.COM',
    'ASM.EXE': 'https://sourceforge.net/projects/microsoft-macro-assembler-v5-0/files/8086/MASM.EXE/download'
};

const buildNames = Object.keys(buildFiles);
for (const buildFile of buildNames) {
    const buildPath = join(__dirname, 'build', buildFile);
    if (!existsSync(buildPath)) {
        console.debug(`Downloading ${buildFile}... ${buildPath}`);
        const url = buildFiles[buildFile];
        writeFileSync(buildPath, Buffer.from(await (await fetch(url)).arrayBuffer()));
    }
}

buildNames.forEach(file => {
    const filePath = join(__dirname, 'build', file);
    const fileData = readFileSync(filePath);
    const newFile = fileSystem.makeFile(file, { size: 0 });
    newFile.open().writeData(fileData);
});

// source files
const files = [
    'MAKE.BAT',
    'JAVA.MOO',
    'JAVA.H'
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

const jarFiles = [
    'NATIVE.JAR',
    'HELLO.JAR',
    'UTILS.JAR',
    'SHELL.JAR'
];

jarFiles.forEach(file => {
    const filePath = join(__dirname, 'build', file);
    const fileData = readFileSync(filePath);
    const newFile = fileSystem.makeFile(file, { size: 0 });
    newFile.open().writeData(fileData);
});

// start emulator

const emulator = new V86({
    wasm_path: 'node_modules/v86/build/v86.wasm',
    bios: { url: 'bin/seabios.bin' },
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
