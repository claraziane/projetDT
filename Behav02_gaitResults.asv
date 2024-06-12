clear all; 
close all;
clc;

% Declare paths
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'Pilot02'; 'Pilot03'; 'Pilot04'};
Sessions     = {'01'; '02'};

Conditions   = {'stimWalk'; 'syncWalk'};
Comparisons  = {'ST'; 'DT'};

for iSession = 1%:length(Sessions)

    for iCondition = 1:length(Conditions)

        % Preallocate matrix
        imiCV = [];

        for iParticipant = 3:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsBehav.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                imiCV(iParticipant, iCompare) = resultsBehav.(condName).imiCV;

            end % End Comparisons

        end % End Participants

        % Plot
%         fig_resultsScatter(imiCV, Comparisons, Conditions{iCondition}, 'Inter-movement Interval Coefficient of Variation');

    end % End Conditions

end % End Sessions