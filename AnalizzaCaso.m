%%

% @function AnalizzaCaso.
% @brief Cerca il valore di cross correlazione maggiore.
% @param xcorrValues I valori calcoltati per mezzo della
%                    cross-correlazione.
% @return prevision La canzone con la quale c'è più somiglianza.

%%

function [prevision] = AnalizzaCaso(xcorrValues)
    maxValue = 0;
    num = 1;
    
    for i = 1 : length(xcorrValues)
        maxCurrent = max(xcorrValues{i});
        
        if maxValue < maxCurrent
           maxValue = maxCurrent;
           num = i;
        end
    end
    
    prevision = num;
end
