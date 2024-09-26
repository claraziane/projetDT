clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'};
Sessions     = {'01'};
Conditions   = {'noneTapST'; 'noneWalkST';...
                'stimTapST'; 'stimWalkST';...
                'stimTapDT'; 'stimWalkDT';...
                'syncTapST'; 'syncWalkST';...
                'syncTapDT'; 'syncWalkDT'};
    
for iParticipant = length(Participants)

    for iSession = 1

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
