clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43';'P44'; 'P45'}; 
Sessions     = {'01'; '02'; '03'};

% Conditions   = {'stimTapST'; 'stimTapDT';  'stimWalkST'; 'stimWalkDT';...
%                 'syncTapST'; 'syncTapDT';'syncWalkST'; 'syncWalkDT';};
Conditions   = {'stimTap'; 'stimWalk';...
                'syncTap'; 'syncWalk'};

varX = {'BTI'; 'BAT'; 'Flexibility'; 'Inhibition'; 'workingMemory'; 'power'; 'phaseR'; 'stabilityIndex'}; 
varY = {'imiMean'; 'imiCV'; 'phaseAngleMean'; 'resultantLength'; 'phaseErrorMean';'power'; 'phaseR'; 'stabilityIndex'};

xLabels = {'Beat Tracking Index'; 'Beat Perception (d'')';  'Flexibility'; 'Inhibition'; 'Working Memory'; 'Power (SNR)'; 'Inter-Trial Phase Coherence'; 'Stability Index (Hz)'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'; 'Synchronization Error (°)'; 'Power (SNR)'; 'Inter-Trial Phase Coherence'; 'Stability Index (Hz)'}';

corrType = 'Spearman';

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iX = 1:length(varX)
        xLabel = (xLabels{iX});

        for iY = 1:length(varY)
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)

                for iParticipant = 1:length(Participants)

                    % Load data
                     load([pathResults Participants{iParticipant} '/01/RESS/resultsEEG.mat'])
                     load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
                     load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])
                     load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCost.mat'])
                    
                     if strcmpi(varX{iX}, 'BTI') || strcmpi(varX{iX}, 'BAT')
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBAASTA.mat'])
                        dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX});
                    elseif strcmpi(varX{iX}, 'power') || strcmpi(varX{iX}, 'phaseR') || strcmpi(varX{iX}, 'stabilityIndex')
                         dataX(iParticipant,iCondition) = resultsDtCost.(Conditions{iCondition}).(varX{iX});
                    else
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsCog.mat'])
                        dataX(iParticipant,iCondition) = resultsCog.(varX{iX});
                    end          
                    dataY(iParticipant,iCondition) = resultsDtCost.(Conditions{iCondition}).(varY{iY});
%                     dataX(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varX{iX})  ;
%                     [p] = circ_rtest(deg2rad(resultsSync.(Conditions{iCondition}).phaseAngle)); % Check if uniformly distributed
%                     if p >= 0.05
%                         dataY(iParticipant,iCondition) = NaN;
%                     else
%                         dataY(iParticipant,iCondition) = resultsSync.(Conditions{iCondition}).(varY{iY})  ;
% %                         dataY(iParticipant,iCondition) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1-resultsSync.(Conditions{iCondition}).(varY{iY})));
%                     end

                end

            end
            
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, corrType)
%             sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/' corrType '/scoresCost/fig_' varY{iY} 'vs' varX{iX} '.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end