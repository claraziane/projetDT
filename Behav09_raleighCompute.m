clear;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');


Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'};
Conditions   = {'syncTapST'; 'syncWalkST'};
  
for iCondition = 1:length(Conditions)

    for iParticipant = 1:length(Participants)

        load([pathResults '/' Participants{iParticipant} '/01/resultsSync.mat'])


        phaseAngles = deg2rad(resultsSync.([Conditions{iCondition}]).phaseAngle);
        [p(iParticipant,1,iCondition)] = circ_rtest(phaseAngles);
        [p(iParticipant,2,iCondition)] = circ_raotest(phaseAngles);

        r(iParticipant,iCondition) = resultsSync.([Conditions{iCondition}]).resultantLength;

        clear phaseAngles
    end

            figure; plot(p(:,1,iCondition), 'ksq'); hold on; 
                plot(p(:,2,iCondition), 'bsq'); ylabel('p-value'); xlabel('Participant'); 
            ax = gca; ax.FontSize = 14;
            title([Conditions{iCondition}])

            figure; plot(r(:,iCondition), 'ksq');  ylabel('Resultant Vector Length'); xlabel('Participant'); 
               ax = gca; ax.FontSize = 14;
            title([Conditions{iCondition}]); 

end