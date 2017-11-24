# Semestral work KIV/OS

Minimalistic real mode Operating System - **FailOS** 

<p align="center">
  <img src="https://download.hornet-cz.com/public/FailOS.png" width="250px"/>
</p>

## Installation

For compilation use **nasm** (working with version 2.13.01) and you will have to install **qemu** (qemu-system-x86\_64, working with version 2.10.1)

## Run

In project directory do **make** and praise the KEK

## Features
* bootloader
* works in video mode with two fancy fonts and nice GUI
* primitive filesystem on second disk with 8 kB of free space (16 files by 512B)
* interactive filebrowser with doom style icon file size indicator
* working text editor with cursor, [A-Z] + [0-9] + ' ' chars
* independently driven clock on bottom of the screen
* Loyd's Fifteen game


## Controls
* **Arrows** for navigation
* **Enter** for choosing item/saving file in editor
* **PrtSc** for getting back in main menu

## Authors

* Petr &Scaron;techm&uuml;ller
* Anton&iacute;n Vrba
* Martin &Ccaron;ervenka

<p align="center">
<img src="https://download.hornet-cz.com/public/fos_menu.png" width="400px"/>
<img src="https://download.hornet-cz.com/public/fos_browser.png" width="400px"/>
<img src="https://download.hornet-cz.com/public/editor_save.png" width="400px"/>
<img src="https://download.hornet-cz.com/public/game.png" width="400px"/>
<img src="https://download.hornet-cz.com/public/info.png" width="400px"/>
</p>



