%% Compute EEG outcome measure 
% 1. Stability index
%   a. Filter RESS component
%   b. Transform filtered RESS into analytical signal using Hilbert transform
%   c. Compute phase angles
%   d. Extract instantaneous frequencies
%   e. Compute stability index (standard deviation of instantaneous frequencies)

clear;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';
addpath('/Users/claraziane/Documents/Académique/Informatique/tweetCodes/'); %Custom FIR check function
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/'); %For computing phase consistency

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'};
Sessions     = {'01'; '02'; '03'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';...
                              'syncTapDT'; 'syncWalkDT'};

for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        % Path to store result structures
        pathParticipant = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];

        % Load stimuli info
        load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/Behavioural/dataRAC.mat']);

%         if exist([pathResults Participants{iParticipant} '/'  Sessions{iSession} '/resultsEEG.mat'], 'file')
%             load([pathResults Participants{iParticipant} '/'  Sessions{iSession} '/resultsEEG.mat'])
%         end

        for iCondition = 1:length(Conditions)
           
            % Load data
            load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/EEG/' Conditions{iCondition} '_comp.mat']);
            
            %% ERP
            if strcmpi(Conditions{iCondition}(1:4), 'none') ~= 1
          
                beatOnset = RAC.(Conditions{iCondition}).beatOnset;
                beatCat   = RAC.(Conditions{iCondition}).beatCat;

                erpStandard   = NaN(1,1001);
                erpTargetLow  = NaN(1,1001);
                erpTargetHigh = NaN(1,1001);

                iS  = 1;
                iTL = 1;
                iTH = 1;

                for iBeat = 1:length(beatOnset)
                    if beatOnset(iBeat)-100 >= 1 && beatOnset(iBeat)+900 <= length(compTime)
                        if strcmpi(beatCat{iBeat}, 'Standard')
                            erpStandard(iS,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
                             iS = iS+1;
                        elseif strcmpi(beatCat{iBeat}, 'targetLow')
                            erpTargetLow(iTL,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
                            iTL = iTL+1;
                        elseif strcmpi(beatCat{iBeat}, 'targetHigh')
                            erpTargetHigh(iTH,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
                            iTH = iTH+1;
                        end
                    end
                end
                resultsEEG.([Conditions{iCondition}]).erpStandard = mean(erpStandard);
                resultsEEG.([Conditions{iCondition}]).erpTargetLow = mean(erpTargetLow);
                resultsEEG.([Conditions{iCondition}]).erpTargetHigh = mean(erpTargetHigh);
            end

            %% Power
            freqIndex = dsearchn(Hz', freqMax);
            snrMax = max(compSNR(freqIndex-5:freqIndex+5));
            
            %% Stability index

            % FIR-filter component
            firBand = [freqMax-sFWHM freqMax+sFWHM];
            firOrder = round(10*(freqEEG/firBand(1)));
            firTrans = .15;
            [firW] = firCheck(firBand, firOrder, firTrans, freqEEG, 0);
             
            % Filter component time-series to compute instantaneous frequencies
            compFiltered = [];
            compFiltered = filtfilt(firW,1,compTime);

            % Compute Hilbert Transform
            compHilbert = [];
            compHilbert = hilbert(compFiltered);

            % Extract phase angles at each step and beat
            compPhase = [];
            compPhase = angle(compHilbert);            
%             figure; plot(compPhase); hold on;

            eventPhase = [];
            eventPhase = compPhase(eventOnset);
%             plot(vertcat(eventOnset, eventOnset), [-3 3], 'r-'); hold on;
            phaseConsistency = circ_r(eventPhase, [], [], 2);
  
            % Convert phase angles to Hz
            compPhase = unwrap(compPhase);

            compPhaseHz = [];
            compPhaseHz = (freqEEG*diff(compPhase)) / (2*pi);

            % Apply a sliding moving median with a window width of 400 samples
            nOrder = 10;
            orders = linspace(10,400,nOrder)/2;
            orders = round(orders/(1000/freqEEG));
            
            phaseTemp = [];
            phaseMed = zeros(length(orders), length(compPhaseHz));
            for iOrder = 1:nOrder
                for iTime = 1:length(compPhaseHz)
                    phaseTemp = sort(compPhaseHz(max(iTime-orders(iOrder),1):min(iTime+orders(iOrder),length(compPhaseHz)-1)));
                    phaseMed(iOrder,iTime) = phaseTemp(floor(numel(phaseTemp)/2)+1);
                end
            end
            phaseMedFilt = [];
            phaseMedFilt = mean(phaseMed);

            % Compute stability index
            stabilityIndex = std(phaseMedFilt);

            % Plot instantaneous frequencies
            figure(2);
            time = linspace(0, round(length(phaseMedFilt)/freqEEG), length(phaseMedFilt));
            plot(time, compPhaseHz, 'r--'); hold on;
            plot(time, phaseMedFilt, 'k-'); hold on;
            set(gca, 'xlim', [time(1) time(end)]);
            limY = get(gca, 'ylim');
            plot([1 time(end)], [freqMax freqMax], 'color', [0.80,0.80,0.80]); hold on;
            legend({'Before moving median smoothing','After moving median smoothing',  'Mean step frequency'}, 'FontSize', 14); %'Before moving median smoothing',
            xlabel({'Time (s)'}, 'FontSize', 14), ylabel({'Frequency (Hz)'}, 'FontSize', 14);
            txt = (['Stability index = ' num2str(mean(stabilityIndex))]); dim = [.2 .5 .3 .3]; annotation('textbox',dim,'String',txt, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FitBoxToText','on', 'FontSize', 14);
            title('Instantaneous frequencies of the extracted component', 'FontSize', 16)
            saveas(figure(2), [pathParticipant '/' Conditions{iCondition} '/fig_ssepStabilityIndex.png']);

            % Store in results structure
            resultsEEG.([Conditions{iCondition}]).power          = snrMax;
            resultsEEG.([Conditions{iCondition}]).phase          = eventPhase;
            resultsEEG.([Conditions{iCondition}]).phaseMean      = circ_mean(eventPhase, [], 2);
            resultsEEG.([Conditions{iCondition}]).phaseStd       = circ_std(eventPhase, [], [], 2);
            resultsEEG.([Conditions{iCondition}]).phaseR         = phaseConsistency;
            resultsEEG.([Conditions{iCondition}]).stabilityIndex = stabilityIndex;   
               
            close all;
            clear comp2plot compSNR compTime eventOnset firW Hz time erpStandard erpTargetHigh erpTargetLow beatCat beatOnset

        end
        save([pathParticipant 'resultsEEG'], 'resultsEEG');
        clear resultsEEG RAC

    end

end

