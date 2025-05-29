% Created by Chloe D. Kwon
% May 15, 2025
% Input: TextGrid directories for manual and automatic segmentation &
% output path
% Output: A data table saved in .mat 

function [T] = process_grids(manual_path, auto_path, output_path)
dbstop if error

%  Create grid list
manual_grids = dir(fullfile(manual_path, '*.TextGrid')); 
auto_grids = dir(fullfile(auto_path, '*.TextGrid')); 

% Check paths
if isempty(manual_grids) % check if manually aligned grids exist
    fprintf('No TextGrid files found in %s. Exiting function.\n', manual_path);
    T = [];
    return
end
if isempty(auto_grids) % check if forced aligned grids exist
    fprintf('No TextGrid files found in %s. Exiting function.\n', manual_path);
    T = []; 
    return
end

T = struct(); % Output

M = struct(); 
 for i=1:size(manual_grids,1)
    fname = manual_grids(i).name;
    folder = manual_grids(i).folder; 
    filepath = fullfile(folder, fname); 

    M(i).fname = fname; 
    M(i).folder = folder;

    tg = read_textgrid(filepath); 
    n_tier = length(tg.tiers); 

    for j=1:n_tier
        tier_name = tg.tiers{j}.name; 
        texts = {tg.tiers{j}.intervals.text}'; 
        xmins = [tg.tiers{j}.intervals.xmin]'; 
        xmaxs = [tg.tiers{j}.intervals.xmax]'; 

        tier_table = table(texts, xmins, xmaxs, ...
            'VariableNames', {'label', 't0', 't1'}); 

        M(i).(tier_name) = tier_table;
    end
 end

A = struct(); 
 for i=1:size(auto_grids,1)
    fname = auto_grids(i).name;
    folder = auto_grids(i).folder; 
    filepath = fullfile(folder, fname); 

    A(i).fname = fname; 
    A(i).folder = folder;

    tg = read_textgrid(filepath); 
    n_tier = length(tg.tiers); 

    for j=1:n_tier
        tier_name = tg.tiers{j}.name; 
        texts = {tg.tiers{j}.intervals.text}'; 
        xmins = [tg.tiers{j}.intervals.xmin]'; 
        xmaxs = [tg.tiers{j}.intervals.xmax]'; 

        tier_table = table(texts, xmins, xmaxs, ...
            'VariableNames', {'label', 't0', 't1'}); 

        A(i).(tier_name) = tier_table;
    end
 end
 
T.manual = struct2table(M); 
T.auto = struct2table(A); 
save(fullfile(output_path, 'grid_output.mat'), 'T')

end