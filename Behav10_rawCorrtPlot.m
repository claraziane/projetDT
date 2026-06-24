clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};
Conditions   = {'stimTapST'; 'syncTapST';  'stimWalkST'; 'syncWalkST';...
               'stimTapDT' ; 'syncTapDT';'stimWalkDT'; 'syncWalkDT';};
% Conditions   = {'noneTapST'; 'stimTapST';   'stimTapDT' ; 'syncTapST'; 'syncTapDT';...
%                'noneWalkST'; 'stimWalkST'; 'stimWalkDT'; 'syncWalkST'; 'syncWalkDT';};

varX = {'power'; 'phaseR'; 'stabilityIndex'; 'Flexibility'; 'Inhibition'; 'workingMemory';  'imiCV'}; 
varY = {'imiMean'; 'imiCV'; 'phaseAngleMean'; 'resultantLength'; 'phaseErrorMean'; 'IBIDeviation'; 'power'; 'phaseR'; 'stabilityIndex'};

xLabels = {'Power (SNR)'; 'Phase Coupling (logit)'; 'Stability Index (Hz)'; 'Flexibility'; 'Inhibition'; 'Working Memory'; 'Coefficient of Variation_{Inter-Movement Interval}'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'; 'Synchronization Error (°)'; 'Inter-Beat Interval Deviation'; 'Power (SNR)'; 'Phase Coupling (logit)'; 'Stability Index (Hz)'}';

corrType = 'Spearman';

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iX = 2%length(varX)
        xLabel = (xLabels{iX});

        for iY = 4
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)

                for iParticipant = 1:length(Participants)

                    % Load data
                     load([pathResults Participants{iParticipant} '/01/vBrainOnly/resultsEEG.mat'])
                     load([pathResults Participants{iParticipant} '/01/resultsSync.mat'])
                     load([pathResults Participants{iParticipant} '/01/resultsBehav.mat'])
                     
                     if strcmpi(varX{iX}, 'power') || strcmpi(varX{iX}, 'phaseR') || strcmpi(varX{iX}, 'stabilityIndex')
                        if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                            dataX(iParticipant,iCondition) = NaN;
                        else
                            if strcmpi(varX{iX}, 'phaseR')
                                phaseX = resultsEEG.(Conditions{iCondition}).(varX{iX});
                                dataX(iParticipant,iCondition)  = log(phaseX ./ (1-phaseX));
                              else
                                dataX(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varX{iX});
                            end
                        end
                     elseif strcmpi(varX{iX}, 'imiCV') 
                         dataX(iParticipant,iCondition) = resultsBehav.(Conditions{iCondition}).(varX{iX});
                     else
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsCog.mat'])
                        dataX(iParticipant,iCondition) = resultsCog.(varX{iX});
                     end
                    
                     if strcmpi(varY{iY}, 'power')  strcmpi(varY{iY}, 'stabilityIndex')
                         if strcmpi(resultsEEG.(Conditions{iCondition}).compKeep, 'N')
                             dataY(iParticipant,iCondition) = NaN;
                         end
                     end

                         if strcmpi(varY{iY}, 'imiMean') || strcmpi(varY{iY}, 'imiCV')
                             dataY(iParticipant,iCondition) = resultsBehav.(Conditions{iCondition}).(varY{iY});
                         elseif strcmpi(varY{iY}, 'power') || strcmpi(varY{iY}, 'stabilityIndex')
                             dataY(iParticipant,iCondition) = resultsEEG.(Conditions{iCondition}).(varY{iY})  ;
                         elseif strcmpi(varY{iY}, 'phaseR')
                             phaseY = resultsEEG.(Conditions{iCondition}).(varY{iY});
                             dataY(iParticipant,iCondition)  = log(phaseY ./ (1-phaseY));
                         elseif strcmpi(varY{iY}, 'resultantLength')
                             dataY(iParticipant,iCondition) = log(resultsSync.(Conditions{iCondition}).(varY{iY}) ./ (1- resultsSync.(Conditions{iCondition}).(varY{iY})));
                         elseif strcmpi(varY{iY}, 'IBIDeviation')
                             dataY(iParticipant,iCondition) = resultsSync.(Conditions{iCondition}).(varY{iY});
                         else
                             dataY(iParticipant,iCondition) = rad2deg(resultsSync.(Conditions{iCondition}).(varY{iY}));
                         end
                end

            end

            % If outliers should be replaced by NaNs
            [dataX] = removeOutliers(dataX);
            [dataY] = removeOutliers(dataY);
            
            % Plot
            [corrType] = plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, corrType);
%             sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/' corrType '/scoresRaw/fig_vBrainOnly_' varY{iY} 'vs' varX{iX} '_noOutliers.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end