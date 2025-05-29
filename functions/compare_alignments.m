% Created by Chloe D. Kwon
% May 15, 2025
% This function compares auto vs. manual alignment.
% It requires a table with each row representing a token. 
% Outputs a table with boundary labels and deviations.

function [W, P] = compare_alignments(datatablePath, saveFolder)
dbstop if error

% Load data table
datatable = load(datatablePath); 
varNames = fieldnames(datatable); 
T = datatable.(varNames{1}); 

% Check number of files between manual & auto
% The number should match (for now) 
M = T.manual; 
A = T.auto; 
numFiles_manual = size(M, 1); 
numFiles_auto = size(A, 1); 

if numFiles_manual ~= numFiles_auto
    error('Unequal number of manually labeled and auto-labeled files.')
    % Add ways to handle this later
end

% Determine tier assignment
% I assume there are always only two tiers, word & phone
numLabels_tier1 = size(M.tier1{1},1); 
numLabels_tier2 = size(M.tier2{1},1); 

if numLabels_tier1 > numLabels_tier2 % word tier always has less intervals than phone tier
    wordTier_name = 'tier2'; phoneTier_name = 'tier1'; 
elseif numLabels_tier2 > numLabels_tier1
    wordTier_name = 'tier1'; phoneTier_name = 'tier2'; 
end

% Initialization for looping through files and calculating deviations
numFiles = size(M, 1); % Number of labeled files
W(numFiles,1) = struct(); % word level deviations
P(numFiles,1) = struct(); % phone level deviations

for f = 1:numFiles
    fname = M.fname{f}; 
    W(f).fname = fname; 
    P(f).fname = fname; 

    % Get word tier info
    wordTier_manual = M.(wordTier_name){f}; 
    wordTier_auto = A.(wordTier_name){f}; 
    wordTier_comparison = get_deviations(wordTier_manual, wordTier_auto, fname); 

    W(f).wordTier_manual = wordTier_manual; 
    W(f).wordTier_auto = wordTier_auto; 
    W(f).wordTier_comprison = wordTier_comparison; 

    % Get phone tier info
    phoneTier_manual = M.(phoneTier_name){f}; 
    phoneTier_auto = A.(wordTier_name){f}; 
    phoneTier_comparison = get_deviations(phoneTier_manual, phoneTier_auto, fname); 

    P(f).phoneTier_manual = phoneTier_manual; 
    P(f).phoneTier_auto = phoneTier_auto; 
    P(f).phoneTier_comparison = phoneTier_comparison; 
end

%save each tier info into a .mat file
save(fullfile(saveFolder, 'wordTier.mat'), 'W'); 
save(fullfile(saveFolder, 'phoneTier.mat'), 'P'); 

end

function [res] = get_deviations(manual, auto, fname)
% Function to calculate deviations
numLabel = size(manual.label, 1); 
dev = []; %boundary deviations (auto - manual)
boundaries = {}; %boundary labels (e.g., 'K A')
label_changed = []; % Did labels change? 

% Helper function to compute overlap between two intervals
overlap = @(a_min, a_max, b_min, b_max) max(0, min(a_max, b_max) - max(a_min, b_min));

if length(manual.label) == length(auto.label)
    % compare deviations by label index (not actual labels)
    % but for sanity check, see if labels are the same

    for i = 1:numLabel-1 
        label_manual = manual.label{i}; 
        label_auto = auto.label{i}; 

        t1_manual = manual.t1(i); 
        t1_auto = auto.t1(i); 

        dev(end+1,1) = t1_auto - t1_manual; 
        % Use manual labs when labels have changed
        % B/c better to analyze based on the "golden standard"
        boundaries{end+1} = [label_manual ' ' manual.label{i+1}]; 
        label_changed(end+1, 1) = ~strcmp(label_manual, label_auto); 
    end

    res = table(boundaries(:), dev(:), label_changed(:), ...
        'VariableNames', {'boundaries', 'dev', 'label_changed'}); 

else
    warning('Mismatch in number of labels for file %s.', fname)

    %Get the auto label that overlap the most with the manual label
    for i=1:length(manual.label)
        xmin_m = manual.t0(i); 
        xmax_m = manual.t1(i); 
        label_m = manual.label{i}; 

        % Find best matching auto interval
        max_ov = 0; 
        best_j = -1; 
        for j=1:length(auto.label)
            xmin_a = auto.t0(j); 
            xmax_a = auto.t1(j); 
            ov = overlap(xmin_m, xmax_m, xmin_a, xmax_a); 
            if ov > max_ov
                max_ov = ov; 
                best_j = j; 
            end
        end

        if best_j == -1, continue; end % No overlapping auto interval

        label_a = auto.label{best_j}; 
        dev_ij = auto.t1(best_j) - manual.t1(i); % Using end time diff 
        dev(end+1,1) = dev_ij; 
        boundaries{end+1} = [label_m ' ' manual.label{min(i+1, end)}]; 
        label_changed(end+1,1) = ~strcmp(label_m, label_a); 
    end

    res = table(boundaries(:), dev(:), label_changed(:), ...
        'VariableNames', {'boundaries', 'dev', 'label_changed'}); 

end


end