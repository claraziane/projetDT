clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTap'; ...
                'syncTap'; ...
                'stimWalk';...
                'syncWalk'};

varX = {'Errors'}; %; 'BTI'
varY = {'imiCV'; 'stabilityIndex'};

xLabels = {'Number of Errors'};
yLabels = { 'Coefficient of Variation_{Inter-Movement Interval}'; 'Stability Index (Hz)'};
 load('/Users/claraziane/Desktop/Errors.mat')               

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iX = 1%:length(varX)
        xLabel = (xLabels{iX});

        for iY = 1%:length(varY)
            yLabel = (yLabels{iY});

            for iCondition = 1:length(Conditions)
                %                 Titles = {Conditions{iCondition}};

                for iParticipant = 1:length(Participants)

                    % Load data
                    load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCost.mat'])
                        dataX(iParticipant,iCondition) = Errors(iParticipant,iCondition);

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