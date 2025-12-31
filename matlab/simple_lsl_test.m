% Get the list of all .xdf files in the current folder
folderPath = pwd; % Change to your folder path if needed
xdfFiles = dir(fullfile(folderPath, '*.xdf'));

% Loop through each .xdf file
for idx = 1:length(xdfFiles)
    % Load the current .xdf file
    filePath = fullfile(xdfFiles(idx).folder, xdfFiles(idx).name);
    [data, ~] = load_xdf(filePath);
    
    % Process the loaded data
    for i = 1:length(data)
        if ~strcmp(data{i}.info.name, 'TimestampStream')
            data{i}.time_series = []; % Remove time_series data
        end
    end
    
    % Save the modified data as a .mat file with the same name as .xdf
    [~, fileName, ~] = fileparts(xdfFiles(idx).name); % Get file name without extension
    save(fullfile(folderPath, [fileName, '.mat']), 'data');
end

disp('Processing completed. Modified .mat files saved.');
