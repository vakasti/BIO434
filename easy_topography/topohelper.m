function [] = topohelper(data, chanlocs, varargin)

    % =====================================================================
    % Helper function to make beautiful topoplots.
    %
    % Input variables:
    % data: 1D data vector, one value per channel
    % chanlocs: channel locations. Use EEGLAB function "readlocs" to load 
    %           channel locations into MATLAB, i.e. readlocs('locs128.loc')

    % Variable input arguments
    % maplimits:    Colorbar limits
    % plotchans:    Channels to plot
    % headrad:      Head radius
    % intrad:       Another radius
    % plotrad:      Another radius
    % markerchans:  Mark this channel
    % markerstyle:  With this symbol
    % makersize:    With this marker size
    % markercolor:  With this marker color
    % pchans:       Significant channels
    % iscolbar:     True -> show colorbar
    % electrodes:   Show electrodes?
    % iscollim:     Data limits indicated as numbers (min, max)

    % Input parser
    p = inputParser;
    addParameter(p, 'maplimits',   []);
    addParameter(p, 'plotchans',   setdiff(1:numel(chanlocs), [49 56 107 113, 126, 127]));
    addParameter(p, 'headrad',     .5);
    addParameter(p, 'intrad',      .5);
    addParameter(p, 'plotrad',     .5);
    addParameter(p, 'electrodes',  'on');    
    addParameter(p, 'markerchans',  []);
    addParameter(p, 'markersize',   10);
    addParameter(p, 'markerstyle', 'x');
    addParameter(p, 'markercolor', 'k');
    addParameter(p, 'pchans',       []);
    addParameter(p, 'sigsize'  ,    16);    
    addParameter(p, 'sigstyle',    '.');
    addParameter(p, 'sigcolor',    'w');    
    addParameter(p, 'iscolbar',   true);
    addParameter(p, 'colorset',     []);
    addParameter(p, 'iscollim',  false);
          
    % Create variables
    parse(p, varargin{:});
    for var = p.Parameters
        eval([var{1} '= p.Results.(var{1});']);
    end    

    % *********************************************************************

    % Data value limits
    if isempty(maplimits)
        maplimits = [min(data(plotchans)), max(data(plotchans))];
    end

    % Check how many NaN values come before the stimulation electrode
    % and adjust the location of the stimulation electrode accordingly
    nanchans = unique([setdiff(1:129, plotchans), find(isnan(data))']);
    for iCh = 1:length(markerchans)        
        markerchans(iCh) = markerchans(iCh) - sum(nanchans <= markerchans(iCh));
    end 

    % Do the same for significant electrodes
    sigchans = sort(pchans);
    for iCh = 1:length(sigchans)      
        sigchans(iCh) = pchans(iCh) - sum(nanchans <= pchans(iCh));
    end       

    % *** Topoplot ***
    topoplot(data, chanlocs, ...
        'plotchans', plotchans, ...
        'maplimits', maplimits, ...
        'style', 'map', ...
        'emarker2', {markerchans,markerstyle,markercolor,markersize}, ...
        'whitebk', 'on', ...
        'electrodes', electrodes, ...
        'headrad',headrad, 'intrad',intrad, 'plotrad',.5); % , 'colormap',c.cmap.(cmap)

    % Significant channels?
    if pchans
        topoplot(data, chanlocs, ...
            'plotchans', plotchans, ...
            'maplimits', maplimits, ...
            'style', 'map', ...
            'emarker2', {sigchans,sigstyle,sigcolor,sigsize}, ...
            'whitebk', 'on', ...
            'electrodes', electrodes, ...
            'headrad',headrad, 'intrad',intrad, 'plotrad',.5); % , 'colormap',c.cmap.(cmap)
    end    
             
    % Make pretty
    if ~isempty(maplimits) && isnumeric(maplimits)
        caxis(maplimits)
    end
    xlim([-.55 .55]) % To show the whole nose
    ylim([-.55 .6])  % To show the whole ear

    % Colormap
    if ~isempty(colorset)
        axis = gca;
        colormap(axis, colorset);
    end


    % Min Max values as numbers
    if iscollim
        write_colorbar_limits(maplimits);    
        iscolbar = 0; % Supress colorbar
    end    

    % Coloarbar
    if iscolbar
        p1 = get(gca, 'Position'); 
        cbar = colorbar();
        set(gca, 'Position', p1);        
    end

end