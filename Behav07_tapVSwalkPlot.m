clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P01'; 'P02'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'none'; 'stim'; 'stim'; 'sync'; 'sync'};
Compare      = {'ST'; 'ST'; 'DT'; 'ST'; 'DT'};

varX = {'imiMean'; 'imiCV'; 'cadence'};
varY = {'imiMean'; 'imiCV'; 'cadence'};

xLabels = {'Tap'};
yLabels = {'Walk'};
Titles = {'Inter-Movement Interval (ms)'; 'Coefficient of Variation_{Inter-Movement Interval}'; 'Cadence (movements per minute)'};

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iX = 1:length(varX)
        xLabel = (xLabels{1});

%         for iY = 1:length(varY)
            yLabel = (yLabels{1});

            for iCondition = 1:length(Conditions)
                condX = strcat(Conditions{iCondition}, 'Tap', Compare{iCondition});
                condY = strcat(Conditions{iCondition}, 'Walk', Compare{iCondition});
                
                for iParticipant = 1:length(Participants)

                    if strcmpi(varX{iX}, 'cadence')
                        % Load data
                        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
                        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);

                        dataX(iParticipant,iCondition) = Taps.(condX).(varX{iX});
                        dataY(iParticipant,iCondition) = Steps.(condY).(varX{iX});

                    else
                        % Load data
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBehav.mat'])

                        dataX(iParticipant,iCondition) = resultsBehav.(condX).(varX{iX});
                        dataY(iParticipant,iCondition) = resultsBehav.(condY).(varX{iX});

                    end

                end

            end
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Conditions, 'Spearman')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/fig_' varX{iX} '_tapVSwalk.png']);

            clear dataX dataY
            iFig = iFig+1;
% 
%         end

    end
    close all;

end