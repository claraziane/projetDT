clear;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'};
Sessions     = {'01'; '02'};

Tests  = {'Flexibility'; 'Inhibition'; 'workingMemory'}; % Agnes' method
% Scores = {'FV3_EXT0', 'NaN'; 'GO2_ERT0', 'GO2_MDT0'; 'WM3_ERT0', 'WM3_OMT0'}; % Agnes' method
Scores = {'FV3_ERR0'; 'FV3_MDN0'; 'GO2_ERR0'; 'GO2_MDN0'; 'WM3_ERR0'; 'WM3_OMI0'};

%% Extract TAP scores
for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

%         % Path to store result structures
%         pathParticipant = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];

        % Create folder for participant's results if does not exist
        pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/');
        if ~exist(pathParticipant, 'dir')
            mkdir(pathParticipant)
        end

        % Load data
        dataTAP = readtable([pathData Participants{iParticipant} '/' Sessions{iSession} '/TAP/TAP.csv']);

        % Agnes' method
        %         for iTest = 1:length(Tests)

        %             if strcmpi(Tests{iTest}, 'Flexibility') == 1
        %                 resultsCog.(Tests{iTest}) = dataTAP.(Scores{iTest,1});
        %             else
        %                 resultsCog.(Tests{iTest}) = dataTAP.(Scores{iTest,1}) + dataTAP.(Scores{iTest,2});
        %             end

        %         end

        for iScore = 1:length(Scores)

            cogScores(iParticipant, iScore, iSession) = dataTAP.(Scores{iScore});

        end
        clear dataTAP

    end
    %             save([pathParticipant 'resultsCog'], 'resultsCog');

end

%% Z-score transform
for iSession = 1%:length(Sessions)
    for iScore = 1:length(Scores)
        cogScores(:, iScore, iSession) = zscore(cogScores(:, iScore, iSession));

    end
end

for iSession = 1%:length(Sessions)

    for iParticipant = 1:length(Participants)

        % Path to store result structures
        pathParticipant = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];

        iTest = 1;
        for iScore = 1:2:length(Scores)
            resultsCog.(Tests{iTest}) = (cogScores(iParticipant,iScore,iSession) + cogScores(iParticipant,iScore+1,iSession)) / 2;
            iTest = iTest+1;
        end
        save([pathParticipant 'resultsCog'], 'resultsCog');
        clear resultsCog

    end

end