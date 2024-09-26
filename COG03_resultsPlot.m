clear all; 
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'};
Sessions     = {'01'; '02'};

Conditions   = {'stimRest_DT'; 'stimTap_DT'; 'syncTap_DT'; 'stimWalk_DT'; 'syncWalk_DT'};
xLabels      = {'stimRest';    'stimTap';    'syncTap';    'stimWalk';    'syncWalk'};
Comparisons = {'DT'};

for iSession = 1%:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    Errors   = nan(length(Participants),length(Conditions));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsOddball.mat']);

            Errors(iParticipant, iCondition) = resultsOddball.(Conditions{iCondition});
               
        end % End Participants

    end % End Conditions
    
    % Plot
    plotScatter(Errors, Comparisons, xLabels, 'Number of Errors');
   
    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/fig_cogOddball.png'])
    close all;

end % End Sessions