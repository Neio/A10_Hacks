adb shell mkdir nanda
adb shell mount -t vfat /dev/block/nanda /nanda
adb pull /nanda/script.bin ./backup/script.bin
adb pull /nanda/script0.bin ./backup/script0.bin
./fexc -I bin -O fex ./backup/script.bin ./work/script.fex

