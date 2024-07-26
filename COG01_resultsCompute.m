clear;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';

Participants = {'Pilot07'; 'Pilot08'; 'Pilot09'; 'Pilot10'};
Sessions     = {'01'; '02'};

Tests  = {'Flexibility'; 'Inhibition'; 'workingMemory'};
Scores = {'FV3_EXT0', 'NaN'; 'GO2_ERT0', 'GO2_MDT0'; 'WM3_ERT0', 'WM3_OMT0'};

for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        % Path to store result structures
        pathParticipant = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
      
        % Create folder for participant's results if does not exist
        pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/');
        if ~exist(pathParticipant, 'dir')
            mkdir(pathParticipant)
        end

        % Load data
        dataTAP = readtable([pathData Participants{iParticipant} '/' Sessions{iSession} '/TAP/TAP.csv']);

        for iTest = 1:length(Tests)

            if strcmpi(Tests{iTest}, 'Flexibility') == 1
                resultsCog.(Tests{iTest}) = dataTAP.(Scores{iTest,1});
            else
                resultsCog.(Tests{iTest}) = dataTAP.(Scores{iTest,1}) + dataTAP.(Scores{iTest,2});
            end

        end
        save([pathParticipant 'resultsCog'], 'resultsCog');
       
        clear dataTAP resultsCog

    end
    
end