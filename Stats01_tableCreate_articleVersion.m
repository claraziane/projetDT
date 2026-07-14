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
Sessions     = {'01'};

effectListen     = {'stim'; 'sync'}; 
effectMvt        = {'Tap'; 'Walk'}; 
effectDifficulty = {'ST'; 'DT'};

%Pre-allocating matrices
Subject = [];
Gender = [];
Age   = [];
yearsEducation = [];
yearsMusicInformal = [];
yearsMusicFormal = [];
Listen = [];
Mvt   = [];
Difficulty = [];
mvtVariability = [];
mvtIMI = [];
syncConsistency = [];
oddballErrors   = [];

% Load demographic info
dataDemog = readtable([pathResults 'All/demographicInfo.xlsx']);

for iParticipant = 1:length(Participants)
    load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])
    load([pathResults Participants{iParticipant} '/01/resultsOddball.mat']);

    for iListen = 1:length(effectListen)

        for iMvt = 1:length(effectMvt)

            for iDifficulty = 1:length(effectDifficulty)
                condition = strcat(effectListen(iListen), effectMvt(iMvt), effectDifficulty(iDifficulty));

                    Subject = [Subject ; {Participants{iParticipant}}];
                    for iLine = 1:size(dataDemog,1)
                        if strcmpi(dataDemog.ID{iLine}, Participants{iParticipant})
                            subjline = iLine;
                            break;
                        end
                    end
                    Age    = [Age; dataDemog.Age(subjline)];
                    Gender = [Gender; dataDemog.Genre(subjline)];
                    yearsEducation = [yearsEducation; dataDemog.YearsOfEducation(subjline)];
                   
                    yearsMusicInformal = [yearsMusicInformal; dataDemog.YearsOfMusicPractice(subjline)];
                    yearsMusicFormal   = [yearsMusicFormal; dataDemog.YearsOfFormalMusicPractice(subjline)];


                    if strcmpi({effectListen{iListen}}, 'stim') 
                        Listen     = [Listen; {'ignore'}];
                    elseif strcmpi({effectListen{iListen}}, 'sync') 
                        Listen     = [Listen; {'synchronize'}];
                    end

                    if strcmpi(effectMvt{iMvt,1}, 'Tap')
                        Mvt        = [Mvt; {'tapping'}];
                    elseif strcmpi(effectMvt{iMvt,1}, 'Walk')
                        Mvt        = [Mvt; {'walking'}];
                    end

                    if strcmpi({effectDifficulty{iDifficulty}}, 'ST')
                        Difficulty = [Difficulty; {'singleTask'}];
                        oddballErrors = [oddballErrors; NaN];
                    elseif strcmpi({effectDifficulty{iDifficulty}}, 'DT')
                        Difficulty = [Difficulty; {'oddball'}];
                        oddballErrors = [oddballErrors; resultsOddball.([(condition{1,1}(1:end-2)) '_DT'])];
                    end

                    mvtVariability  = [mvtVariability; resultsBehav.(condition{1,1}).imiCV];
                    mvtIMI          = [mvtIMI; resultsBehav.(condition{1,1}).imiMean];                                          
                    syncConsistency = [syncConsistency; log(resultsSync.(condition{1,1}).resultantLength ./ (1-resultsSync.(condition{1,1}).resultantLength))];

            end

        end

    end

end

% Convert to table format
resultsTable = table(Subject, Age, Gender, yearsEducation, yearsMusicInformal, yearsMusicFormal, Mvt, Listen, Difficulty, mvtIMI, mvtVariability, syncConsistency, oddballErrors,...
    'VariableNames', {'Participant', 'Age', 'Gender', 'Education (years)', 'Music Informal (years)', 'Music Formal (years)', 'Movement', 'Instruction', 'Cognitive Load', 'Mean IMI (ms)', 'CV', 'Sync Consistency (logit)', 'Oddball Errors'});
writetable(resultsTable, '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Articles/articleBehavioural/SUBMITTED/PsyArXiv/dataTable_EXP1_IMI_CV_syncConsistency_Cognition.csv')