clear all;
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};

Conditions   = {'stimTap'; 'syncTap'; 'stimWalk'; 'syncWalk'};
Comparisons  = {'ST'; 'DT'};

% Preallocate matrix
rvlLogit         = nan(length(Participants),length(Conditions),length(Sessions));
IBI         = nan(length(Participants),length(Conditions),length(Sessions));
asyncMean   = nan(length(Participants),length(Conditions),length(Sessions));
asyncCI     = nan(length(Participants), 2, length(Conditions),length(Sessions));
phaseMean   = nan(length(Participants),length(Conditions),length(Sessions));
phaseCI     = nan(length(Participants), 2, length(Conditions),length(Sessions));
noSyncPhase = nan(length(Participants),length(Conditions),length(Sessions));
noSyncError = nan(length(Participants),length(Conditions),length(Sessions));

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
                [p] = circ_rtest(phaseAngle); % Check if uniformly distributed
                if p >= 0.05  % When participants do not synchronize, accuracy value is replaced by NaN
                    noSyncPhase(iParticipant, iPlot+iCompare-1, iSession) = rad2deg(phaseMean(iParticipant, iPlot+iCompare-1, iSession));
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession)   = NaN;
                    phaseCI(iParticipant, : , iPlot+iCompare-1, iSession) = NaN;
                else
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession) = rad2deg(phaseMean(iParticipant, iPlot+iCompare-1, iSession));
                    SEM = circ_std(phaseAngle) / sqrt(length(phaseAngle));
                    t = tinv([0.025 0.975], length(phaseAngle)-1);
                    phaseCI(iParticipant, : , iPlot+iCompare-1, iSession) = rad2deg(circ_mean(phaseAngle, [], 1) + t * SEM);
                    noSyncPhase(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                end            
           
                % Phase errors (in rad)
                phaseError = [];
                phaseError = deg2rad(resultsSync.(condName).phaseError);
                phaseErrorMean(iParticipant, iPlot+iCompare-1, iSession) = circ_mean(phaseError, [], 1);
                if p >= 0.05  % When participants do not synchronize, error value is replaced by NaN
                    noSyncError(iParticipant, iPlot+iCompare-1, iSession) = rad2deg(phaseErrorMean(iParticipant, iPlot+iCompare-1, iSession));
                    phaseErrorMean(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                    phaseErrorCI(iParticipant, : , iPlot+iCompare-1, iSession) = NaN;
                else
                    phaseErrorMean(iParticipant, iPlot+iCompare-1, iSession) = rad2deg(phaseErrorMean(iParticipant, iPlot+iCompare-1, iSession));
                    SEM = circ_std(phaseError) / sqrt(length(phaseError));
                    t = tinv([0.025 0.975], length(phaseError)-1);
                    phaseErrorCI(iParticipant, : , iPlot+iCompare-1, iSession) = rad2deg(circ_mean(phaseError, [], 1) + t * SEM);
                    noSyncError(iParticipant, iPlot+iCompare-1, iSession) = NaN;
                end

                % Resultant vector lengths
                rvlLogit(iParticipant, iPlot+iCompare-1, iSession) = log(resultsSync.(condName).resultantLength ./ (1-resultsSync.(condName).resultantLength));
                rvl(iParticipant, iPlot+iCompare-1, iSession) = resultsSync.(condName).resultantLength;

                % Inter-beat interval deviations
                IBI(iParticipant, iPlot+iCompare-1, iSession) = resultsSync.(condName).IBIDeviation;
            
            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % End Participants

    end % End Conditions
   
    %% Plot
%     plotScatter(RVL, Comparisons, Conditions, 'Synchronization Consistency (logit)');    
    plotScatter(rvlLogit, Comparisons, Conditions, 'Synchronization Consistency');    
    plotScatter(phaseMean, Comparisons, Conditions, 'Synchronization Accuracy (°)'); %, noSyncPhase
    plotScatter(IBI, Comparisons, Conditions, 'Interbeat Interval Deviations');
    plotScatterCI(asyncMean, asyncCI, Comparisons, Conditions, 'Asynchronies (ms)');
    plotScatterCI(phaseMean, phaseCI, Comparisons, Conditions, 'Phase Angles (°)');
    plotScatter(phaseErrorMean, Comparisons, Conditions, 'Synchronization Error (°)'); %, noSyncError
    plotScatter_doubleY(rvl, rvlLogit, Comparisons, Conditions, {'Synchronization Consistency (vector length)'; 'Synchronization Consistency (logit)'});      

    % Save
%     saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncConsistency_vectorLength.png'])
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncConsistency_Logit.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncAccuracy.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncIBI.png'])
    saveas(figure(4), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncAsyncCI.png'])
    saveas(figure(5), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncAccuracyCI.png'])
    saveas(figure(6), [pathResults '/All/' Sessions{iSession} '/Sync/fig_syncError.png'])
    
    close all;

end % End Sessions
