function [chanlocs] = call_eeglab(path_eeglab)

    % Add path
    addpath(path_eeglab)

    % *** Add EEGLAB's functions correctly to MATLAB
    addedpaths = strsplit(path(), pathsep); % All paths in Matlab's set path
    if ~any(cellfun(@(x) contains(x, fullfile(path_eeglab , 'plugins')), addedpaths))
        
        % Checks if EEGLAB has previously been called in this session. If not,
        % call EEGLAB and close the pop-up window.
        eeglab; close;
    end

    % *** Add path for channel locations
    % You can then use readlocs('locs128.loc') to import channels
    function_path = matlab.desktop.editor.getActiveFilename;
    addpath(fullfile(function_path, 'Locfile'))
end