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
    addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
end
Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'; '02'};

effectListen     = {'stim'; 'sync'}; %'none'; 'stim'; 'sync'
effectMvt        = {'Tap'; 'Walk'}; %'Rest'; 'Tap'; 'Walk'
effectDifficulty = {'ST'; 'DT'}; %'ST'; 'DT'

%Pre-allocating matrices
Subject = [];
Class   = [];
musicCategory = [];
yearsPractice   = [];
yearsFormal     = [];
Listen = [];
Mvt   = [];
Difficulty = [];
syncTap = [];
syncWalk = [];
syncDelta = [];
mvtVariability = [];
mvtIMI = [];
syncAccuracy = [];
syncError = [];
syncConsistency = [];
stabilityIndex = [];
power = [];
ITPC = [];

Flexibility = [];
Inhibition  = [];
workingMemory = [];
oddballCost = [];

BAT = [];
beatPerception = [];

BTI = [];
rhythmSkills = [];

% Load demographic info
dataDemog = readtable([pathResults 'All/demographicInfo.xlsx']);

for iParticipant = 1:length(Participants)
    load([pathResults Participants{iParticipant} '/01/RESS/resultsEEG.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsCog.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsDtCost.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsBAASTA.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsOddball.mat']);

    for iListen = 1:length(effectListen)

        for iMvt = 1:length(effectMvt)

            for iDifficulty = 1:length(effectDifficulty)
                condition = strcat(effectListen(iListen), effectMvt(iMvt), effectDifficulty(iDifficulty));

                if strcmpi(effectListen{iListen}, 'none') && strcmpi(effectDifficulty{iDifficulty}, 'DT')
                elseif strcmpi(effectMvt{iMvt}, 'Rest') && strcmpi(effectListen{iListen}, 'Sync')
             

                else

                    Subject = [Subject ; {Participants{iParticipant}}];
                    for iLine = 1:size(dataDemog,1)
                        if strcmpi(dataDemog.ID{iLine}, Participants{iParticipant})
                            subjline = iLine;
                            break;
                        end
                    end
                    Class = [Class; dataDemog.Classification(subjline)];
                    yearsPractice = [yearsPractice; dataDemog.YearsOfMusicPractice(subjline)];
                    yearsFormal   = [yearsPractice; dataDemog.YearsOfFormalMusicPractice(subjline)];

                    if dataDemog.YearsOfFormalMusicPractice(subjline) > 0
                        musicCategory = [musicCategory; 'musician'];
                    else
                        musicCategory = [musicCategory; 'nomusici'];
                    end

                    Listen     = [Listen; {effectListen{iListen}}];
                    Mvt        = [Mvt; {effectMvt(iMvt)}];
                    Difficulty = [Difficulty; {effectDifficulty{iDifficulty}}];

                    mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];
                    mvtIMI          = [mvtIMI; resultsBehav.(condition{1,1}).imiMean];                    
                      
                    % EEG variables
                    if strcmpi(resultsEEG.(condition{1,1}).compKeep, 'N')
                        power = [power; NaN];
                        ITPC = [ITPC; NaN];
                        stabilityIndex = [stabilityIndex; NaN];

                    else
                        stabilityIndex  = [stabilityIndex; resultsEEG.(condition{1,1}).stabilityIndex];
                        power  = [power; resultsEEG.(condition{1,1}).power];
                        ITPC  = [ITPC; resultsEEG.(condition{1,1}).phaseR];
                    end

                    %% Cognitive functions
                    Flexibility   = [Flexibility; resultsCog.Flexibility];
                    Inhibition    = [Inhibition; resultsCog.Inhibition];
                    workingMemory = [workingMemory; resultsCog.workingMemory];

                    %% Rhythmic Abilities
                    
                    [p] = circ_rtest(deg2rad(resultsSync.stimTapST.phaseAngle));
                    if p >= 0.05
                        syncTap = [syncTap; 'unsync'];
                    else
                        syncTap = [syncTap; 'issync'];
                    end

                    [p] = circ_rtest(deg2rad(resultsSync.stimWalkST.phaseAngle));
                    if p >= 0.05
                        syncWalk = [syncWalk; 'unsync'];
                    else
                        syncWalk = [syncWalk; 'issync'];
                    end

                    [p] = circ_rtest(deg2rad(resultsSync.(condition{1,1}).phaseAngle));
                    if p >= 0.05
                        syncAccuracy    = [syncAccuracy; NaN];
                        syncError       = [syncError; NaN];
                    else
                        syncAccuracy    = [syncAccuracy; rad2deg(resultsSync.(condition{1,1}).phaseAngleMean)];
                        syncError       = [syncError; rad2deg(resultsSync.(condition{1,1}).phaseErrorMean)];
                    end
                    syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];

                                       
                    [splitRVL] = findMedianSplit('resultantLength', 'syncTap', 'resultsDtCost');
                    if abs(resultsDtCost.syncTap.resultantLength) >= abs(splitRVL)
                        syncDelta = [syncDelta; 'Great'];
                    else
                        syncDelta = [syncDelta; 'Small'];
                    end

                    % BAT
                    BAT   = [BAT; resultsBAASTA.BAT];

                    % Classify participants based on beat perception
                    [splitBAT] = findMedianSplit('BAT', [], 'resultsBAASTA');
                    if resultsBAASTA.BAT > splitBAT
                        beatPerception = [beatPerception; 'Good'];
                    else
                        beatPerception = [beatPerception; 'Poor'];
                    end

                    % BTI
                    BTI   = [BTI; resultsBAASTA.BTI];
                    
                    % Classify participants based on BTI
                    [splitBTI] = findMedianSplit('BTI', [], 'resultsBAASTA');
                    if resultsBAASTA.BTI >= splitBTI
                        rhythmSkills = [rhythmSkills; 'Good'];
                    else
                        rhythmSkills = [rhythmSkills; 'Poor'];
                    end

                    % Classify participants based on their DT cost during odball
                    if resultsOddball.costDT >= 0
                        oddballCost = [oddballCost; 'restPoor'];
                    elseif resultsOddball.costDT < 0
                        oddballCost = [oddballCost; 'restBest'];
                    end

                end

            end

        end

    end

