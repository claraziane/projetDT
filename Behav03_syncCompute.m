clear all; 
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'};
Sessions     = {'01'; '02'};
Conditions   = {'stimTapST'; 'stimWalkST';...
                'stimTapDT'; 'stimWalkDT';...
                'syncTapST'; 'syncWalkST';...
                'syncTapDT'; 'syncWalkDT'};
     
for iParticipant = length(Participants)-1:length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        % Load behavioural data
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataRAC.mat']);

        for iCondition = 1:length(Conditions)

            % Extract acquisition frequency
            freqRAC  = RAC.([Conditions{iCondition}]).sampFreq;

            % Extracting beat onsets
            beatOnset = [];
            beatOnset = RAC.([Conditions{iCondition}]).beatOnset;
            beatOnset = (beatOnset / freqRAC) * 1000; %Convert to ms
            IOI = mean(diff(beatOnset));

            mvtOnset = [];
            if strcmpi(Conditions{iCondition}(5:7), 'Tap') 
                freqMvt = Taps.([Conditions{iCondition}]).sampFreq;

%                 % Extracting tap onsets
                mvtOnset = Taps.([Conditions{iCondition}]).tapOnset(2:end-1);

            else
                freqMvt = Steps.([Conditions{iCondition}]).sampFreq;

                % Extracting step onsets
                mvtOnset = Steps.([Conditions{iCondition}]).stepOnsets(2:end-1);

            end
            mvtOnset = (mvtOnset / freqMvt) * 1000; %Convert to ms

            %% Estimating period-matching accuracy (i.e., extent to which step tempo matches stimulus tempo) using IBI deviation

            % Matching step onsets to closest beat
            beatMatched = [];
            for iMvt = 1:length(mvtOnset)
                [minValue matchIndex] = min(abs(beatOnset-mvtOnset(iMvt)));
                beatMatched(iMvt,1) = beatOnset(matchIndex);
            end

            % Calculating interstep interval
            mvtInterval = [];
            mvtInterval = diff(mvtOnset);

            % Calculating interbeat interval
            racInterval = [];
            racInterval = diff(beatMatched);
            
            % Calculating IBI deviation
            IBI = [];
            IBI = mean(abs(mvtInterval - racInterval))/mean(racInterval);

            %% Estimating phase-matching accuracy (i.e., the difference between step onset times and beat onset times) using circular asynchronies
            asynchrony           = [];
            asynchronyNormalized = [];
            asynchronyCircular   = [];
            asynchronyRad        = [];

            asynchrony           = mvtOnset - beatMatched;
            asynchronyNormalized = asynchrony(1:end-1)./mvtInterval;
            asynchronyCircular   = asynchronyNormalized * 360;
            asynchronyRad        = asynchronyCircular * pi/180;
            asynchronyMean       = circ_mean(asynchronyRad, [], 1);
%             figure; scatter(1,asynchronyCircular)

            % Running Rao's test (a not-significant test means participant failed to synchronize)
            [p U UC] = circ_raotest(asynchronyCircular);

            % Calculating circular variance
            [varianceCircular varianceAngular] = circ_var(asynchronyRad);

            % Calculating phase angles (error measure of synchronization based on the phase difference between two oscillators)
            phaseAngle     = [];
            phaseAngle     = 360*(asynchrony(1:end-1)/IOI);
            
            phaseError     = [];
            phaseError     = abs(phaseAngle);
            phaseErrorRad  = deg2rad(phaseError);
            phaseErrorMean = circ_mean(phaseErrorRad(phaseErrorRad ~=0), [], 1);

            phaseRad       = [];
            phaseRad       = deg2rad(phaseAngle);
            phaseAngleMean = circ_mean(phaseRad(phaseRad ~=0), [], 1);

            % Calculating resultant vector length (expresses the stability of the relative phase angles over time)
            resultantLength = circ_r(phaseRad, [], [], 1);

            % Storing results in structure
            resultsSync.([Conditions{iCondition}]).IBIDeviation = IBI;
            resultsSync.([Conditions{iCondition}]).Asynchrony = asynchrony;
            resultsSync.([Conditions{iCondition}]).circularAsynchrony = asynchronyCircular;
            resultsSync.([Conditions{iCondition}]).asynchronyMean = asynchronyMean;
            resultsSync.([Conditions{iCondition}]).circularVariance = varianceCircular;
            resultsSync.([Conditions{iCondition}]).pRao = p;
            resultsSync.([Conditions{iCondition}]).phaseAngle = phaseAngle;
            resultsSync.([Conditions{iCondition}]).phaseError = phaseError;
            resultsSync.([Conditions{iCondition}]).phaseErrorMean = phaseErrorMean;
            resultsSync.([Conditions{iCondition}]).phaseAngleMean = phaseAngleMean;
            resultsSync.([Conditions{iCondition}]).resultantLength = resultantLength;

        end % End Conditions

        % Save results
        save([pathExport 'resultsSync.mat'], 'resultsSync');

    end % End Sessions

end % End Participants