clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'Pilot02'; 'Pilot03'; 'Pilot04'};
Sessions     = {'01'; '02'};
Conditions   = {'stimWalkST'; 'stimWalkDT';...
                'syncWalkST'; 'syncWalkDT'};

for iParticipant = 3%1:length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        % Load behavioural data
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);

        for iCondition = 1:length(Conditions)

            % Extract acquisition frequency
            Freq = Steps.([Conditions{iCondition}]).sampFreq;

            % Tapping conditions
            if strcmpi(Conditions{iCondition}(5:7), 'Tap')

                %                 % Extracting inter-tap intervals
                %                 ITI = [];
                %                 ITI = Taps.([Conditions{iCondition}]).ITI;
                %                 ITI =  (ITI / Freq) * 1000; % Convert frames to ms
                %
                %                 % Computing coefficient of variability of inter-tap intervals
                %                 itiStd = std(ITI);
                %                 itiCV = itiStd/mean(ITI);
                %
                %                 % Storing results in structure
                %                 resultsGait.([Conditions{iCondition}]).ITI   = ITI;
                %                 resultsGait.([Conditions{iCondition}]).itiCV = itiCV;
                %
           
            % Gait conditions
            else

                % Extracting step onsets
                stepOnset = [];
                stepOnset = Steps.([Conditions{iCondition}]).stepOnsets;

                % Computing inter-mvt intervals
                IMI = [];
                IMI = diff(stepOnset);
                IMI = (IMI / Freq) * 1000; % Convert frames to ms

                % Computing coefficient of variability of inter-mvt intervals
                imiStd = std(IMI);
                imiCV = imiStd/mean(IMI);

            end

            % Storing results in structure
            resultsBehav.([Conditions{iCondition}]).IMI   = IMI;
            resultsBehav.([Conditions{iCondition}]).imiCV = imiCV;

        end % End Conditions

        % Save results
        save([pathExport 'resultsBehav.mat'], 'resultsBehav');

        clear resultsBehav Steps Taps

    end % End Sessions

end % End Participants
