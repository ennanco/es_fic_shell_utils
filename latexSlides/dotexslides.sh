#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# dotexslides.sh
#
# Build a simple Beamer presentation (slides.tex) from PNG screenshots.
#
# Usage:
#   1) Place this script in a directory containing:
#      - PNG screenshots (*.png)
#      - a 'begin' file with the LaTeX header/preamble
#      - an 'end' file with the LaTeX closing content
#   2) Run:
#        ./dotexslides.sh [FRAME_TITLE]
#      Example:
#        ./dotexslides.sh "My Demo Session"
#   3) The script will:
#      - remove previous crop*.png files
#      - rename PNG files replacing spaces with underscores
#      - crop each PNG to 1910x1060+0+150 using ImageMagick 'convert'
#      - generate slides.tex with one frame per cropped image
#
# Notes:
#   - If FRAME_TITLE is not provided, a default title is used.
#
# Requirements:
#   - bash
#   - ImageMagick (convert)
# -----------------------------------------------------------------------------

set -euo pipefail
shopt -s nullglob

frame_title="${1:-RNA-Seq Data Analysis with Galaxy}"

# Ensure ImageMagick 'convert' is available.
if ! command -v convert >/dev/null 2>&1; then
  echo "Error: 'convert' (ImageMagick) is not installed or not in PATH." >&2
  exit 1
fi

# Clean previous cropped images from earlier runs.
rm -f -- crop*.png

# Normalize input filenames and crop each PNG.
png_files=(*.png)
for file in "${png_files[@]}"; do
  safe_name="${file// /_}"
  if [[ "$file" != "$safe_name" ]]; then
    mv -- "$file" "$safe_name"
  fi

  convert -- "$safe_name" -crop 1910x1060+0+150 "crop_${safe_name}"
done

# Build slides.tex by combining begin + generated frames + end.
{
  cat begin

  crop_files=(crop*.png)
  for file in "${crop_files[@]}"; do
    echo "\\begin{frame}{$frame_title}"
    echo "\\includegraphics[height=5.8cm]{$file}"
    echo '\\centering'
    echo '\\end{frame}'
    echo
  done

  cat end
} > slides.tex
