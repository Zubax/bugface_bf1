# Dronecode Probe manufacturing

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
* `blackmagic.bin` - the main firmware.

Prebuilt binaries can be found here: <https://files.zubax.com/products/dronecode_probe>.

The following comands can be used to create a loadable ELF from a flat binary:

    arm-none-eabi-objcopy -I binary -O elf32-little --change-section-address .data=0x08000000 blackmagic_dfu.bin blackmagic_dfu.elf
    arm-none-eabi-objcopy -I binary -O elf32-little --change-section-address .data=0x08000000 blackmagic.bin blackmagic.elf

## Flashing the DFU bootloader

Flash the DFU bootloader image using one of the methods below.

### Using the STM32 serial bootloader

1. Using tweezers, close the jumper `BOOT0` and connect the board to USB
(note that the jumper itself is marked as not to be installed).
The microcontroller will start the embedded bootloader, accessible via the serial port.
Once the board is powered, the tweezers can be removed.
It is adviced to use the following tool for flashing: <https://github.com/Zubax/zubax_serial_updater>.

2. Using any available STM32 serial bootloader tool, load the DFU bootloader image onto the board at zero offset
(i.e. 0x08000000, which is the address of flash).

3. Disconnect the board from USB.

### Using JTAG/SWD

1. Connect the board to USB and SWD pins of the board to any other SWD adapter (e.g., another Dronecode Probe).
SWD pins are marked on the bottom side of the board: SWD, GND, SWC, 5V. Note, that 5V pin is target voltage probe pin. Don't connect it to any power supply.  

2. Using any of the available tools, flash the DFU bootloader image at 0x08000000 (i.e., at the start of the flash memory).

3. Disconnect the board from USB.


## Flashing the main firmware

Connect the board to USB while holding the button `BOOT`.
All LEDs on the board should start blinking alernately.
The system will report the device as follows:

```
$ dmesg
usb 3-1.4.1: new full-speed USB device number 16 using xhci_hcd
usb 3-1.4.1: New USB device found, idVendor=1d50, idProduct=6017
usb 3-1.4.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 3-1.4.1: Product: Black Magic Probe (Upgrade)
usb 3-1.4.1: Manufacturer: Black Sphere Technologies
usb 3-1.4.1: SerialNumber: 7ECB8AC5
```

Then go to the directory with firmware sources and execute the following script:

```bash
sudo scripts/stm32_mem.py src/blackmagic.bin
```
The following information will be reported in the console:

```
USB Device Firmware Upgrade - Host Utility -- version 1.2
Copyright (C) 2011  Black Sphere Technologies
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

Device ID:	 1d50:6017
Manufacturer:	 Black Sphere Technologies
Product:	 Black Magic Probe (Upgrade)
Serial:		 7ECB8AC5
Programming memory at 0x08018000
Verifying memory at   0x08018000
Verified!
All operations complete!
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

Connect the board to a target (e.g. another unflashed Dronecode Probe, as described in one of the steps above)
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
