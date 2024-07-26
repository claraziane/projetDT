clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'Pilot02'; 'Pilot03'; 'Pilot04'; 'Pilot05'; 'Pilot06'; 'Pilot07'; 'Pilot08'; 'Pilot09'};
Sessions     = {'01'; '02'};
Conditions   = {'noneTapST'; 'noneWalkST';...
    'stimTapST'; 'stimWalkST';...
    'stimTapDT'; 'stimWalkDT';...
    'syncTapST'; 'syncWalkST';...
    'syncTapDT'; 'syncWalkDT'};

for iParticipant = 6:length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        % Load behavioural data
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);

        for iCondition = 1:length(Conditions)
            IMI = [];

            % Tapping conditions
            if strcmpi(Conditions{iCondition}(5:7), 'Tap')

                % Extract acquisition frequency
                Freq = Taps.([Conditions{iCondition}]).sampFreq;

                % Extracting inter-tap intervals
                IMI = Taps.([Conditions{iCondition}]).ITI;

            % Gait conditions
            else

                % Extract acquisition frequency
                Freq = Steps.([Conditions{iCondition}]).sampFreq;

                % Extracting step onsets   
                Onsets = [];
                Onsets = Steps.([Conditions{iCondition}]).stepOnsets;
                IMI = diff(Onsets); 
            end

            % Convert frames to ms                  
            IMI = (IMI / Freq) * 1000; 

            % Computing coefficient of variability of inter-mvt intervals
            imiStd = std(IMI);
            imiCV = imiStd/mean(IMI);

            % Storing results in structure
            resultsBehav.([Conditions{iCondition}]).IMI     = IMI;
            resultsBehav.([Conditions{iCondition}]).imiMean = mean(IMI);
            resultsBehav.([Conditions{iCondition}]).imiCV   = imiCV;

        end % End Conditions

        % Save results
        save([pathExport 'resultsBehav.mat'], 'resultsBehav');

        clear resultsBehav Steps Taps

    end % End Sessions

end % End Participants
