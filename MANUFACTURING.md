# BF1 manufacturing

Please open a ticket or reach <info@zubax.com> if questions arise.

## Prerequisites

The instructions below assume that the host computer is running a Linux-based OS.

### Installing dependencies

#### Debian-based systems

The following APT packages must be installed:

* `python-yaml`
* `python-usb`

Also, the ARM GCC toolchain must be installed in order to build the firmware and test the board with GDB.
The toolchain is available from <https://launchpad.net/gcc-arm-embedded>,
or from an APT package `gcc-arm-none-eabi`.
Recommended GCC version is 7.2.

## Assembling

See the assembly drawing in PDF available in this repo.
All components are reflow-solderable.

Keep in mind that certain components are explicitly marked as not to be installed.

## Getting the firmware

Get the sources from <https://github.com/blacksphere/blackmagic> and build them.
The output will contain the following two files (among others):

* `blackmagic_dfu.bin` - the USB DFU bootloader.
* `blackmagic_latest.bin` - the main firmware.

Prebuilt binaries can be found here: <https://files.zubax.com/products/com.zubax.bugface>.

The following comands can be used to create a loadable ELF from a flat binary:

    arm-none-eabi-objcopy -I binary -O elf32-little --change-section-address .data=0x08000000 blackmagic_dfu.bin blackmagic_dfu.elf

## Flashing the firmware for the first time

To upload the firmware for the first time, simply use [`flash_bugface_bf1.sh`](flash_bugface_bf1.sh);
read the usage instructions in the comments.

## Updating the firmware via DFU

If you want to replace an already uploaded firmware, you can also do it as described in this section.

Connect the board to USB while holding the button `BOOT`.
All LEDs on the board should start blinking alernately.
The system will report the device as follows:

```
$ sudo dmesg
usb 3-1.4.1: new full-speed USB device number 16 using xhci_hcd
usb 3-1.4.1: New USB device found, idVendor=1d50, idProduct=6017
usb 3-1.4.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 3-1.4.1: Product: Black Magic Probe (Upgrade)
usb 3-1.4.1: Manufacturer: Black Sphere Technologies
usb 3-1.4.1: SerialNumber: 7ECB8AC5
```

Then go to the directory with firmware sources and execute the following script:

```bash
sudo dfu-util -d 1d50:6017 -s 0x08002000:leave -R -D src/blackmagic.bin
```
The following information will be reported in the console:

```
Opening DFU capable USB device...
ID 1d50:6017
Run-time device DFU version 011a
Claiming USB DFU Interface...
Setting Alternate Setting #0 ...
Determining device status: state = dfuIDLE, status = 0
dfuIDLE, continuing
DFU mode device DFU version 011a
Device returned transfer size 1024
DfuSe interface name: "Internal Flash   "
Downloading to address = 0x08002000, size = 120004
Download	[=========================] 100%       120004 bytes
Download done.
```

Disconnect the board afterwards.

Alternative instructions for this step are available from
<https://github.com/blacksphere/blackmagic/wiki/Upgrading-Firmware>.

## Testing

Disconnect the newly flashed board from USB, then connect again.
The system will detect a new CDC-ACM device:

```
$ dmesg
usb 3-1.4.1: new full-speed USB device number 19 using xhci_hcd
usb 3-1.4.1: New USB device found, idVendor=1d50, idProduct=6018
usb 3-1.4.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 3-1.4.1: Product: Black Magic Probe
usb 3-1.4.1: Manufacturer: Black Sphere Technologies
usb 3-1.4.1: SerialNumber: 7ECB8AC5
cdc_acm 3-1.4.1:1.0: ttyACM0: USB ACM device
cdc_acm 3-1.4.1:1.2: ttyACM1: USB ACM device
```

Connect the board to a target (e.g. another unflashed BF1, as described in one of the steps above)
and try to load its firmware using GDB.
For example, start `arm-none-eabi-gdb` providing path to the ELF,
and execute the following commands in the internal command prompt:

```
tar ext /dev/ttyACM0    # Or another port
mon swdp_scan
attach 1
load
kill
```
