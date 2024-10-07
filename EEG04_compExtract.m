%% Extract entrained component
% 1. Sequence EEG in trials according to movement/beat onsets (-100:500 ms)
% 2. Compute covariance matrices S (from narrow-band filtered data) and R (from broadband signal)
% 3. Perform Generalized Eigen Decomposition (GED)
% 4. Extract entrained component

clear;
close all;
clc;

% Declare paths
pathEEG     = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/05_Analysis/'; %Folder where preprocessed signals are (post ICA)
pathPreproc = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/'; %Folders where movement/beat events are
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';  %Folder to save results
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1'); %EEGLab
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/GED-master/'); %For Gaussian filtering

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'};
Sessions     = {'01'; '02'; '03'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';...
                              'syncTapDT'; 'syncWalkDT'};

% Parameters for eigendecomposition
sFWHM = 0.5; % FWHM of stim frequency

eeglab;
for iParticipant = 5%length(Participants)
    disp(Participants{iParticipant})

    for iSession = 1%:length(Sessions)

        % Load data
        load([pathPreproc Participants{iParticipant} '/'  Sessions{iSession} '/Behavioural/dataRAC']);

        for iCondition = 2:length(Conditions)

            % Create folder for participant's results if does not exist
            pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/', Conditions{iCondition}, '/');
            if ~exist(pathParticipant, 'dir')
                mkdir(pathParticipant)
            end
       
            % Import EEG
            pathImport = [pathEEG Participants{iParticipant} '/' Sessions{iSession} '/' Conditions{iCondition} '/'];
            fileRead   = [Participants{iParticipant} '_cleaned_with_ICA.set'];
            EEG = pop_loadset('filename', fileRead,'filepath', pathImport);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');
            freqEEG = EEG.srate;

            % Remove accelerometer data
            EEG = pop_select(EEG, 'nochannel', {'ECG'; 'x_dir'; 'y_dir'; 'z_dir'});
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
            EEG = eeg_checkset(EEG);
            chanLocs = EEG.chanlocs;

            % Electrode used for 'best-electrode' analyses
            electrode = 'Cz';
            elecLoc = chanLocs(strcmpi([{chanLocs.labels}], electrode) == 1);
            elecPos = strcmpi([{chanLocs.labels}], electrode);
            [~, elecPos] = max(elecPos);

            % Extract mvt and beat onsets                   
            Event = [];
            if strcmpi(Conditions{iCondition}(5:7), 'Tap') == 1
                Event = 'Tap';
            elseif strcmpi(Conditions{iCondition}(5:8), 'Walk') == 1
                Event = 'Step';
            elseif strcmpi(Conditions{iCondition}(5:8), 'Rest') == 1
                 Event = 'RAC';
            end         
                    
            eventLoc = [];
            eventOnset = [];
            if strcmpi(Conditions{iCondition}, 'noneRestST') == 1 %Special case because no events in that condition
                eventOnset = round(RAC.stimRestST.beatOnset * (freqEEG/RAC.stimRestST.sampFreq));
            else    
                eventLoc   = find(strcmp({EEG.event.type}, Event));
                eventOnset = [EEG.event(eventLoc).latency];
            end

            beatLoc   = [];
            beatOnset = [];
            if strcmpi(Conditions{iCondition}(end-1:end), 'DT') == 1
                beatLoc   = find(strcmp({EEG.event.type}, 'RAC'));
                beatOnset = [EEG.event(beatLoc).latency];
            end

            % Compute S freq
            nEvents   = length(eventOnset);
            sFreq = round(nEvents / ((eventOnset(end) - eventOnset(1))/freqEEG),2);

            data = [];
            data = double(EEG.data);
            dataTime = size(data,2);

            % Filter above .5 Hz
            [d,c] = butter(3, .5/(freqEEG/2), 'high') ; % High-pass filter parameters (>0.5 Hz)
            for iChan = 1:EEG.nbchan
                data(iChan,:) = filtfilt(d,c,data(iChan,:));
            end
            data = double(data);

            % Filter under 45 Hz
            [b,a] = butter(3, 40/(freqEEG/2), 'low') ; % Low-pass filter parameters (<40 Hz)
            for iChan = 1:EEG.nbchan
                data(iChan,:) = filtfilt(b,a,data(iChan,:));
            end
            data = double(data);

            % FFT Parameters
            fftRes   = ceil(freqEEG/.02); % FFT resolution of .02 Hz
            Hz       = linspace(0, freqEEG, fftRes);

            %% Compute covariance matrices

            dataFFT = [];
            dataFFT = abs(fft(data,fftRes,2)/(size(data,2)-1)).^2;

            % S covariance
            sData = [];
            sData = filterFGx(data,freqEEG,sFreq,sFWHM);

            nMvt = 1;
            for iMvt = 1:length(eventOnset)-1
                if eventOnset(iMvt)-100 >= 1 && eventOnset(iMvt)+500 <= dataTime
                    sTemp = sData(:,eventOnset(iMvt)-100:eventOnset(iMvt)+500);
                    sTemp = bsxfun(@minus,sTemp,mean(sTemp,2));
                    sCovariance(:,:,nMvt) = (sTemp*sTemp')/(size(sTemp,2)-1);

                    rTemp = data(:,eventOnset(iMvt)-100:eventOnset(iMvt)+500);
                    rTemp = bsxfun(@minus,rTemp,mean(rTemp,2));
                    rCovariance(:,:,nMvt) = (rTemp*rTemp')/(size(rTemp,2)-1);

                    nMvt = nMvt+1;
                end
            end
            sCovMean = mean(sCovariance,3);
            rCovMean = mean(rCovariance,3);

            % Compute Euclidean distance
            sCovDistance = zeros(nMvt-1,1);
            rCovDistance = zeros(nMvt-1,1);

            for iMvt = 1:nMvt-1
                sCovTemp = squeeze(sCovariance(:,:,iMvt));
                sCovDistance(iMvt) = sqrt(sum((sCovTemp(:) - sCovMean(:)).^2));
     
                rCovTemp = squeeze(rCovariance(:,:,iMvt));
                rCovDistance(iMvt) = sqrt(sum((rCovTemp(:) - rCovMean(:)).^2));
            end

            % Convert distance to Z scores
            sCovZ = (sCovDistance-mean(sCovDistance)) / std(sCovDistance);
            rCovZ = (rCovDistance-mean(rCovDistance)) / std(rCovDistance);

            % Plot covariance distances
            figure, clf
            subplot(1,2,1); plot(sCovZ,'ks-','linew',2,'markerfacecolor','w','markersize',12);
            xlabel('Event'), ylabel('Z_{distance}'); title('Euclidean distance of S covariances from the mean')
            subplot(1,2,2); plot(rCovZ,'ks-','linew',2,'markerfacecolor','w','markersize',12);
            xlabel('Event'), ylabel('Z_{distance}'); title('Euclidean distance of R covariances from the mean')

            % Pick threshold to reject covariance matrice
            Threshold = 2.23; %probability of ~.013

            % Identify trials that exceed the threshold
            sCovReject = sCovZ > Threshold;
            rCovReject = rCovZ > Threshold;

            % Remove trials from covariance matrices and recompute grand average
            sCovariance(:,:,sCovReject) = [];
            sCovariance = mean(sCovariance,3);

            rCovariance(:,:,rCovReject) = [];
            rCovariance = mean(rCovariance,3);
            regulFactor = .01;
            rCovariance = (1-regulFactor)*rCovariance + regulFactor*mean(eig(rCovariance))*eye(size(rCovariance));

            % Plot covariance martices
            clim = [-1 1]*10;
            figure(3), clf
            subplot(121); imagesc(sCovariance);
            axis square; set(gca,'clim',clim); xlabel('Channels'), ylabel('Channels'); colorbar
            title('Covariance Matrix S');
            subplot(122); imagesc(rCovariance);
            axis square; set(gca,'clim',clim); xlabel('Channels'), ylabel('Channels'); colorbar
            title('Covariance Matrix R');
            saveas(figure(3), ['/' pathParticipant 'fig_ssepCovariance.png']);

            %% Extract component

            % Generalized eigendecomposition
            [W,Lambdas] = eig(sCovariance, rCovariance);
            [lambdaSorted, lambdaIndex] = sort(diag(Lambdas), 'descend'); 

            W = bsxfun(@rdivide, W, sqrt(sum(W.^2,1))); % Normalize vectors
            compMaps = sCovariance * W / (W' * sCovariance * W); % Extract components
            
            % Plot first 5 components
            i = 1;
            figure(4), clf
            subplot(211); plot(lambdaSorted,'ks-','markersize',10,'markerfacecolor','w');
            xlabel('Component', 'FontSize', 14); ylabel('\lambda', 'FontSize', 14);
            title('Eigen Values', 'FontSize', 14);
            for iComp = 1:5

                % Force Cz to be positive to facilitate across-subject interpretation
                elecSign = sign(compMaps(elecPos, lambdaIndex(iComp))); % To reverse sign
                compMaps(:,lambdaIndex(iComp)) = compMaps(:,lambdaIndex(iComp))* elecSign;

                subplot(2,5,5+i); comp2plot = compMaps(:,lambdaIndex(iComp)); topoplot(comp2plot./max(comp2plot), chanLocs, 'maplimits', [-1 1], 'numcontour',0,'electrodes','on','shading','interp');
                title(['Component ' num2str(iComp)], 'FontSize', 14)
                i = i+1;

            end
            colormap jet
            saveas(figure(4), [pathParticipant 'fig_ssepComponents.png']);

            comp2Keep = 1; %input('Which component should be kept ?'); comp2Keep = 2;
            compMax   = lambdaIndex(comp2Keep);
            comp2plot = compMaps(:,compMax);

            %% Reconstruct component time series
                             
            compTime = [];
            compTime = W(:,compMax)' * data;

            compFFT = [];
            compFFT = abs(fft(compTime',fftRes,1) / (length(compTime)-1)).^2;

            [M, fIndex] = max(compFFT);
            freqMax     = round(Hz(fIndex),2);
            timeVector  = linspace(1, round(length(compTime(:,~isnan(compTime)))/freqEEG), length(compTime(:,~isnan(compTime))));

            figure(5)
            subplot(221); topoplot(comp2plot./max(comp2plot), chanLocs, 'maplimits', [-1 1], 'numcontour',0,'conv','off','electrodes','on','shading','interp'); colorbar;
            title('Component Topography', 'FontSize', 14);
            subplot(222); plot(timeVector, compTime(:,~isnan(compTime)));
            set(gca, 'xlim', [timeVector(1) timeVector(end)]);
            xlabel({'Time (s)'}, 'FontSize', 14),
            title('Component Time Series', 'FontSize', 14);
            subplot(2,2,[3:4]); plot(Hz,compFFT);
            xlim = [0 25]; set(gca,'xlim',xlim);...
                xlabel('Frequency (Hz)', 'FontSize', 14) ; ylabel('Power', 'FontSize', 14);
            legend(['Peak frequency = ' num2str(freqMax)], 'FontSize', 14);
            title('Component FFT', 'FontSize', 14);
            saveas(figure(5), [pathParticipant 'fig_ssepTopo.png']);

            if abs(sFreq-freqMax) > .5
                if strcmpi(Conditions{iCondition}, 'noneRestST')
                    freqMax = sFreq;
                else
                    freqMax = input('What is the peak frequency ?');
                end
            end

            %% Compute SNR spectrum
            elecFFT = dataFFT(elecPos,:);

            [compSNR,elecSNR] = deal(zeros(size(Hz)));
            bins2skip =  5;
            binsNb    = 20+bins2skip;

            % Loop over frequencies to compute SNR
            for iHz = binsNb+1:length(Hz)-binsNb-1
                numer = compFFT(iHz);
                denom = mean(compFFT([iHz-binsNb:iHz-bins2skip iHz+bins2skip:iHz+binsNb]));
                compSNR(iHz) = numer./denom;

                numer = elecFFT(iHz);
                denom = mean( elecFFT([iHz-binsNb:iHz-bins2skip iHz+bins2skip:iHz+binsNb]));
                elecSNR(iHz) = numer./denom;
            end

            figure(6), clf
            xlim = [0.5 15];
            subplot(2,2,1); topoplot(comp2plot./max(comp2plot),chanLocs,'maplimits',[-1 1],'numcontour',0,'electrodes','on','shading','interp');
            title([ 'Component at ' num2str(freqMax) ' Hz' ], 'FontSize', 14);
            subplot(2,2,2); topo2plot = dataFFT(:,dsearchn(Hz', freqMax)); topoplot(topo2plot./max(topo2plot),chanLocs,'maplimits',[-1 1],'numcontour',0,'electrodes','on','emarker2',{find(strcmpi({chanLocs.labels},electrode)) 'o' 'w' 4},'shading','interp');
            title(['Electrode Power at ' num2str(freqMax) ' Hz'], 'FontSize', 14);
            subplot(2,2,[3:4]); plot(Hz,compSNR,'ro-','linew',1,'markersize',5,'markerface','w'); hold on;
            plot(Hz,elecSNR,'ko-','linew',1,'markersize',5,'markerface','w');
            set(gca,'xlim',xlim); xlabel('Frequency (Hz)', 'FontSize', 14), ylabel('SNR', 'FontSize', 14); legend({'Component'; electrode}, 'FontSize', 14); clear xlim
            saveas(figure(6), [pathParticipant 'fig_ssepVSelectrode.png']);

            save([pathPreproc Participants{iParticipant} '/' Sessions{iSession} '/EEG/' Conditions{iCondition} '_comp.mat'], 'compTime', 'compSNR', 'comp2plot', 'comp2Keep', 'chanLocs', 'freqMax', 'Hz', 'sFWHM', 'eventOnset', 'beatOnset', 'freqEEG');

            clear sCovariance rCovariance W Lambdas comp2plot lambdaIndex lambdaSorted timeVector...
                  rCovDistance rCovMean rCovReject rCovTemp rCovZ sCovDistance sCovMean sCovReject sCovTemp sCovZ...
                  data chanLocs elecLoc

            ALLEEG = [];

            close all

        end
        clear RAC

    end

end