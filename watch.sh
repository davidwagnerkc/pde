#!/bin/bash
NOTEBOOK_FILE="pde-refiner.ipynb"
SLIDES_DIR="slides_output"
SLIDES_FILE="$SLIDES_DIR/$(basename "$NOTEBOOK_FILE" .ipynb).slides.html"
HTTP_SERVER_PID=0

convert_to_slides() {
  jupyter nbconvert "$NOTEBOOK_FILE" \
      --to slides \
      --output-dir="$SLIDES_DIR" \
      --SlidesExporter.reveal_theme=serif
  cp "$SLIDES_DIR/pde-refiner.slides.html" "$SLIDES_DIR/index.html"
}

start_http_server() {
  python -m http.server --directory "$SLIDES_DIR" 8000 &
  HTTP_SERVER_PID=$!
}

stop_http_server() {
  if [ $HTTP_SERVER_PID -ne 0 ]; then
    kill $HTTP_SERVER_PID
  fi
}

cleanup() {
  stop_http_server
  exit 0
}

trap cleanup INT
mkdir -p $SLIDES_DIR
convert_to_slides
start_http_server
fswatch -o "$NOTEBOOK_FILE" | while read f; do
  convert_to_slides
  echo "Converted slides after change detected at $(date)"
done

