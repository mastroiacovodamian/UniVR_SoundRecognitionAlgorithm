%%

% Martedì 19 Marzo 2019.
% Corso di Elaborazione Segnali ed Immagini.
% Percorso 1: progetto ESI.
% Sviluppo di un algoritmo di riconscimento delle canzoni.
% Partecipanti: Nicolò Lutteri;
%               Damian Mastroiacovo;
%               Luigi Capogrosso.

%%

% Pulisco la memoria di lavoro (Workspace).
clear all;
% Elimino tutte le figure presenti (Figures).
close all; 
% Ripulisco la finestra di comando (Command Window).
clc;

% Salvo il log in un file.
diary('log.txt');

% Variabile per l'esecuzione dell'elaborato in versione rapida.
lightVersion = true;

% @brief Verifico se la GPU è predisposta all'utilizzo di CUDA.
% @returns 1 (vero) o 0 (falso)
% accellerationGPU = parallel.gpu.GPUDevice.isAvailable;
accellerationGPU = false;

if accellerationGPU
    % Un oggetto gpuDevice rappresenta una GPU nel computer. 
    % È possibile utilizzare la GPU per eseguire codice MATLAB.
    gdev = gpuDevice;
    mem = gdev.AvailableMemory;
end

if accellerationGPU
   fprintf("Accellerazione GPU: Abilitata\n"); 
else
   fprintf("Accellerazione GPU: Disabilitata\n");
end

%% Caricamento dei file

% Carico i file *.mp3 della cartella Libreria.
% Qui sono contenute le canzoni.
library = CaricaMp3('Libreria');

% Carico i file *.mp3 dalla cartella Rumore.
% Qui sono contenute le canzoni che verranno trattate come rumore.
noise = CaricaMp3('Rumore');

%% Creazione della lista dei casi d'uso

% Creo i casi d'uso.
% Sommo per ogni rumore tutte le canzoni contenute in library.
% Per aumentare il numero dei casi d'uso creo questi di lunghezza diversa.
useCases = [];
for i = 1 : length(noise)
    for j = 1 : length(library)
        for z = 1 : 10
            [signal, hz, isValid] = SommaSegnali(library{j, 1}, ...
                                                 library{j, 2}, ...
                                                 noise{i, 1},   ...
                                                 noise{i, 2},   ...
                                                 z);

            if isValid
                % Alloco dinamicamente l'array casi ad ogni iterazione.
                useCases = [useCases ; {signal hz j z}];
                fprintf("Creato caso: %i.m4a\n", size(useCases, 1));
                fprintf("\tSomma fra rumore %i e canzone %i (%i [s])\n", ...
                        i, j, z);
                SalvaCaso(size(useCases, 1), signal, hz);
            else
                fprintf("Rifiutato caso:\n");
                fprintf("\tSomma tra rumore %i e canzone %i (%i [s])\n", ...
                        i, j, z);
            end
        end
    end
end

clear signal hz isValid;

%% Correlazione con i file della libreria

if lightVersion
    cycle = 3;
else
    cycle = length(useCases);
end

result = zeros(10, 2);
for i = 1 : cycle
    % Predispongo l'array di celle nel verranno salvati i soli confronti
    % del  brano i-esimo con tutte le canzoni della library.
    comparisons = cell(length(library), 1);
    for j = 1 : length(library)
        fprintf("Xcorr tra caso %i e brano libreria %i\n", i, j);
        
        if accellerationGPU
            % @function gpuArray
            % @brief Copia l'array dalla memoria di sistema (RAM) in quella
            % della GPU. Attraverso tale funzione MATLAB sa quindi che il 
            % lavoro deve essere svolto dalla GPU e non dalla CPU.
            comparisons{j} = xcorr(gpuArray(useCases{i, 1}),      ...
                                   gpuArray(library{j, 1}(:, 1)));
        else
            % @function xcorr.
            % @brief Effettua la cross-correlazione fra due segnali.
            % @param useCases{i, 1} Segnale 1.
            % @param library{j, 1}(:, 1) Segnale 2, utilizzando solo il 
            %                            il canale sinistro.
            % @return Il grado di somiglianza fra i due segnali.
            comparisons{j} = xcorr(useCases{i, 1}, library{j, 1}(:, 1)); 
        end
    end
    
    if accellerationGPU
        % La CPU attende la terminazione del lavoro da parte della GPU.
        wait(gdev);
        for j = 1 : length(library)
            % @function xcorr.
            % @brief Recupera l'array dalla GPU. Inoltre, pulisce anche
            %        la memoria della GPU.
            comparisons{j} = gather(comparisons{j});
        end
    else
        
    end
    
    % Analizzo i risulatti della cross correlazione.
    valuexcorr = AnalizzaCaso(comparisons);
    if (useCases{i, 3} == valuexcorr)
        result(useCases{i, 4}, 1) = result(useCases{i, 4}, 1) + 1;
        fprintf("%i Giusto [Risultato xcorr: %i]\n", i, valuexcorr);
    else
        result(useCases{i, 4}, 2) = result(useCases{i, 4}, 2) + 1;
        fprintf("%i Sbagliato [Risultato xcorr: %i]\n", i, valuexcorr);
    end
end

if accellerationGPU
    % Reset della memoria della GPU.
    gpuDevice(1);
end

%% Calcolo risultati

for z = 1 : size(result, 1)
    % Memorizzo i risultati corretti.
    right = result(z, 1);
    % Memorizzo i risultati errati.
    wrong = result(z, 2);
    % Calcolo del totale.
    total = right + wrong;
    % Calcolo del rapporto casi corretti su casi totali.
    percentage = right / total * 100;
    fprintf("Lunghezza: %i\nGiusti: %i\nSbagliati: %i\nRapporto: %i%%\n", ...   
                                                          z    ,       ...
                                                          right,       ...
                                                          wrong,       ...
                                                          fix(percentage));
end
