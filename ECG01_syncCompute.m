clear all; 
close all;
clc;

% Declare paths
pathData     = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P07'; 'P08';'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'};
Sessions     = {'01'; '02'};
Conditions   = {'stimTapST'; 'stimWalkST';...
                'stimTapDT'; 'stimWalkDT';...
                'syncTapST'; 'syncWalkST';...
                'syncTapDT'; 'syncWalkDT'};
     
for iParticipant = 8:length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
  
        % Load behavioural data
        load([pathExport '/resultsECG.mat']);
        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataRAC.mat']);

        for iCondition = 1:length(Conditions)

            % Extract acquisition frequency
            freqRAC  = RAC.([Conditions{iCondition}]).sampFreq;

            % Extracting beat onsets
            beatOnset = [];
            beatOnset = RAC.([Conditions{iCondition}]).beatOnset;
            beatOnset = (beatOnset / freqRAC) * 1000; %Convert to ms
            IOI = mean(diff(beatOnset));

            heartOnset = [];
            freqECG = resultsECG.([Conditions{iCondition}]).sampFreq;

            % Extracting tap onsets
            heartOnset = resultsECG.([Conditions{iCondition}]).heartOnsets(2:end-1);
            heartOnset = (heartOnset / freqECG) * 1000; %Convert to ms

            %% Estimating period-matching accuracy (i.e., extent to which step tempo matches stimulus tempo) using IBI deviation

            % Matching step onsets to closest beat
            beatMatched = [];
            for iHR = 1:length(beatOnset)
                [minValue matchIndex] = min(abs(heartOnset-beatOnset(iHR)));
                beatMatched(iHR,1) = heartOnset(matchIndex);
            end

            % Calculating interstep interval
            heartInterval = [];
            heartInterval = diff(beatMatched);

            % Calculating interbeat interval
            racInterval = [];
            racInterval = diff(beatOnset);
            
            % Calculating IBI deviation
            IBI = [];
            IBI = mean(abs(heartInterval - racInterval))/mean(racInterval);

            %% Estimating phase-matching accuracy (i.e., the difference between step onset times and beat onset times) using circular asynchronies
            asynchrony           = [];
            asynchronyNormalized = [];
            asynchronyCircular   = [];
            asynchronyRad        = [];

            asynchrony           = beatMatched - beatOnset;
            asynchronyNormalized = asynchrony(1:end-1)./heartInterval;
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

            phaseRad       = [];
            phaseRad       = deg2rad(phaseAngle);
            phaseAngleMean = circ_mean(phaseRad(phaseRad ~=0), [], 1);

            % Calculating resultant vector length (expresses the stability of the relative phase angles over time)
            resultantLength = circ_r(phaseRad, [], [], 1);

            % Storing results in structure
            resultsSyncECG.([Conditions{iCondition}]).IBIDeviation = IBI;
            resultsSyncECG.([Conditions{iCondition}]).Asynchrony = asynchrony;
            resultsSyncECG.([Conditions{iCondition}]).circularAsynchrony = asynchronyCircular;
            resultsSyncECG.([Conditions{iCondition}]).asynchronyMean = asynchronyMean;
            resultsSyncECG.([Conditions{iCondition}]).circularVariance = varianceCircular;
            resultsSyncECG.([Conditions{iCondition}]).pRao = p;
            resultsSyncECG.([Conditions{iCondition}]).phaseAngle = phaseAngle;
            resultsSyncECG.([Conditions{iCondition}]).phaseAngleMean = phaseAngleMean;
            resultsSyncECG.([Conditions{iCondition}]).resultantLength = resultantLength;

        end % End Conditions

        % Save results
        save([pathExport 'resultsSyncECG.mat'], 'resultsSyncECG');

    end % End Sessions

end % End Participants