# validate-forced-alignment

A MATLAB-based toolkit to validate forced alignment outputs by comparing automatically aligned TextGrids against manually corrected ones. This tool is useful for researchers working in phonetics, linguistics, and speech processing who need to evaluate the accuracy of forced aligners.

## Overview

This repository provides a workflow to:

- Load and parse pairs of automatic and manual TextGrid files.
- Extract and align time boundaries for corresponding tiers.
- Compute deviations between label boundaries (words and phones).

## To be updated
- Compute deviation metrics and summary statistics.
- Output visual and tabular diagnostics of alignment accuracy.

## Use Case

You have a corpus of audio files and two sets of TextGrids:
- One from a **forced aligner** (e.g., Montreal Forced Aligner).
- One **manually corrected** by a human annotator.

This tool helps quantify **how closely the forced aligner output matches the manual ground truth**.

## How to run
Run the  `run.m` file in Matlab. 

## Directory Structure
validate-forced-alignment/
├── sample_data/
│ ├── manual/ # Folder with manually-aligned TextGrids
│ ├── auto/ # Folder with auto-aligned TextGrids
├── run.m # Main script to run the pipeline
├── functions/
│ ├── process_grids.m # Loads and pairs TextGrids into a .mat table
│ ├── compare_alignments.m # Computes deviations between manual and auto alignments
└── README.md

