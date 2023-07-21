# PUBG Mobile PCOB Logo and INI Generator

The script is designed to create team logos and an INI file for PUBG Mobile PCOB Client. It generates the required formats and naming conventions specified for the files. The problem this script solves is the need to have all logos in uniform sizes and file formats for PCOB. Often, logos are received in different sizes and formats, but PCOB requires consistency. This script simplifies and automates the manual work involved in achieving this.

## Features
- Automatically resizes and centers logo images to match specific dimensions (256x256, 128x128, and 64x64 pixels).
- Converts jpg and jpeg files to PNG format, ensuring uniformity for all logos.
- Generates the TeamLogoAndColor.ini file based on the information provided in the `slots.txt` file.
- Maintains the order of teams in the `slots.txt` file, which determines the slot order in the INI file.

## Usage
1. Place your logo images in the root folder or the `Input` folder.
2. If you want to generate the `TeamLogoAndColor.ini` file, make sure to have a `slots.txt` file containing information about the teams and their corresponding tags. The order of teams in `slots.txt` will also be the order of slots in the INI file. If you want to leave a slot empty, simply set its value to 0.
3. Run the script to process the logos and generate the INI file.

## Is it save?
No original logo file will get removed or overwritten. Everything moved into `Input` Folder.

## Dependencies
- The script uses ImageMagick (convert) for image processing tasks. Ensure you have ImageMagick installed on your system.

---
This script was developed by discord.gg/EuroElite to simplify the process of preparing team logos and generating the required INI file for PUBG Mobile PCOB Client. With this script, you can save time and effort by automating the conversion and formatting of logo images to meet the specific requirements of PCOB.

Happy logo generating!
