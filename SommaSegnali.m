%%

% @function SommaSegnali.
% @brief Somma due segnali.
% @param original Segnale audio.
% @param originalHz Frequenza del primo segnale.
% @param noise Segnale audio.
% @param rumoreHz Frequenza del secondo segnale.
% @param noiseHz Durata espressa in secondi del segnale risultante.
% @param seconds Durata del segnale somma.
% @return values Valori del segnale somma.
% @return hz Frequenza del segnale somma.
% @return answer Valore attraverso il quale indichiamo se il segnale
%                risultante può essere o meno un caso d'uso.

%%

function [values, hz, answer] = SommaSegnali(original,   ...
                                             originalHz, ...
                                             noise,      ...
                                             noiseHz,    ...
                                             seconds)
    % Svolgo dei controlli preliminari sui segnali in ingresso:
    % 1) Verifico che la prima canzone sia più lunga dei secondi indicati;
    % 2) Verifico che la seconda canzone sia più lunga dei secondi indicati;
    % 3) Verifico che la frequenza di campionamento sia effettivamente di 
    %    di 44100.
    % 4) Verifico se la frequenza di campionamento di S1 è diversa da 
    %    quella di S2.
    if (length(original) < originalHz * seconds || ...    % 1
        length(noise) < noiseHz * seconds       || ...    % 2
        originalHz ~= 44100                     || ...    % 3
        originalHz ~= noiseHz)                            % 4
		
        values = [];
        hz = 0;
        answer = false;
    else
        % Taglio del primo segnale.
        % Rendo segnale mono, ovvero prendo un solo canale,
        % nello specifico, il sinistro.
        originalCut = original(1:originalHz*seconds, 1);
        % Taglio del secondo segnale.
        % Rendo segnale mono, ovvero prendo un solo canale,
        % nello specifico, il sinistro.
        noiseCut = noise(1:noiseHz*seconds, 1);
        % Somma dei segnali.
        result = originalCut + noiseCut;
        
        % @FIX Risultato./max(abs(Risultato))
        %      Warning: Data clipped when writing file.
        values = result./max(abs(result));
        hz = originalHz;
        answer = true;
    end
end
