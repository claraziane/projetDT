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
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1'); %EEGLab

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};
Conditions   = {'noneRestST'; 'noneTapST'; 'stimTapST';  'stimTapDT';  'syncTapST'; 'syncTapDT';...
                'noneWalkST'; 'stimWalkST'; 'stimWalkDT'; 'syncWalkST';'syncWalkDT'}; %'stimRestST'; 'stimRestDT';...

eeglab;
for iParticipant = 10:length(Participants)

    for iSession = length(Sessions)

        % Path to store result structures
        pathParticipant = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/vBrainOnly/'];

        % Load stimuli info
        load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/Behavioural/dataRAC.mat']);
        load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/Behavioural/dataStep.mat']);
        load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/Behavioural/dataTap.mat']);

        if exist([pathResults Participants{iParticipant} '/'  Sessions{iSession} '/vBrainOnly/resultsEEG.mat'], 'file')
            load([pathResults Participants{iParticipant} '/'  Sessions{iSession} '/vBrainOnly/resultsEEG.mat'])
        end

        for iCondition = 5%:length(Conditions)

            % Not keeping components if EEG too noisy
            if strcmpi(Participants{iParticipant}, 'P40') && strcmpi(Conditions{iCondition}, 'stimTapDT')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P40') && strcmpi(Conditions{iCondition}, 'syncTapST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P40') && strcmpi(Conditions{iCondition}(5:8), 'Walk')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P39') && strcmpi(Conditions{iCondition}(5:8), 'Walk')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P17') && strcmpi(Conditions{iCondition}, 'syncWalkDT')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P02') && strcmpi(Conditions{iCondition}, 'stimRestST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P03') && strcmpi(Conditions{iCondition}, 'stimRestDT')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P39') && strcmpi(Conditions{iCondition}(5:8), 'Rest')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P40') && strcmpi(Conditions{iCondition}(5:8), 'Rest')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P39') && strcmpi(Conditions{iCondition}, 'noneTapST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P01') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P03') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P11') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P13') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P22') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P36') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P41') && strcmpi(Conditions{iCondition}, 'noneWalkST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';
            elseif strcmpi(Participants{iParticipant}, 'P11') && strcmpi(Conditions{iCondition}, 'noneRestST')
                resultsEEG.([Conditions{iCondition}]).compKeep = 'N';

            else

            % Load data
            load([pathData Participants{iParticipant} '/'  Sessions{iSession} '/EEG/' Conditions{iCondition} '_compBrainOnly.mat']);

            figure(2), clf
            xlim = [0.5 8];
            subplot(2,1,1); topoplot(comp2plot./max(comp2plot),chanLocs,'maplimits',[-1 1],'numcontour',0,'electrodes','on','shading','interp');
            title([ 'Component at ' num2str(freqMax) ' Hz' ], 'FontSize', 14);
            subplot(2,2,[3:4]); plot(Hz,compSNR,'ko-','linew',1,'markersize',5,'markerface','w'); hold on;
            set(gca,'xlim',xlim); xlabel('Frequency (Hz)', 'FontSize', 14), ylabel('SNR', 'FontSize', 14); clear xlim

            
