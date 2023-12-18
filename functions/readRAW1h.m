function [EEG, srateOrg] = readRAW1h(pathEGI, chans, varargin)


    % Input parser
    p = inputParser;
    addParameter(p, 'filesRAW', {} ,@iscell);
       
    % Varargin
    parse(p,varargin{:});
    filesRAW = p.Results.filesRAW;



    % Get .raw files of selected paths
    if isempty(filesRAW)
        files   = dir(fullfile(pathEGI, '*.raw'));
        filesRAW = {files.name};
    end
    
    % Preallocate variables
    tLoad  = tic;
    EEG_1h = int16([]);         % stores 1h of EEG (EGI saves 1h chunks of EEG) - .raw data is saved in int16
    EEG    = int16([]);         % the dataframe holding the raw EEG data    
    
    % Load the EEG data (which is in .raw files)
    fprintf('** Load [%d] .raw files..', length(filesRAW))   
    for iFile = 1:length(filesRAW)
        fprintf(' %d.. ', iFile)

        % Load the EEG data (which is in .raw files)
        [EEG_1h, srateOrg] = readEGI(fullfile(pathEGI, filesRAW{iFile}), chans);
        EEG = [EEG, EEG_1h];

    end  
    clear EEG_1h % big and not used anymore
    fprintf('Done!\n'); tLoad=toc(tLoad); % get time needed  
end

