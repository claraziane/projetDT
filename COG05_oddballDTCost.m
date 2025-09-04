clear all; 
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};

Conditions   = { 'stimTap_DT'; 'syncTap_DT'; 'stimWalk_DT'; 'syncWalk_DT'}; %'stimRest_DT';
xLabels      = {    'stimTap';    'syncTap';    'stimWalk';    'syncWalk'}; %'stimRest';   
Comparisons = {'DT'};

iPlot = 1;

% Preallocate matrix
Cost   = nan(length(Participants),2);

for iParticipant = 1:length(Participants)

    pathImport = [pathResults Participants{iParticipant} '/01/'];
    load([pathImport 'resultsOddball.mat']);
    
    Cost(iParticipant,1) = resultsOddball.stimRest_DT - resultsOddball.syncWalk_DT;
    
end % End Participants
clusters = kmeans(resultsOddball.costDT(:,1), 2);

% Plot
plotScatter(Cost, Comparisons, xLabels, 'Dual-Task Cost');
saveas(figure(1), [pathResults '/All/01/Cognition/fig_oddDTCost.png'])

close all;