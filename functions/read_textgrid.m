% Created by Chloe D. Kwon
% May 16, 2025
% Function to parse information from .TextGrid files
% Input: Textgrid file path
% Output: Struct with parsed textgrid info

function [tg] = read_textgrid(file_path)
dbstop if error

% open file
fid = fopen(file_path, 'r');
if fid == -1
    error('File not found: %s', file_path);
end

% Read all lines into cell array
lines = textscan(fid, '%s', 'Delimiter', '\n');
lines = lines{1};
fclose(fid);

% Initialize
tg = struct();
tg.tiers = {};  % cell array of tiers
found_tier = false;
interval_index = 0;
tier_counter = 0;
in_interval = false;
tier_data = struct();

for i = 1:length(lines)
    line = strtrim(lines{i});

    % Global xmin/xmax
    if startsWith(line, 'xmin =') && ~found_tier
        tg.xmin = str2double(extractAfter(line, '='));

    elseif startsWith(line, 'xmax =') && ~found_tier
        tg.xmax = str2double(extractAfter(line, '='));

    % Skip container header
    elseif strcmp(line, 'item []:')
        continue;

    % Start new tier
    elseif startsWith(line, 'item [')
        % Save previous tier if any
        if tier_counter > 0
            tg.tiers{end+1} = tier_data;
        end

        found_tier = true;
        tier_counter = tier_counter + 1;
        interval_index = 0;
        in_interval = false;
        tier_data = struct();
        tier_data.intervals = struct('xmin', {}, 'xmax', {}, 'text', {});
        tier_data.name = ['tier' num2str(tier_counter)];

    elseif startsWith(line, 'class =')
        class_val = extractBetween(line, '"', '"');
        tier_data.class = class_val{1};

    elseif startsWith(line, 'name =')
        name_val = extractBetween(line, '"', '"');
        if ~isempty(name_val) && ~isempty(name_val{1})
            tier_data.name = matlab.lang.makeValidName(name_val{1});
        end

    elseif contains(line, 'intervals [')
        interval_index = interval_index + 1;
        in_interval = true;

    elseif startsWith(line, 'xmin =') && in_interval
        tier_data.intervals(interval_index).xmin = str2double(extractAfter(line, '='));

    elseif startsWith(line, 'xmax =') && in_interval
        tier_data.intervals(interval_index).xmax = str2double(extractAfter(line, '='));

    elseif startsWith(line, 'text =') && in_interval
        txt = extractBetween(line, '"', '"');
        if isempty(txt)
            txt = {''};
        end
        tier_data.intervals(interval_index).text = txt{1};
        in_interval = false;
    end
end

% Save final tier
if isfield(tier_data, 'class')
    tg.tiers{end+1} = tier_data;
end


end
