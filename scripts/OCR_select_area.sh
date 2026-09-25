#!/usr/bin/env bash

if [ -z "$LANG" ]; then
  exit 0
fi

tmp_img=$(mktemp /tmp/ocr_XXXXXX.png)
trap 'rm -f "$tmp_img"' EXIT

grim -g "$(slurp)" - | \
  magick - \
  -alpha set -background white -alpha remove \
  -modulate 100,0 \
  -resize 300% \
  -density 300 \
  -bordercolor white -border 50x50 \
  -sharpen 0x1.5 \
  "$tmp_img"

easyocr -l ru en -f "$tmp_img" --detail=0 | wl-copy

# Needs grim, slurp, imagemagick, wl-clipboard and easyocr - `rei.desktopStack`
# brings all of them (hm-modules/desktop-stack.nix). easyocr downloads its
# models into ~/.EasyOCR on the first run.

