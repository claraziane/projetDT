clear all; 
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'};
Sessions     = {'01'; '02'};

Conditions   = {'noneTap'; 'stimTap'; 'syncTap'; 'noneWalk'; 'stimWalk'; 'syncWalk'};
Comparisons  = {'ST'; 'DT'};

for iSession = 1%:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    imiCV   = nan(length(Participants),length(Conditions)*length(Comparisons));
    imiMean = nan(length(Participants),length(Conditions)*length(Comparisons));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsBehav.mat']);
                
            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                if  strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
                else
                    imiCV(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiCV;
                    imiMean(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiMean;
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
   
    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/fig_mvtCV.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/fig_mvtIMI.png'])
    close all;

end % End Sessions