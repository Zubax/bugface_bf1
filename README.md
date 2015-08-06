# DroneCode Probe

The DroneCode Probe is a generic JTAG / SWD + UART console adapter compatible with most ARM Cortex based
designs and in particular with hardware maintained by the DroneCode project.
It is a low-cost design with a BOM value around $10.00​ and supported on all operating systems (Windows, Linux, Mac OS).

## Key Features / Added Value

- Firmware compatible to the Black Magic probe.
- Does not require OpenOCD or other software to run GDB on Windows, Linux or Mac OS.
- Better setup / usage experience compared to other JTAG probes
- Integrated 3.3V serial adapter for console access
- Solder-free support for common DroneCode cabling options:
  - ARM Mini 10pos standard header
  - DCD-S: DroneCode Debug connector small
  - DCD-M: DroneCode Debug connector medium
  - 6-pos DF13 console cable (Pixhawk 1.x)

## Suggested Packaging Content (JST SUR and SH required as minimum)

- JST SUR 6 pos cable (available from [JST](http://www.jst.com/home9.html) or at lower quantities from 3D Robotics)
- JST SH 6 pos cable ([SparkFun](https://www.sparkfun.com/products/9123))
- ARM Mini cable ([Digi-Key](http://www.digikey.com/product-search/en?x=0&y=0&lang=en&site=us&KeyWords=FFSD-05-D-06.00-01-N))
- Hirose DF13 6-pos cable ([3DR Store](https://store.3drobotics.com/products/df13-6-position-connector-15-cm), or [wires](http://www.digikey.com/product-detail/en/H4BBT-10104-W8/H4BBT-10104-W8-ND/425449)+[headers](http://www.digikey.com/product-search/en?KeyWords=DF13-6S-1.25C&WT.z_header=search_go) from DigiKey)

## License

This project is licensed under the terms of [CC-BY-SA](https://creativecommons.org/licenses/by-sa/3.0/).
