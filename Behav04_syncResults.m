clear all;
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/CircStat2012a/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'};
Sessions     = {'01'; '02'};

Conditions   = {'stimTap'; 'syncTap'; 'stimWalk'; 'syncWalk'};
Comparisons  = {'ST'; 'DT'};

% Preallocate matrix
RVL       = nan(length(Participants),length(Conditions),length(Sessions));
IBI       = nan(length(Participants),length(Conditions),length(Sessions));
asyncMean = nan(length(Participants),length(Conditions),length(Sessions));
asyncCI   = nan(length(Participants), 2, length(Conditions),length(Sessions));
phaseMean = nan(length(Participants),length(Conditions),length(Sessions));
phaseCI   = nan(length(Participants), 2, length(Conditions),length(Sessions));

for iSession = 1%:length(Sessions)
    iPlot = 1;

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsSync.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                % Asynchronies
                Asynchrony = [];
                Asynchrony = resultsSync.(condName).Asynchrony;
                asyncMean(iParticipant, iPlot+iCompare-1, iSession) = mean(Asynchrony);
                SEM = std(Asynchrony) / sqrt(length(Asynchrony));
                t = tinv([0.025 0.975], length(Asynchrony)-1);
                asyncCI(iParticipant, :, iPlot+iCompare-1, iSession) = mean(Asynchrony) + t * SEM;

                % Phase angles (in rad)
                phaseAngle = [];
                phaseAngle = deg2rad(resultsSync.(condName).phaseAngle);
                phaseMean(iParticipant, iPlot+iCompare-1, iSession) = circ_mean(phaseAngle, [], 1); 
                phaseMean(iParticipant, iPlot+iCompare-1, iSession) = rad2deg(phaseMean(iParticipant, iPlot+iCompare-1, iSession));
                SEM = circ_std(phaseAngle) / sqrt(length(phaseAngle));
                t = tinv([0.025 0.975], length(phaseAngle)-1);
                phaseCI(iParticipant, : , iPlot+iCompare-1, iSession) = rad2deg(circ_mean(phaseAngle, [], 1) + t * SEM);

                % Resultant vector lengths
                RVL(iParticipant, iPlot+iCompare-1, iSession) = log(resultsSync.(condName).resultantLength ./ (1-resultsSync.(condName).resultantLength));

                % Inter-beat interval deviations
                IBI(iParticipant, iPlot+iCompare-1, iSession) = resultsSync.(condName).IBIDeviation;
            
            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % End Participants

    end % End Conditions
   
    %% Plot
    plotScatter(RVL, Comparisons, Conditions, 'Synchronization Consistency (logit)');    
    plotScatter(phaseMean, Comparisons, Conditions, 'Synchronization Accuracy (°)');
    plotScatter(IBI, Comparisons, Conditions, 'Interbeat Interval Deviations');
    plotScatterCI(asyncMean, asyncCI, Comparisons, Conditions, 'Asynchronies (ms)');
    plotScatterCI(phaseMean, phaseCI, Comparisons, Conditions, 'Phase Angles (°)');

    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/fig_syncConsistency.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/fig_syncAccuracy.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/fig_syncIBI.png'])
    saveas(figure(4), [pathResults '/All/' Sessions{iSession} '/fig_syncAsyncCI.png'])
    saveas(figure(5), [pathResults '/All/' Sessions{iSession} '/fig_syncAccuracyCI.png'])
    
    close all;

end % End Sessions
