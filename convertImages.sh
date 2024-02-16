#!/bin/bash

# Jobs of this script:
# 1. Create input and output folder
# 2. Move files into the input folder
# 3. Read files from the input folder.

# 4. Convert them to match
## a. 256 X 256 pixels  > for 001.png
## b. 64 X 64 pixels > for 001_64.png
## c. 128 X 128 pixels  > for 001_128.png
## d. 256 X 256 pixels  > for 001_256.png

# 5. Set TeamLogoAndColor.ini based on slots.txt file
# Sample format for slots.txt where team is the Name and 001.png (the tag) will be used as the logo:
# Team 001;001

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Global Variable
processed_images=0
converted_jpg=0
missing_images=()


# Function to create the Input folder and move source files
create_input_folder_and_move_files() {
  mkdir -p Input
  rm -r Output && mkdir -p Output
  rm -r OutputSPX &&  mkdir -p OutputSPX
  mv *.png Input/

  # Convert jpg and jpeg files to PNG and move them to the Input folder
  for file in Input/*.jpg Input/*.jpeg; do
    if [[ -f "$file" ]]; then
      new_file_name=$(basename "$file" | tr '[:upper:]' '[:lower:]' | sed 's/\(.*\)\..*/\1/') # Convert to lowercase and remove file extension
      convert "$file" "Input/${new_file_name}.png"
      ((converted_jpg++))
    fi
  done

  # Convert jpg and jpeg files in player pics to PNG
    for file in player_pics/*.jpg Input/*.jpeg; do
      if [[ -f "$file" ]]; then
        new_file_name=$(basename "$file" | tr '[:upper:]' '[:lower:]' | sed 's/\(.*\)\..*/\1/') # Convert to lowercase and remove file extension
        convert "$file" "player_pics/${new_file_name}.png"
      fi
    done
}

# Function to resize and center the image
resize_and_center_image() {
  input_file=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Convert every filename to lowercase
  output_size="$2"
  output_file_with_size="${input_file%.*}_${output_size}.png"
  output_file_without_size="${input_file%.*}.png"

  # Edit and save image with size information
  convert "Input/$input_file" -background none -gravity center -resize ${output_size}x${output_size} -extent ${output_size}x${output_size} "Output/$output_file_with_size"

  echo "Image $input_file processed and saved as $output_file_with_size."

  # Edit and save image without size information if the desired size is 256
  if [[ "$output_size" -eq 256 ]]; then
    convert "Input/$input_file" -background none -gravity center -resize 256x256 -extent 256x256 "Output/$output_file_without_size"
    echo "Image $input_file processed and saved as $output_file_without_size. and in OutputSPX folder"

    cp "Output/$output_file_without_size" "OutputSPX/$output_file_without_size"
  fi
}

remove_background_if_necessary() {
  local input_file=$1
  local output_file=$2

  echo $(identify -format '%[opaque]' "$input_file")
  if [[ $(identify -format '%[opaque]' "$input_file") == "True" ]]; then

     # Determine the most common color
     most_common_color=$(convert "$input_file" -format %c -depth 8 histogram:info:- | sort -n | tail -1 | sed -n 's/.*\(#.*\).*/\1/p')

     # Replace the most common color with transparency
     convert "$input_file" -fuzz 10% -transparent "$most_common_color" "${output_file}_transparent.png"
     echo "The most common color $most_common_color has been replaced with transparency."

    # store the source file as _src and move the transparent modifcation
     mv "$input_file" "${output_file}_src.png"
     mv "${output_file}_transparent.png" "${output_file}.png"

  else
     echo "The image already contains transparency. No change necessary."
  fi
}

# Step 1: Create Input folder and move the source files there
create_input_folder_and_move_files

# Step 2: Loop through the PNG files in the Input folder and process them
for file in Input/*.png; do
  if [[ -f "$file" ]]; then
    filename=$(basename "$file" .png) # Extract the filename without extension

    # Remove background
    remove_background_if_necessary "Input/${filename}.png" "Input/${filename}"

    resize_and_center_image "$filename.png" 256
    resize_and_center_image "$filename.png" 128
    resize_and_center_image "$filename.png" 64
    ((processed_images++))
  fi
done

# Step 3: Check if the slots.txt file exists and create the updated TeamLogoAndColor.ini
if [[ -f "slots.txt" ]]; then
  # Step 1: Read the content of TeamLogoAndColor_base.ini into TeamLogoAndColorBase
  cp TeamLogoAndColor_base.ini TeamLogoAndColor.ini

  TLAC=$(<TeamLogoAndColor.ini)
  teams=1

  # Step 2: Loop through the lines in slots.txt and replace the placeholders in TeamLogoAndColorBase
  while IFS=';' read -r team_name tag; do
    # Convert tag to lowercase
    tag_lower=$(echo "$tag" | tr '[:upper:]' '[:lower:]')

    if ! [[ -f "Input/${tag_lower}.png" ]]; then
      missing_images+=("$tag_lower")
    fi

    # Set logo files
    TLAC=$(echo "$TLAC" | sed -E "s#TeamLogoPath=C:/LOGO/(00|0)?$teams.png,#TeamLogoPath=C:/LOGO/$tag_lower.png,#g")
    TLAC=$(echo "$TLAC" | sed -E "s#KillInfoPath=C:/KILLINFO/(00|0)?$teams.png,#KillInfoPath=C:/LOGO/$tag_lower.png,#g")

    # Set team name
    TLAC=$(echo "$TLAC" | sed "s/TeamName=Team $teams,/TeamName=$team_name,/g")

    echo "Slot $teams with team $team_name and logo $tag_lower.png"

    # Increment the teamsIndex for the next iteration
    ((teams++))
  done < slots.txt

  # Step 3: Write TLAC variable to TeamLogoAndColor.ini file
  echo "$TLAC" > TeamLogoAndColor.ini

  echo -e "${GREEN}Processed $processed_images/$teams images. Converted $converted_jpg JPG to PNG.${NC}"

  if [ ${#missing_images[@]} -ne 0 ]; then
    echo -e "${RED}Missing images for slots: ${missing_images[*]}${NC}"
  else
    echo -e "${GREEN}All images are present for the slots.${NC}"
  fi
fi
