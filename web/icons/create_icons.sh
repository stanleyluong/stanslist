#!/bin/bash

# Create basic icons for PWA
# This script creates simple colored squares with "SL" text as placeholders

ICONS_DIR="/Users/stanleyluong/code/stanslist/web/icons"
mkdir -p "$ICONS_DIR"

# Make sure we have a favicon
cp "$(convert -size 32x32 xc:'#5468FF' -gravity center -pointsize 16 -fill white -annotate 0 "SL" PNG:-)" "/Users/stanleyluong/code/stanslist/web/favicon.png"

# Create standard icons
for size in 16 32 64 128 192 512; do
  convert -size ${size}x${size} xc:'#5468FF' -gravity center -pointsize $(($size/3)) \
    -fill white -annotate 0 "SL" "$ICONS_DIR/Icon-$size.png"
  
  # Create maskable versions for 192 and 512
  if [ "$size" -eq 192 ] || [ "$size" -eq 512 ]; then
    # Maskable icons need padding (safe zone is 40% of width)
    convert -size ${size}x${size} xc:'#5468FF' -gravity center -pointsize $(($size/4)) \
      -fill white -annotate 0 "SL" "$ICONS_DIR/Icon-maskable-$size.png"
  fi
done

echo "PWA icons created in $ICONS_DIR"
