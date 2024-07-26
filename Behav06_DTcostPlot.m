clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'Pilot07'; 'Pilot08'; 'Pilot09'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTap'; 'stimWalk';...
                'syncTap'; 'syncWalk'};

varX = {'Flexibility'; 'Inhibition'; 'workingMemory'};
varY = {'imiMean'; 'imiCV'; 'IBIDeviation'; 'phaseAngleMean'; 'resultantLength'; 'power'; 'phaseR'; 'stabilityIndex'};

xLabels = {'Flexibility'; 'Inhibition'; 'Working Memory'};
yLabels = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Interbeat Interval Deviations'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'; 'Power (SNR)'; 'Inter-Trial Phase Coherence'; 'Stability Index (Hz)'};

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iX = 1:length(varX)
        xLabel = (xLabels{iX});

        for iY = 1:length(varY)
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)
                %                 Titles = {Conditions{iCondition}};

                for iParticipant = 1:length(Participants)

                    % Load data
                    load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCost.mat'])
                    load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsCog.mat'])

                    dataX(iParticipant,iCondition) = resultsCog.(varX{iX});
                    dataY(iParticipant,iCondition) = resultsDtCost.(Conditions{iCondition}).(varY{iY});

                end

            end
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, 'Spearman')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/fig_' varY{iY} 'vs' varX{iX} '.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end