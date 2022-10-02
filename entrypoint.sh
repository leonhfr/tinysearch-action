#!/bin/sh -l

echo "::notice ::Create output directory if not existing"
mkdir -p "$INPUT_OUTPUT_DIR"

echo "::notice ::Building Tinysearch"
tinysearch "$INPUT_INDEX"

echo "::notice ::Copying selected output files"
for file_type in $INPUT_OUTPUT_TYPES
do
  cp -prv ./wasm_output/*.$file_type $INPUT_OUTPUT_DIR
done

rm -rf ./wasm_output
FILES_LIST=$(ls $INPUT_OUTPUT_DIR)
echo "::set-output name=files::$FILES_LIST"
