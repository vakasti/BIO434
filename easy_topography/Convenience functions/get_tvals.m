function [tvals] = get_tvals(data)

    % *** This function performs a paired t-test and returns significant
    % channels. Can be used for the 'pchans' argument in topohelper.m. The
    % input data needs to be a channel x subject matrix.

    [h, p, ci, stats] = ttest(data'); 
    tvals = stats.tstat;
end