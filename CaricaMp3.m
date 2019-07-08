%%

% @function CaricaMp3.
% @brief Carica i file con estensione *.mp3 da una specifica cartella.
% @param folder Nome della cartella in cui sono contenuti i file audio.
% @return cellArray Array di celle (5 x 2) contente i valori della 
%                   canzone ed il campionamento della canzone.

%%

function [cellArray] = CaricaMp3(folder)
    % @function fullfile.
    % @brief Costruisco il path della cartella.
    % @param folder Nome della cartella.
    % @param *.mp3 Estensione dei file interessati.
    % @return Percorso relativo.
    filePattern = fullfile(folder, '*.mp3');
    
    % @function dir.
    % @brief Elenco i file nella corrente.
    % @param filePattern Percorso della cartella.
    % @return Struttura N x 1 con i campi:
    %         name;
    %         folder;
    %         date;
    %         bytes;
    %         isdir;
    %         datenum;
    theFiles = dir(filePattern);
    
    % @function cell.
    % @brief Crea un array di celle (tipo di dato in MATLAB).
    %        Si accede al contenuto delle celle indicizzando con { }. 
    % @param length(theFiles) Numero di righe.
    % @param 2 Numero di colonne.
    % @return L'array di celle vuote.
    tmp = cell(length(theFiles), 2);
    
    for k = 1 : length(theFiles)
        % Acquisisco il nome del file.
        baseFileName = theFiles(k).name;
        % Compongo il path completo per la canzone.
        fullFileName = fullfile(folder, baseFileName);
        fprintf(1, 'Lettura %s\n', fullFileName);

        % @function audioread.
        % @brief Legge il file audio.
        % @param fullFileName Percorso del file audio da leggere.
        % @return values Dati campionati (double).
        % @return hz Frequenza di campionamento in Hz.
        [values, hz] = audioread(fullFileName);
        
        tmp{k, 1} = values;
        tmp{k, 2} = hz;
    end
    
    cellArray = tmp;
end
