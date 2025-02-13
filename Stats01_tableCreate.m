clear all;
close all;
clc;

% Declare paths
[ret, Computer] = system('hostname');
if strcmpi({Computer(end-5:end-1)}, 'BRAMS')
        pathResults = 'C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\Results\';
addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\CircStat2012a\')
else
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/CircStat2012a/');
end
Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'}; %; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'
Sessions     = {'01'; '02'};

effectListen     = {  'none'; 'stim'; 'sync'}; % 
effectMvt        = { 'Rest'; 'Tap'; 'Walk'}; %
effectDifficulty = {'ST'; 'DT'};

%Pre-allocating matrices
Subject = [];
Listen = [];
Mvt   = [];
Difficulty = [];
mvtVariability = [];
mvtIMI = [];
syncAccuracy = [];
syncError = [];
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
%                     mvtIMI          = [mvtIMI; resultsBehav.(condition{1,1}).imiMean];
%                     syncAccuracy    = [syncAccuracy; rad2deg(resultsSync.(condition{1,1}).phaseAngleMean)];
%                     syncError       = [syncError; rad2deg(resultsSync.(condition{1,1}).phaseErrorMean)];
%                     syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];
                    stabilityIndex  = [stabilityIndex; resultsEEG.(condition{1,1}).stabilityIndex];
                    power  = [power; resultsEEG.(condition{1,1}).power];
                    ITPC  = [ITPC; resultsEEG.(condition{1,1}).phaseR];
%    
                end

            end

        end

    end

end

% Convert to table format
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, stabilityIndex, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'stabilityIndex'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, mvtIMI, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'IMI'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, syncAccuracy, syncError, syncConsistency, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'syncAccuracy', 'syncError', 'syncConsistency'});
resultsTable = table(Subject, Listen, Mvt, Difficulty, stabilityIndex, power, ITPC, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty',  'stabilityIndex', 'Power', 'ITPC'});

writetable(resultsTable, [pathResults '/All/01/statsTableNEURO.csv'])