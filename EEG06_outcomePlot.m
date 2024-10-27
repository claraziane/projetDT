clear;
close all;
clc;

% Declare paths
pathProject = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/';
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1'); %EEGLab

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'};
Sessions     = {'01'}; %; '02'; '03'
Conditions   = {'noneTap'; 'stimTap'; 'syncTap'; 'noneWalk'; 'stimWalk'; 'syncWalk'}; %'noneRest'; 'stimRest';
Comparisons  = {'ST'; 'DT'};

% Preallocate matrix
compTopo       = nan(64, length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
Power          = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
phaseMean      = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
phaseCI        = nan(length(Participants), 2, length(Conditions)*length(Comparisons),length(Sessions));
ITPC           = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));
stabilityIndex = nan(length(Participants),length(Conditions)*length(Comparisons),length(Sessions));

eeglab;
for iSession = 1%:length(Sessions)
    iPlot = 1;
    iTopo = 17;
    iCond = 1;

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            pathPreproc = [pathProject 'DATA/Processed/' Participants{iParticipant} '/' Sessions{iSession} '/EEG/'];
            pathResults = [pathProject 'Results/' Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathResults 'resultsEEG.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                if  strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
                else

                    load([pathPreproc condName '_comp.mat'], 'comp2plot', 'chanLocs');

                    % Topoplots
                    compTopo(:, iParticipant, iPlot+iCompare-1, iSession) = comp2plot;

                    figure(iPlot+iCompare-1+1);
                    subplot(1,length(Participants), iParticipant);...
                        topoplot(comp2plot./max(comp2plot), chanLocs, 'maplimits', [-1 1], 'numcontour', 0, 'conv', 'off', 'electrodes', 'off', 'shading', 'interp'); hold on;
                    title(Participants{iParticipant})
                    sgtitle(condName, 'FontSize', 24, 'FontWeight', 'bold')

                    % Power
                    Power(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).power;

                    % Phase
                    Phase = [];
                    Phase = resultsEEG.(condName).phase;
                    phaseMean(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseMean;
                    SEM = resultsEEG.(condName).phaseStd / sqrt(length(Phase));
                    t = tinv([0.025 0.975], length(Phase)-1);
                    phaseCI(iParticipant, :, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseMean + t * SEM;

                    % ITPC
                    ITPC(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).phaseR;

                    % Stability Index
                    stabilityIndex(iParticipant, iPlot+iCompare-1, iSession) = resultsEEG.(condName).stabilityIndex;
                end

            end % end Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2;
            end

        end % end Participants

        % Plot average topo per condition
        iCompare = 1;
        for iTopo = iTopo+1:iTopo+2

            if strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
            else
                topoMean = mean(squeeze(compTopo(:,:,iCond,iSession)),2);

                figure(iTopo);
                topoplot(topoMean./max(topoMean), chanLocs, 'maplimits', [-1 1], 'numcontour', 0, 'conv', 'off', 'electrodes', 'off', 'shading', 'interp'); hold on;
                title([strcat(Conditions{iCondition}, Comparisons{iCompare})], 'FontSize', 24, 'FontWeight', 'bold')
                saveas(figure(iTopo), [pathProject 'Results/All/' Sessions{iSession} '/topoMean_' strcat(Conditions{iCondition}, Comparisons{iCompare}) '.png'])
            end
            iCond = iCond +1;
            iCompare = iCompare + 1;

        end


    end % end Conditions

    %% Plot
    plotScatter(Power, Comparisons, Conditions, 'Power (SNR)');
    plotScatterCI(phaseMean, phaseCI, Comparisons, Conditions, 'Phase (rad)');
    plotScatter(ITPC, Comparisons, Conditions, 'Inter-trial Phase Coherence');
    plotScatter(stabilityIndex, Comparisons, Conditions, 'Stability Index (Hz)');

    %% Save
    saveas(figure(2), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{1} Comparisons{1} '.png'])
    saveas(figure(4), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{2} Comparisons{1} '.png'])
    saveas(figure(5), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{2} Comparisons{2} '.png'])
    
    saveas(figure(6), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{3} Comparisons{1} '.png'])
    saveas(figure(8), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{4} Comparisons{1} '.png'])
    saveas(figure(9), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{4} Comparisons{2} '.png']) 
    saveas(figure(10), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{5} Comparisons{1} '.png'])
    saveas(figure(11), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{5} Comparisons{2} '.png'])
    
    saveas(figure(12), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{6} Comparisons{1} '.png']) 
    saveas(figure(14), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{7} Comparisons{1} '.png'])
    saveas(figure(15), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{7} Comparisons{2} '.png'])
    saveas(figure(16), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{8} Comparisons{1} '.png'])
    saveas(figure(17), [pathProject 'Results/All/' Sessions{iSession} '/topo_' Conditions{8} Comparisons{2} '.png'])

    saveas(figure(3), [pathProject 'Results/All/' Sessions{iSession} '/fig_eegPower.png'])
    saveas(figure(7), [pathProject 'Results/All/' Sessions{iSession} '/fig_eegPhase.png'])
    saveas(figure(13), [pathProject 'Results/All/' Sessions{iSession} '/fig_eegITPC.png'])
    saveas(figure(19), [pathProject 'Results/All/' Sessions{iSession} '/fig_eegStabilityIndex.png'])

    close all;

end % end Sessions