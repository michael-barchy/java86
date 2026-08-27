import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { V86 } from 'v86';
import { fdisk, mkfsvfat, mount } from 'libmount';
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'fs';
import { execSync } from 'child_process';
import { platform } from 'os';
import readline from 'readline';
import fetch from 'node-fetch';
import * as zip from 'zip-lib';

export async function run(bat = ['MAKE.BAT'], exitOnBuild = true) {
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = dirname(__filename);

    globalThis.__dirname = __dirname;

    // bin files

    if (!existsSync('bin')) {
        mkdirSync('bin');
    }

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

    if (!existsSync('build')) {
        mkdirSync('build');
    }

    const sp = 'darwin' === platform() ? ':' : ';';
    const cp = `./bin/janino-3.1.9.jar${sp}./bin/commons-compiler-3.1.9.jar`;
    const javac = `java -classpath "${cp}" org.codehaus.commons.compiler.samples.CompilerDemo`;
    execSync(`${javac} -d build src/Native.java`);
    execSync(`${javac} -d build -classpath build src/Hello.java`);
    execSync(`${javac} -d build -classpath build src/StringUtils.java`);
    execSync(`${javac} -d build -classpath build src/UI.java`);
    execSync(`${javac} -d build -classpath build src/*.java`);
    await zip.archiveFile('build/Native.class', 'release/NATIVE.JAR', { compressionLevel: 0 });
    await zip.archiveFile('build/Hello.class', 'release/HELLO.JAR', { compressionLevel: 0 });
    await zip.archiveFile('build/StringUtils.class', 'release/UTILS.JAR', { compressionLevel: 0 });
    await zip.archiveFile('build/Shell.class', 'release/SHELL.JAR', { compressionLevel: 0 });
    const demo = new zip.Zip({ compressionLevel: 0 });
    demo.addFile('build/Demo.class');
    demo.addFile('build/Proc1.class');
    demo.addFile('build/Proc2.class');
    await demo.archive('release/DEMO.JAR');
    const ui = new zip.Zip({ compressionLevel: 0 });
    ui.addFile('build/UI.class');
    ui.addFile('build/Button.class');
    await ui.archive('release/UI.JAR');
    const mooui = new zip.Zip({ compressionLevel: 0 });
    mooui.addFile('build/MooUI.class');
    await mooui.archive('release/MOOUI.JAR');

    // freedos bootdisk

    const bootBuffer = readFileSync(join(__dirname, 'bin', 'freedos722.img'));
    const bootDisk = mount(bootBuffer, { type: 'fat12' });
    const bootFS = bootDisk.getFileSystem().getRoot();

    const autoExec = [
        '@ECHO OFF',
        'CTTY COM1',
        'C:',
        ...(bat.map((s) => `CALL ${s}`))
    ];

    const autoexecFile = bootFS.makeFile('AUTOEXEC.BAT', { size: 0 });
    autoexecFile.open().writeData(Buffer.from(autoExec.join('\r\n') + '\r\n', 'utf8'));

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
        ...bat,
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
        'SHELL.JAR',
        'DEMO.JAR',
        'UI.JAR',
        'MOOUI.JAR'
    ];

    jarFiles.forEach(file => {
        const filePath = join(__dirname, 'release', file);
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

    if (!existsSync('release')) {
        mkdirSync('release');
    }

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

    setTimeout(() => {
        setInterval(() => {
            const releaseFile = fileSystem.getFile('JAVA.COM');
            if (null !== releaseFile) {
                writeFileSync(join('release', 'JAVA.COM'), releaseFile.open()?.readData());
                if (exitOnBuild) {
                    releaseFile.delete();
                    process.exit();
                }
            }

            const errFile = fileSystem.getFile('JAVA.ERR');
            if (null !== errFile) {
                console.log(Buffer.from(errFile.open()?.readData()).toString());
                errFile.delete();
                if(exitOnBuild) process.exit();
            }
        }, 1000);
    }, 2000); // boot

}

