clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTapST'; 'stimWalkST';...
                'syncTapST'; 'syncWalkST';...
                'stimTapDT'; 'stimWalkDT';...
                'syncTapDT'; 'syncWalkDT'};
Variables    = {'imiCV'; 'imiMean'}; 

for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        % Load data
        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBehav.mat'])

        for iCondition = 1:length(Conditions)

            % DT cost calculation
            for iVar = 1:length(Variables)
                
                scoreST = resultsBehav.(['none' Conditions{iCondition}(5:end-2) 'ST']).([Variables{iVar}]);
                scoreDT = resultsBehav.([Conditions{iCondition}]).([Variables{iVar}]);

                resultsDtCost.(Conditions{iCondition}).(Variables{iVar}) = ((scoreDT - scoreST) / scoreST)*100; 

            end % end Variables

        end % end Conditions

        % Save results
        save([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCostNew'], 'resultsDtCost');
        
        clear resultsDtCost resultsBehav

    end % end Sessions

end % end Participants