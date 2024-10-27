clear all; 
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'};
Sessions     = {'01'; '02'};

Conditions   = {'noneTap'; 'stimTap'; 'syncTap'; 'noneWalk'; 'stimWalk'; 'syncWalk'};
Comparisons  = {'ST'; 'DT'};

for iSession = 1%:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    imiCV   = nan(length(Participants),length(Conditions)*length(Comparisons));
    imiMean = nan(length(Participants),length(Conditions)*length(Comparisons));
    cadence = nan(length(Participants),length(Conditions)*length(Comparisons));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            % Load data
            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsBehav.mat']);
            load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
            load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                if  strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
                else
                    imiCV(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiCV;
                    imiMean(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiMean;

                    if strcmpi(Conditions{iCondition}(5:7), 'Tap')
                        cadence(iParticipant, iPlot+iCompare-1) = Taps.(condName).cadence;
                    elseif strcmpi(Conditions{iCondition}(5:8), 'Walk')
                        cadence(iParticipant, iPlot+iCompare-1) = Steps.(condName).cadence;
                    end

                end

            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2; 
            end

        end % End Participants

    end % End Conditions
    
    % Plot
    plotScatter(imiCV, Comparisons, Conditions, 'Coefficient of Variation_{Inter-Movement Interval}');
    plotScatter(imiMean, Comparisons, Conditions, 'Inter-Movement Interval (ms)');
    plotScatter(cadence, Comparisons, Conditions, 'Cadence (movements per minute)');

    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/fig_mvtCV.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/fig_mvtIMI.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/fig_mvtCadence.png'])
    close all;

end % End Sessions