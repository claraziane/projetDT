clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'P01'; 'P02'; 'P03'; 'P04';'P07'; 'P08'; 'P09'};
Sessions     = {'01'; '02'};

effectListen     = {'none'; 'stim'; 'sync'};
effectMvt        = {'Tap'; 'Walk'};
effectDifficulty = {'ST'; 'DT'};

%Pre-allocating matrices
Subject = [];
Listen = [];
Mvt   = [];
Difficulty = [];
mvtVariability = [];
stabilityIndex = [];

for iParticipant = 1:length(Participants)
    load([pathResults Participants{iParticipant} '/01/resultsEEG.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])

    for iListen = 1:length(effectListen)

        for iMvt = 1:length(effectMvt)

            for iDifficulty = 1:length(effectDifficulty)
                condition = strcat(effectListen(iListen), effectMvt(iMvt), effectDifficulty(iDifficulty));

                if strcmpi(effectListen{iListen}, 'none') && strcmpi(effectDifficulty{iDifficulty}, 'DT')
                else

                    Subject = [Subject ; {Participants{iParticipant}}];

                    Listen     = [Listen; {effectListen{iListen}}];
                    Mvt        = [Mvt; {effectMvt(iMvt)}];
                    Difficulty = [Difficulty; {effectDifficulty{iDifficulty}}];

                    mvtVariability = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];
                    stabilityIndex = [stabilityIndex; resultsEEG.(condition{1,1}).stabilityIndex];
   
                end

            end

        end

    end

end

% Convert to table format
resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, stabilityIndex, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'stabilityIndex'});

writetable(resultsTable, [pathResults '/All/01/statsTable.csv'])