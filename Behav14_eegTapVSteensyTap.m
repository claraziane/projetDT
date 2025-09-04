clear;
close all;
clc;

% Declare paths
pathTreadmill  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathOverground = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectBehavioural/DATA/Processed/');
pathResults   = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P02'; 'P03'; 'P10'; 'P16'; 'P17'; 'P18';...
                'P19'; 'P21'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P29'; 'P30';...
                'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37'; 'P38'; 'P39';...
                'P40'; 'P41'; 'P44'};
treadmillCond  = {'noneTapST';  'stimTapDT'; 'syncTapST';  'syncTapDT'};
overgroundCond = {'noneTapST'; 'stimTapODD'; 'syncTapST'; 'syncTapODD'};
Comparisons  = {'Treadmill'; 'Overground'};

IMI = nan(length(Participants),(length(treadmillCond)+length(overgroundCond)));
imiCV = nan(length(Participants),(length(treadmillCond)+length(overgroundCond)));
syncConsistency = nan(length(Participants),(length(treadmillCond)-1+length(overgroundCond)-1));

iCond = 1;
for iParticipant = 1:length(Participants)
    treadmillData  = load([pathResults Participants{iParticipant} '/01/resultsBehav.mat']);
    treadmillSync  = load([pathResults Participants{iParticipant} '/01/resultsSync.mat']);
    overgroundData = load([pathOverground Participants{iParticipant} '/Events.mat']);
    overgroundSync = load([pathOverground Participants{iParticipant} '/dataSync.mat']);

    for iCondition = 1:2:length(treadmillCond)*2
        
        % Extract treadmill data
        IMI(iParticipant, iCondition)   = treadmillData.resultsBehav.(treadmillCond{iCond}).imiMean;
        imiCV(iParticipant, iCondition) = treadmillData.resultsBehav.(treadmillCond{iCond}).imiCV;

        % Extract overground data
        IMI(iParticipant, iCondition+1)   = mean(overgroundData.Events.(overgroundCond{iCond}).IMI);
        imiCV(iParticipant, iCondition+1) = overgroundData.Events.(overgroundCond{iCond}).imiCV;
        
        % Sync variables unavailable in silent conditions
        if iCond >= 2
            % Extract treadmill data
            syncConsistency(iParticipant, iCondition-2) = log(treadmillSync.resultsSync.(treadmillCond{iCond}).resultantLength ./ (1-treadmillSync.resultsSync.(treadmillCond{iCond}).resultantLength));
            
            % Extract overground data
            syncConsistency(iParticipant, iCondition-1) = log(overgroundSync.dataSync.(overgroundCond{iCond}).resultantLength ./ (1-overgroundSync.dataSync.(overgroundCond{iCond}).resultantLength));
        end

        if iCond == length(treadmillCond)
            iCond = 1;
        else
            iCond = iCond+1;
        end
    end

end

%Plot
plotScatter(imiCV, Comparisons, treadmillCond, 'Coefficient of Variation_{Inter-Movement Interval}');
plotScatter(IMI, Comparisons, treadmillCond, 'Inter-Movement Interval (ms)');
plotScatter(syncConsistency, Comparisons, treadmillCond(2:end), 'Synchronization Consistency');

% Save
saveas(figure(1), [pathResults '/All/01/treadmillVSoverground/fig_tapCV.png'])
saveas(figure(2), [pathResults '/All/01/treadmillVSoverground/fig_tapIMI.png'])
saveas(figure(3), [pathResults '/All/01/treadmillVSoverground/fig_tapSyncConsistency.png'])
