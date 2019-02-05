# DroneCode Probe manufacturing

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
Recommended GCC version is 4.9.

## Assembling

See the assembly drawing in PDF available in this repo.
All components are reflow-solderable.

Keep in mind that certain components are explicitly marked as not to be installed.

## Getting the firmware

Get the sources from <https://github.com/blacksphere/blackmagic> and build them.
The output will contain the following two files (among others):

* `blackmagic_dfu.bin` - DFU bootloader.
* `blackmagic.bin` - main firmware.

Prebuilt binaries can be found here: <https://files.zubax.com/products/dronecode_probe>.

## Flashing the DFU bootloader

Flash the DFU bootloader image using one of the methods below.

### Using STM32 serial bootloader

1. Using tweezers, close the jumper `BOOT0` and connect the board to USB
(note that the jumper itself is marked as not to be installed).
The microcontroller will start the embedded bootloader, accessible via the serial port.
Once the board is powered, the tweezers can be removed.
2. Using any available STM32 serial bootloader tool, load the DFU bootloader image onto the board at zero offset
(i.e. 0x08000000, which is the address of flash).
3. Disconnect the board from USB.

It is adviced to use the following tool for flashing: <https://github.com/Zubax/zubax_serial_updater>.

### Using JTAG/SWD

This option will require an adapter cable, with ARM Cortex debug connector (1.27mm 2x5) on one end
and any of DroneCode debug connectors on the other end. The pinout of the cable must be as follows:

ARM Cortex debug connector      | DroneCode debug connector (any type)
--------------------------------|-------------------------------------
`GND` (pin 3 or 5)              | `GND` (pin 6)
`SWDIO/TMS` (pin 2)             | `UART_RX` (pin 2)
`SWDCLK/TDO` (pin 4)            | `UART_TX` (pin 3)

Steps:

1. Install resistors (or short with solder blobs) between the microcontroller's own SWD interface and UART signals.
Currently their designators are R14 and R15.
2. Connect one end of the adapter cable to a JTAG/SWD adapter (e.g. to an another DroneCode Probe that is already
flashed), and the other end to the corresponding DroneCode debug connector of the target device.
3. Using any of the available tools, flash the DFU bootloader image to the target board with
zero offset from the start of the flash memory.
4. Disconnect the target board.

The following script can be used to create a loadable ELF from a flat binary: <https://gist.github.com/tangrs/4030336>.
Usage example:

    ./bin2elf.sh blackmagic_dfu.bin blackmagic_dfu.elf 0x08000000

## Flashing the main firmware

Connect the board to USB while holding the button `BOOT`.
The red LED on the board should start blinking.
The system will report the device as follows:

```
$ dmesg
usb 2-6.2.3: new full-speed USB device number 12 using ehci-pci
usb 2-6.2.3: New USB device found, idVendor=1d50, idProduct=6017
usb 2-6.2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 2-6.2.3: Product: Black Magic Probe (Upgrade)
usb 2-6.2.3: Manufacturer: Black Sphere Technologies
usb 2-6.2.3: SerialNumber: B5DCABF5
```

Then go to the directory with firmware sources and execute the following script:

```bash
sudo scripts/stm32_mem.py src/blackmagic.bin
```

Disconnect the board afterwards.

Alternative instructions for this step are available from
<http://px4.io/dev/jtag/black_magic_probe#instructions_for_linux>.

## Testing

Disconnect the newly flashed board from USB, then connect again.
The system will detect a new CDC-ACM device:

```
$ dmesg
usb 2-6.2.3: new full-speed USB device number 9 using ehci-pci
usb 2-6.2.3: New USB device found, idVendor=1d50, idProduct=6018
usb 2-6.2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 2-6.2.3: Product: Black Magic Probe
usb 2-6.2.3: Manufacturer: Black Sphere Technologies
usb 2-6.2.3: SerialNumber: B5DCABF5
cdc_acm 2-6.2.3:1.0: This device cannot do calls on its own. It is not a modem.
cdc_acm 2-6.2.3:1.0: ttyACM0: USB ACM device
cdc_acm 2-6.2.3:1.2: This device cannot do calls on its own. It is not a modem.
cdc_acm 2-6.2.3:1.2: ttyACM1: USB ACM device
usbcore: registered new interface driver cdc_acm
cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
```

Connect the board to a target (e.g. another unflashed DroneCode Probe, as described in one of the steps above)
and try to load a firmware using GDB.
For example, start `arm-none-eabi-gdb` providing path to the ELF,
and execute the following commands in the internal command prompt:

```
tar ext /dev/ttyACM0    # Or another port
mon swdp_scan
attach 1
load
```

The steps can be automated with a script, e.g.
<https://github.com/Zubax/zubax_rtems/blob/master/flashers/flash_via_blackmagic.sh>.
