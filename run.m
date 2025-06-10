% Created by Chloe D. Kwon
% May 29, 2025
% Change the path vars to adjust to your data structure

main_path = '/Users/chloekwon/Desktop/side_project/validate_forced_alignment'; % main directory path to subfolders with scripts and data
addpath(main_path); 

auto_path = fullfile(main_path, 'sample_data', 'auto'); %folder for auto-aligned textgrids
manual_path = fullfile(main_path, 'sample_data', 'manual'); %folder for manually-aligned textgrids
output_path = main_path; % where the result of process_grid() is saved

T = process_grids(manual_path, auto_path, output_path); % processes textgrids into a combined data table
[W,P] = compare_alignments(fullfile(output_path, 'grid_output.mat'), output_path); % compares and output boundary deviations for words (W) and phones (P)