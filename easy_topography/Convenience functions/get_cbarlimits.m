function [limits] = get_cbarlimits(data, varargin)


    % Input parser
    p = inputParser;
    addParameter(p, 'zero_center', 1);
    addParameter(p, 'low_percentile', 1);
    addParameter(p, 'up_percentile', 99);
          
    % Create variables
    parse(p, varargin{:});
    for var = p.Parameters
        eval([var{1} '= p.Results.(var{1});']);
    end    


    % *** Compute limits
    % Find limits
    low_limit = prctile(abs(data), low_percentile);
    up_limit  = prctile(abs(data), up_percentile);
    
    % Set limits
    limits = [low_limit up_limit];


    % *** Center colorbar limits around 0
    if zero_center        

        % Take larger value
        max_limit = max(low_limit, up_limit);

        % Set limits to -/+ the larger limit
        limits = [-max_limit, max_limit];
    end

end