end

% Convert to table format
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, stabilityIndex, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'stabilityIndex'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, mvtVariability, mvtIMI, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'mvtVar', 'IMI'});
% resultsTable = table(Subject, Listen, Mvt, Difficulty, syncAccuracy, syncError, syncConsistency, 'VariableNames', {'Participants', 'Modality', 'Movement', 'Dfficulty', 'syncAccuracy', 'syncError', 'syncConsistency'});

% resultsTable = table(Subject, Class, yearsPractice, Listen, Mvt, Difficulty, syncTap, syncWalk, rhythmSkills, beatPerception, syncDelta, syncAccuracy, syncError, syncConsistency, mvtVariability, mvtIMI, Flexibility, Inhibition, workingMemory, BAT, BTI, 'VariableNames', {'Participants', 'Musicians', 'YearsOfMusicPractice', 'Instruction', 'Movement', 'Difficulty', 'SynchronizersTap', 'SynchronizersWalk', 'rhythmSkills', 'beatPerception', 'syncCost', 'syncAccuracy', 'syncError', 'syncConsistency', 'mvtVar', 'IMI', 'Flexibility', 'Inhibition', 'workingMemory', 'BAT', 'BTI'});

resultsTable = table(Subject, Class, yearsPractice, musicCategory, Listen, Mvt, Difficulty, syncTap, syncWalk, rhythmSkills, beatPerception, syncDelta, oddballCost, stabilityIndex, power, ITPC, syncAccuracy, syncError, syncConsistency, mvtVariability, mvtIMI, Flexibility, Inhibition, workingMemory, BAT, BTI, 'VariableNames', {'Participants', 'Musicians', 'YearsOfMusicPractice', 'musicCategory', 'Instruction', 'Movement', 'Difficulty', 'SynchronizersTap', 'SynchronizersWalk', 'rhythmSkills', 'beatPerception', 'syncCost', 'oddballCost', 'stabilityIndex', 'Power', 'ITPC', 'syncAccuracy', 'syncError', 'syncConsistency', 'mvtVar', 'IMI', 'Flexibility', 'Inhibition', 'workingMemory', 'BAT', 'BTI'});
writetable(resultsTable, [pathResults '/All/01/statsTable.csv'])