clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/CircStat2012a/');


Participants = {'P01'; 'P02'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTapST'; 'stimWalkST'; 'syncTapST'; 'syncWalkST';...
    'stimTapDT'; 'stimWalkDT'; 'syncTapDT'; 'syncWalkDT'};

varX = {'resultantLength'; 'phaseAngleMean'}; %; 'BTI'
varY = {'BPM'};

xLabels = {'Synchronization Consistency (logit)'; 'Synchronization Accuracy (°)'};
yLabels = {'Heart Rate (BPM)'};

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
                    load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsSync.mat'])
                    load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsECG.mat'])

                    if strcmpi(varX{iX}, 'resultantLength')
                         dataX(iParticipant,iCondition) = log(resultsSync.(Conditions{iCondition}).(varX{iX}) ./ (1-resultsSync.(Conditions{iCondition}).(varX{iX})));          
                    else
                        dataX(iParticipant,iCondition) = rad2deg(resultsSync.(Conditions{iCondition}).(varX{iX}));
                    end
                    dataY(iParticipant,iCondition) = resultsECG.(Conditions{iCondition}).(varY{iY});

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