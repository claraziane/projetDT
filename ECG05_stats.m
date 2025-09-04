clear;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35';...
                'P36'; 'P37'; 'P39'};

effectListen     = {'sync'}; %'none'; 'stim'; 'sync'
effectMvt        = {'Tap'}; %'Rest'; 'Tap'; 'Walk'
effectDifficulty = {'ST'}; %'ST'; 'DT'

%Pre-allocating matrices
Subject = [];
Listen = [];
Mvt   = [];
Difficulty = [];
mvtVariability = [];
syncAccuracy = [];
syncError = [];
syncConsistency = [];
% BAT = [];
RMSSD = [];
BPM = [];

for iParticipant = 1:length(Participants)
    load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsECG.mat'])
%     load([pathResults Participants{iParticipant} '/01/resultsBAASTA.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])

    for iListen = 1:length(effectListen)

        for iMvt = 1:length(effectMvt)

            for iDifficulty = 1:length(effectDifficulty)
                condition = strcat(effectListen(iListen), effectMvt(iMvt), effectDifficulty(iDifficulty));

                if strcmpi(effectListen{iListen}, 'none') && strcmpi(effectDifficulty{iDifficulty}, 'DT')
                elseif strcmpi(effectMvt{iMvt}, 'Rest') && strcmpi(effectListen{iListen}, 'Sync')            
                else

                    Subject = [Subject ; {Participants{iParticipant}}];

                    Listen     = [Listen; {effectListen{iListen}}];
                    Mvt        = [Mvt; {effectMvt(iMvt)}];
                    Difficulty = [Difficulty; {effectDifficulty{iDifficulty}}];
                    
                    % Sync variables
                    mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];

                    [p] = circ_rtest(deg2rad(resultsSync.(condition{1,1}).phaseAngle));
                    if p >= 0.05
                        syncAccuracy    = [syncAccuracy; NaN];
                        syncError       = [syncError; NaN];
                    else
                        syncAccuracy    = [syncAccuracy; rad2deg(resultsSync.(condition{1,1}).phaseAngleMean)];
                        syncError       = [syncError; rad2deg(resultsSync.(condition{1,1}).phaseErrorMean)];
                    end
                    syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];
    
                   % BAT
%                    BAT = [BAT; resultsBAASTA.BAT];

                   % RMSSD
%                    RMSSD = [RMSSD; resultsECG.(condition{1,1}).RMSSD];
                   BPM   = [BPM; resultsECG.noneRestST.BPM];

                end

            end

        end

    end

end

% Convert to table
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, syncAccuracy, syncError, syncConsistency, BAT, RMSSD, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'syncAccuracy', 'syncError', 'syncConsistency', 'BAT', 'RMSSD'});
resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, syncAccuracy, syncError, syncConsistency, BPM, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'syncAccuracy', 'syncError', 'syncConsistency', 'BPM'});

% Save
% writetable(resultsTable, [pathResults '/All/01/ECG/Rest/statsTableRMSSD_syncWalkDT.csv'])
writetable(resultsTable, [pathResults '/All/01/ECG/Rest/statsTableBPM_syncTapST.csv'])