%             %% ERP
%             if strcmpi(Conditions{iCondition}(1:4), 'none') ~= 1
%           
% %                 beatOnset = RAC.(Conditions{iCondition}).beatOnset;
%                 beatCat   = RAC.(Conditions{iCondition}).beatCat;
% 
%                 erpStandard   = NaN(1,1001);
%                 erpTargetLow  = NaN(1,1001);
%                 erpTargetHigh = NaN(1,1001);
% 
%                 iS  = 1;
%                 iTL = 1;
%                 iTH = 1;
% 
%                 for iBeat = 1:length(beatOnset)
%                     if beatOnset(iBeat)-100 >= 1 && beatOnset(iBeat)+900 <= length(compTime)
%                         if strcmpi(beatCat{iBeat}, 'Standard')
%                             erpStandard(iS,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
%                              iS = iS+1;
%                         elseif strcmpi(beatCat{iBeat}, 'targetLow')
%                             erpTargetLow(iTL,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
%                             iTL = iTL+1;
%                         elseif strcmpi(beatCat{iBeat}, 'targetHigh')
%                             erpTargetHigh(iTH,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+900);
%                             iTH = iTH+1;
%                         end
%                     end
%                 end
%                 resultsEEG.([Conditions{iCondition}]).erpStandard = mean(erpStandard);
%                 resultsEEG.([Conditions{iCondition}]).erpTargetLow = mean(erpTargetLow);
%                 resultsEEG.([Conditions{iCondition}]).erpTargetHigh = mean(erpTargetHigh);
%             end

            %% Power
            freqIndex = dsearchn(Hz', freqMax);
%             snrMax = max(compSNR(freqIndex-5:freqIndex+5)); %Method used in original draft
            snrMax = sum(compSNR(freqIndex-1:freqIndex+1));
            
            %% Stability index

            % FIR-filter component
            firBand = [freqMax-sFWHM freqMax+sFWHM];
            firOrder = round(10*(freqEEG/firBand(1)));
            firTrans = .15;
            [firW] = firCheck(firBand, firOrder, firTrans, freqEEG, 1);
             
            % Filter component time-series to compute instantaneous frequencies
            compFiltered = [];
            compFiltered = filtfilt(firW,1,compTime);

            % Compute Hilbert Transform
            compHilbert = [];
            compHilbert = hilbert(compFiltered);

            % Extract phase angles at each step and beat
            compPhase = [];
            compPhase = angle(compHilbert);            
            figure; plot(compPhase); hold on;
%%            
            eventOnset = [];
%             if strcmpi(Conditions{iCondition}(5:8), 'Walk')
%                 eventOnset = Steps.([Conditions{iCondition}]).stepOnsets;
%                 eventOnset = round(eventOnset * (500/Steps.([Conditions{iCondition}]).sampFreq));
%             elseif strcmpi(Conditions{iCondition}(5:7), 'Tap')
%                 eventOnset = Taps.([Conditions{iCondition}]).tapOnset;
%                 eventOnset = round(eventOnset * (500/Taps.([Conditions{iCondition}]).sampFreq));
%             end
%             eventOnset(eventOnset > length(compTime)) = [];
            eventPhase = [];
%             eventPhase = compPhase(eventOnset);
            eventPhase = compPhase(beatOnset);
           %%
            plot(vertcat(beatOnset, beatOnset), [-3 3], 'k-'); hold on;
            phaseConsistency = circ_r(eventPhase, [], [], 2);

%             %Computing ITPC with different method
%             for iBeat = 1:length(beatOnset)
%                 newComp(iBeat,:) = compTime(1,beatOnset(iBeat)-100:beatOnset(iBeat)+400);
%                 beatFFT(iBeat,:) = fft(newComp(iBeat,:), fftRes);
%                 newFFT(iBeat,:) = beatFFT(iBeat,:) ./ abs(beatFFT(iBeat,:));
%             end
%             meanFFT = abs(mean(newFFT,1));
%             newITPC = meanFFT(freqIndex);
%   
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
            figure(3);
            time = linspace(0, round(length(phaseMedFilt)/freqEEG), length(phaseMedFilt));
            plot(time, compPhaseHz, 'r--'); hold on;
            plot(time, phaseMedFilt, 'k-'); hold on;
            set(gca, 'xlim', [time(1) time(end)]);
            limY = get(gca, 'ylim');
            plot([1 time(end)], [freqMax freqMax], 'color', [0.80,0.80,0.80]); hold on;
            legend({'Before moving median smoothing','After moving median smoothing',  'Beat frequency'}, 'FontSize', 14); %'Before moving median smoothing',
            xlabel({'Time (s)'}, 'FontSize', 14), ylabel({'Frequency (Hz)'}, 'FontSize', 14);
            txt = (['Stability index = ' num2str(mean(stabilityIndex))]); dim = [.2 .5 .3 .3]; annotation('textbox',dim,'String',txt, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FitBoxToText','on', 'FontSize', 14);
            title('Instantaneous frequencies of the extracted component', 'FontSize', 16)            
%             saveas(figure(3), [pathParticipant '/' Conditions{iCondition} '/fig_ssepStabilityIndex.png']);

%             % Store in results structure
%             resultsEEG.([Conditions{iCondition}]).power          = snrMax;
%             resultsEEG.([Conditions{iCondition}]).phase          = eventPhase;
%             resultsEEG.([Conditions{iCondition}]).phaseMean      = circ_mean(eventPhase, [], 2);
%             resultsEEG.([Conditions{iCondition}]).phaseStd       = circ_std(eventPhase, [], [], 2);
%             resultsEEG.([Conditions{iCondition}]).phaseR         = phaseConsistency;
            resultsEEG.([Conditions{iCondition}]).newITPC         = newITPC;
%             resultsEEG.([Conditions{iCondition}]).stabilityIndex = stabilityIndex;   
%             resultsEEG.([Conditions{iCondition}]).compKeep = 'Y';%input('Should component be kept ?', 's');
               
            end

%             resultsEEG.([Conditions{iCondition}]).compKeep = input('Should component be kept ?', 's');
% 
%             if strcmpi(resultsEEG.([Conditions{iCondition}]).compKeep, 'N')
%                 resultsEEG.([Conditions{iCondition}]).stabilityIndex = NaN;
%                 resultsEEG.([Conditions{iCondition}]).phaseR         = NaN;
%                 resultsEEG.([Conditions{iCondition}]).power          = NaN;
%             end
         
            save([pathParticipant 'resultsEEG'], 'resultsEEG');

            close all;
            clear comp2plot compSNR compTime eventOnset firW Hz time erpStandard erpTargetHigh erpTargetLow beatCat beatOnset

        end
        clear resultsEEG RAC

    end

end