clear all;
close all;
clc;

% Declare paths
pathImport    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
addpath '/Users/claraziane/Documents/Académique/Informatique/projectFig'

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19'; 'P21'; 'P22'; 'P23'; 'P24'; 'P26'};
% Conditions   = {'stimTapST'; ...
%                 'stimTapDT'; ...
%                 'syncTapST'; ...
%                 'syncTapDT'; 'stimWalkST'; 'stimWalkDT';'syncWalkST';'syncWalkDT'};
Conditions   = {'stimTapST'; 'stimWalkST';...
                'stimTapDT'; 'stimWalkDT';...
                'syncTapST'; 'syncWalkST';...
                'syncTapDT'; 'syncWalkDT'};

Comparisons  = {'ST'; 'DT'};

mvtCV           = nan(length(Participants), 2, length(Conditions));
meanIMI         = nan(length(Participants), 2, length(Conditions));
meanPhase       = nan(length(Participants), 2, length(Conditions));
resultantLength = nan(length(Participants), 2, length(Conditions));
  
for iParticipant = 1:length(Participants)

    load([pathImport Participants{iParticipant} '/01/resultsBehav.mat']);
    load([pathImport Participants{iParticipant} '/01/resultsSync.mat']);

    for iCondition = 1:length(Conditions)

        IMI = [];
        IMI = resultsBehav.([Conditions{iCondition}]).IMI;
        if rem(length(IMI),2) ~= 0 % if length IMI is and odd number
            IMI(end) = [];
        end
        IMI = reshape(IMI, [], 2);

        phaseAngles = [];
        phaseAngles = deg2rad(resultsSync.([Conditions{iCondition}]).phaseAngle);
        if rem(length(phaseAngles),2) ~= 0 % if length IMI is and odd number
            phaseAngles(end) = [];
        end
        phaseAngles = reshape(phaseAngles, [], 2);

        for iTime = 1:size(mvtCV,2)
            imiStd = std(IMI(:,iTime));
            mvtCV(iParticipant, iTime, iCondition) = imiStd/mean(IMI(:,iTime));
            meanIMI(iParticipant, iTime, iCondition) = mean(IMI(:,iTime));
       
            meanPhase(iParticipant, iTime, iCondition) = circ_mean(phaseAngles((phaseAngles(:,iTime) ~=0),iTime), [], 1);
            meanError(iParticipant, iTime, iCondition) = circ_mean(abs(phaseAngles((phaseAngles(:,iTime) ~=0),iTime)), [], 1);
            RVL = [];
            RVL = circ_r(phaseAngles(:,iTime), [], [], 1);
            resultantLength(iParticipant, iTime, iCondition) = log(RVL ./ (1-RVL));
        end

    end
end

meanIMI   = reshape(meanIMI, length(Participants), []);
mvtCV     = reshape(mvtCV, length(Participants), []);
meanPhase = rad2deg(reshape(meanPhase, length(Participants), []));
meanError = rad2deg(reshape(meanError, length(Participants), []));
resultantLength = reshape(resultantLength, length(Participants), []);

plotScatter(meanIMI, Comparisons, Conditions, 'Mean IMI (ms)');    
plotScatter(mvtCV, Comparisons, Conditions, 'CV');    
plotScatter(meanPhase, Comparisons, Conditions, 'Phase Angles (°)'); 
plotScatter(meanError, Comparisons, Conditions, 'Synchronization Error (°)'); 
plotScatter(resultantLength, Comparisons, Conditions, 'Resultant Vector Length'); 
