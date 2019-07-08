%%

% @function SalvaCaso.
% @brief Crea il file audio con estensione *.m4a in una specifica cartella.
% @param num Il numero del caso audio.
% @param y Il segnale.
% @param fs La frequenza di campionamento.

%%

function SalvaCaso(num, y, fs)
    % Genero il nome del file.
    fileName = num + ".m4a";
    % Genero il path di destinazione.
    filePattern = fullfile('Casi', fileName);
    fprintf("\tSalvataggio del caso in %s\n", filePattern);
    
    % @function audiowrite.
    % @brief Crea un file audio.
    % @param filePattern il path del file.
    % @param y valori del segnale.
    % @param fs la frequenza di campionamento.
    audiowrite(filePattern, y, fs)
end
