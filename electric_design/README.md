# Electronic
This subfolder is used for the circuit and PCB Design.

For developing we used KiCAD which is an open source CAD software.
It was used by the Raspberry Pi Foundation for their IO Board and the Compute Module.

## Project Structure
The next block shows the structure of files used from KiCAD.

ONLY store files we already build.
First step will only have project and schematics!
```
├── FreeSpeaker-backups
│   ├── [..] KiCAD Auto save files
├── FreeSpeaker.csv (generated bill of material)
├── FreeSpeaker.kicad_pcb (pcb design )
├── FreeSpeaker.kicad_prl (pcb design )
├── FreeSpeaker.kicad_pro (kicad project file)
├── FreeSpeaker.kicad_sch (kicad schematic)
├── hardwareID_connector
│   ├── hardwareID_connector.kicad_pro
│   └── hardwareID_connector.kicad_sch
├── LoRaWan
│   ├── LoRaWan.kicad_pro
│   └── LoRaWan.kicad_sch
├── Mainboard
│   ├── Mainboard.kicad_pro
│   └── Mainboard.kicad_sch
├── PowerSupply
│   ├── PowerSupply.kicad_pro
│   └── PowerSupply.kicad_sch
├── PrototypingSlice
│   ├── PrototypingSlice.kicad_pro
│   └── PrototypingSlice.kicad_sch
├── Speaker
│   ├── Speaker.kicad_pro
│   └── Speaker.kicad_sch
└── UserInterface
    ├── UserInterface.kicad_pro
    └── UserInterface.kicad_sch
```

Each subdir is a stand alone KiCAD project.

The top level project is
- for referencing the different schematics
- showing the dependencies between the different PCBs
- documentation
- generating a full bill of material

The sub project are used to build the separate PCB for the module itself.

## Libraries
KiCAD brings a set of libraries for footprints and symbols.

For this project we needed to build our own symbols.
To use these libs generate links to the lib files or fix path settings in KiCAD.
Project libs do not work as we just created multiple project using this libs.

Due to unknown licences we removed the symbols, footprints and 3D files from third parties.

## Install and Versions KiCAD
We selected this program because it was used to build the IO Baord for the compute module.
So this project serves as a good reference to start.

The Raspberry Pi foundation used the beta version which has some features needed to build the IO Board.
So we also use the beta version of KiCad v6.x.

To publish the data we checked the files with the current release (v7.0.5).
