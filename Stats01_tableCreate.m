clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04';'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'};
Sessions     = {'01'; '02'};

effectListen     = { 'none'; 'stim'; 'sync'};
effectMvt        = { 'Rest'; 'Tap'; 'Walk'}; 
effectDifficulty = {'ST'; 'DT'};

%Pre-allocating matrices
Subject = [];
Listen = [];
Mvt   = [];
Difficulty = [];
mvtVariability = [];
syncAccuracy = [];
syncConsistency = [];
stabilityIndex = [];
power = [];
ITPC = [];

for iParticipant = 1:length(Participants)
    load([pathResults Participants{iParticipant} '/01/resultsEEG.mat'])
%     load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
%     load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])

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

%                     mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];
%                     syncAccuracy    = [syncAccuracy; rad2deg(resultsSync.(condition{1,1}).phaseAngleMean)];
%                     syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];
                    stabilityIndex  = [stabilityIndex; resultsEEG.(condition{1,1}).stabilityIndex];
                    power  = [power; resultsEEG.(condition{1,1}).power];
                    ITPC  = [ITPC; resultsEEG.(condition{1,1}).phaseR];
   
                end

            end

        end

    end

end

% Convert to table format
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, stabilityIndex, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'stabilityIndex'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, syncAccuracy, syncConsistency, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'syncAccuracy', 'syncConsistency'});
resultsTable = table(Subject, Listen, Mvt, Difficulty, stabilityIndex, power, ITPC, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty',  'stabilityIndex', 'Power', 'ITPC'});

writetable(resultsTable, [pathResults '/All/01/statsTableNEURO.csv'])