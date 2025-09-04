clear all;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12';...
                'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19'; 'P21'; 'P22'; 'P23'; 'P24';...
                'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35';...
                'P36'; 'P37'; 'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};
Conditions   = {'stimTapST'; 'syncTapST';  'stimWalkST'; 'syncWalkST';...
               'stimTapDT' ; 'syncTapDT';'stimWalkDT'; 'syncWalkDT';};


varX = {'BTI'; 'BAT'; 'pacedTap'; 'Anisochrony'; 'Adaptive' ; 'Adaptive'; 'Adaptive' ;'Adaptive'; 'Adaptive'; 'Adaptive'; 'Adaptive'}; 
xLabels = {'Beat Tracking Index';...
       'Beat Perception (d'')';...
       'Synchronization Consistency (logit)';...
       'Threshold (% of IOI)';...
       'Adaptation Index (acceleration trials)';...
       'Adaptation Index (deceleration trials)';...
       'Sensitivity Index (d'')_{IOI 30ms shorter}';...
       'Sensitivity Index (d'')_{IOI 30ms longer}';...
       'Sensitivity Index (d'')_{IOI 75ms shorter}';...
       'Sensitivity Index (d'')_{IOI 75ms longer}';...
       'Continuation CV_{Inter-Movement Interval}'};

varY = {'imiMean'; 'imiCV'; 'phaseAngleMean'; 'resultantLength'; 'stabilityIndex'};
yLabels = {'Inter-Movement Interval (ms)';...
    'Coefficient of Variation_{Inter-Movement Interval}';...
    'Synchronization Accuracy (°)';...
    'Synchronization Consistency (logit)';...
    'Stability Index (Hz)'}';

corrType = 'Spearman';
for iSession = 1:length(Sessions)
    iFig = 1;

    for iX = length(varX)
        xLabel = (xLabels{iX});

        for iY = 1:length(varY)
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)

                for iParticipant = 1:length(Participants)                    

                     % Extract BAASTA data from structure
                     load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/resultsBAASTA.mat'])
                     if strcmpi(varX{iX}, 'Adaptive')
                         if strcmpi(xLabels{iX}, 'Adaptation Index (acceleration trials)')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).indexAcceleration;
                         elseif strcmpi(xLabels{iX}, 'Adaptation Index (deceleration trials)')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).indexDeceleration;
                         elseif strcmpi(xLabels{iX}, 'Sensitivity Index (d'')_{IOI 30ms shorter}')     
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).sensitivityIndex1_m30;
                         elseif strcmpi(xLabels{iX}, 'Sensitivity Index (d'')_{IOI 30ms longer}')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).sensitivityIndex1_p30;
                         elseif strcmpi(xLabels{iX}, 'Sensitivity Index (d'')_{IOI 75ms shorter}')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).sensitivityIndex1_m75;
                         elseif strcmpi(xLabels{iX}, 'Sensitivity Index (d'')_{IOI 75ms longer}')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).sensitivityIndex1_p75;
                         elseif strcmpi(xLabels{iX}, 'Continuation CV_{Inter-Movement Interval}')
                             dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).continuationCV;
                         end
                     elseif strcmpi(varX{iX}, 'Anisochrony')
                         dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX}).thresholdBest;
                     elseif strcmpi(varX{iX}, 'pacedTap')
                         dataX(iParticipant,iCondition) = log(resultsBAASTA.(varX{iX}).vectorLength ./ (1- resultsBAASTA.(varX{iX}).vectorLength));
                     else
                         dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX});
                     end

                     % Extract Y variable
                     if strcmpi(varY{iY}, 'stabilityIndex')
                         load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/RESS/resultsEEG.mat'])
                         if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                             dataY(iParticipant,iCondition) = NaN;
                         else
                             dataY(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varY{iY})  ;
                         end
                     elseif strcmpi(varY{iY}, 'imiMean') || strcmpi(varY{iY}, 'imiCV')
                         load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/resultsBehav.mat'])
                         dataY(iParticipant,iCondition) = resultsBehav.(Conditions{iCondition}).(varY{iY});
                     else 
                         load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/resultsSync.mat'])
                         if strcmpi(varY{iY}, 'resultantLength')
                             dataY(iParticipant,iCondition) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1- resultsSync.(Conditions{iCondition}).(varY{iY})));
                         else
                             dataY(iParticipant,iCondition) = rad2deg(resultsSync.(Conditions{iCondition}).(varY{iY}));
                         end
                     end  
                end

            end
            
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, corrType)
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/BAASTA/' corrType '/fig_' varY{iY} 'vs' varX{iX} '_' xLabel{iX} '.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end