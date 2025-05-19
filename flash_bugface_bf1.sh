#!/bin/bash
# Usage:
# - Connect one functional BugFace to this PC.
# - Connect it to the debug pins of the BugFace being flashed.
# - Run the script and ensure it completes successfully.

function die()
{
    echo "$@" 1>&2
    exit 1
}

tmpdir=$(mktemp -d) && cd "$tmpdir"
echo "Working directory: $tmpdir"

gdb_remote=$(readlink -f /dev/serial/by-id/*Black*Magic*Probe*0)
[ -e "$gdb_remote" ] || die "Debugger not found or more than one is available"
+echo "GDB remote: $gdb_remote"

which arm-none-eabi-objcopy || die "could not locate arm-none-eabi-objcopy"
which wget || die "could not locate wget"

wget https://files.zubax.com/products/com.zubax.bugface/bf1/blackmagic_dfu.bin    -O dfu.bin || die "could not download DFU firmware"
wget https://files.zubax.com/products/com.zubax.bugface/bf1/blackmagic_latest.bin -O fw.bin  || die "could not download firmware"

arm-none-eabi-objcopy -I binary -O elf32-little --change-section-address .data=0x08000000 dfu.bin dfu.elf || die "objcopy failed"
arm-none-eabi-objcopy -I binary -O elf32-little --change-section-address .data=0x08002000 fw.bin  fw.elf  || die "objcopy failed"

cat > script.gdb <<EOF

set confirm off
target extended-remote $gdb_remote
monitor swdp_scan
attach 1
load dfu.elf
load fw.elf
quit

EOF

arm-none-eabi-gdb -n -batch -x script.gdb || die "GDB failure"

echo "Success! :3"
