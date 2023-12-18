function [data] = add_markerchan_val(data, surrounding_chans)

    % Adds a further channel that is the average of the channels
    % surrounding the target channel
    if isrow(data)
        data = [data, mean(data(surrounding_chans))];
    else
        data = [data; mean(data(surrounding_chans))];
    end
end