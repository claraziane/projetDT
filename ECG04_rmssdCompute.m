clear;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'P01'; 'P02'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';... 
                              'syncTapDT'; 'syncWalkDT'};

allRMSSD = NaN(length(Participants), length(Conditions));
for iParticipant = length(Participants)-1:length(Participants)

        pathImport = [pathResults Participants{iParticipant} '/01/'];
  
        % Load behavioural data
        load([pathImport '/resultsECG.mat']);
%         load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataRAC.mat']);

        for iCondition = 1:length(Conditions)
            IBI = resultsECG.([Conditions{iCondition}]).IBI;
            RMSSD = sqrt(mean(diff(IBI).^2));

            allRMSSD(iParticipant,iCondition) = RMSSD;
            resultsECG.([Conditions{iCondition}]).RMSSD = RMSSD;

            clear IBI RMSSD 
        end
        save([pathImport 'resultsECG.mat'], 'resultsECG')
        clear resultsECG

end
save([pathResults 'All/01/RMSSD.mat'], 'allRMSSD')
