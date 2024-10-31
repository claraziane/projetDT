clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTap'; 'stimWalk';...
                'syncTap'; 'syncWalk'};

varX = {'Flexibility'; 'Inhibition'; 'workingMemory'}; %'stabilityIndex'; ;  'BTI'
varY = {'imiCV'; 'phaseAngleMean'; 'resultantLength';}; %'imiMean';  'power'; 'phaseR'; 'stabilityIndex'

xLabels = {'Flexibility'; 'Inhibition'; 'Working Memory';}; % 'Stability Index (Hz)';  'Beat Tracking Index'
yLabels = { 'Coefficient of Variation_{Inter-Movement Interval}'; 'Synchronization Accuracy (°)'; 'Synchronization Consistency (logit)'}; %'Inter-Movement Interval (ms)'; 'Power (SNR)'; 'Inter-Trial Phase Coherence'; ; 'Stability Index (Hz)'

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
                    if strcmpi(varX{iX}, 'BTI')
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBAASTA.mat'])
                        dataX(iParticipant,iCondition) = resultsBAASTA.(varX{iX});
                    else
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsCog.mat'])
                        dataX(iParticipant,iCondition) = resultsCog.(varX{iX});
                    end
%                     dataX(iParticipant,iCondition) = resultsDtCost.(Conditions{iCondition}).(varX{iX});

                    dataY(iParticipant,iCondition) = resultsDtCost.(Conditions{iCondition}).(varY{iY});

                end

            end
            
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, 'Pearson')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/fig_' varY{iY} 'vs' varX{iX} '.png']);

            clear dataX dataY
            iFig = iFig+1;

        end

    end
    close all;

end