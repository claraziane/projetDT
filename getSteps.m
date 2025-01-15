%% This function extracts participants' step onsets from left and right kinetic data
%
% Input variables:
% -kineticR: z force time-series recorded for the right foot (vector of length = total number of frames)
% -kineticL: z force time-series recorded for the left foot (vector of length = total number of frames)
% -Freq:     acquisition frequency (single value variable)
%
% Output variables:
% -stepOnsetR:   right step onset time values expressed in frames (vector of length = number of right steps)
% -stepOnsetL:   left step onset time values expressed in frames (vector of length = number of left steps)
% -stepOnsetAll: left and right step onset time values expressed in frames (vector of length = total number of steps)
%
% C. Ziane

function [stepOnsets] = getSteps(Kinetics, Freq)

%% Right foot

% Normalize forces
Kinetics = Kinetics(~isnan(Kinetics));
Kinetics = Kinetics-mean(Kinetics);
Kinetics = (Kinetics/max(Kinetics))*100;

figure; plot(Kinetics); title('Force Plate Data'); hold on;

% Low-pass filter audio signal at 5 Hz to get signal envelop
[f,e] = butter(2,4*10/Freq);
kineticFilt = filtfilt(f,e,Kinetics);
% plot(kineticFilt)

% Find envelop peaks
peakThreshold = 40; %40
[pksFilt, locsFilt] = findpeaks(kineticFilt);

% Find first stepOnset and remove peaks before first stepOnset
[minPksFilt, minIndexPksFilt] = min(pksFilt(1:3));
if minIndexPksFilt > 1
    locsFilt(1:minIndexPksFilt-1) = [];
    pksFilt(1:minIndexPksFilt-1) = [];
end

% Only keep one peak per step
pksFiltTemp = pksFilt;
pksFiltTemp(pksFilt < peakThreshold) = 0;
pksFiltTemp(pksFilt > peakThreshold) = 1;
pks2Keep = [];

% if one zero value is missing
pksSingle = [];
for iPksFilt = 1:length(pksFilt)-3
    if mean(pksFiltTemp(iPksFilt:iPksFilt+3)) == 1
        pksFiltTemp(iPksFilt+3:end+1) = pksFiltTemp(iPksFilt+2:end);
        pksFiltTemp(iPksFilt+2) = 0;

        pksFilt(iPksFilt+3:end+1) = pksFilt(iPksFilt+2:end);
        pksFilt(iPksFilt+2) = 0;

        locsFilt(iPksFilt+3:end+1) = locsFilt(iPksFilt+2:end);
        locsFilt(iPksFilt+2) = locsFilt(iPksFilt+2)-1;
    end
    if pksFiltTemp(iPksFilt) == 1 && pksFiltTemp(iPksFilt-1) == 0 && pksFiltTemp(iPksFilt+1) == 0
        pksSingle = [pksSingle; locsFilt(iPksFilt)];
    end

    %     if pksFiltTemp(iPksFilt) == 1
    %
    %         if pksFiltTemp(iPksFilt-1) == 1 && locsFilt(iPksFilt) - locsFilt(iPksFilt-1) > 100
    %             pksFiltTemp(iPksFilt:end+1) = pksFiltTemp(iPksFilt-1:end);
    %             pksFiltTemp(iPksFilt-1) = 0;
    %
    %             locsFilt(iPksFilt:end+1) = locsFilt(iPksFilt-1:end);
    %             locsFilt(iPksFilt-1) = locsFilt(iPksFilt-1)-1;
    %         end
    %
    %
    %         if pksFiltTemp(iPksFilt+1) == 1 && locsFilt(iPksFilt+1) - locsFilt(iPksFilt) > 100
    %             pksFiltTemp(iPksFilt+2:end+1) = pksFiltTemp(iPksFilt+1:end);
    %             pksFiltTemp(iPksFilt+1) = 0;
    %
    %             locsFilt(iPksFilt+2:end+1) = locsFilt(iPksFilt+1:end);
    %             locsFilt(iPksFilt+1) = locsFilt(iPksFilt+1)-1;
    %         end
    %
    %         if pksFiltTemp(iPksFilt-1) == 0 && pksFiltTemp(iPksFilt+1) == 0
    %             pksSingle = [pksSingle; locsFilt(iPksFilt)];
    %         end
    %
    %     end

end

for iPksFilt = 1:length(pksFilt)
    if pksFiltTemp(iPksFilt) == 0 && iPksFilt ~= length(pksFilt)
        pks2Keep = [pks2Keep; iPksFilt+1];
    end
end
locsFilt = locsFilt(pks2Keep);
pksFilt = pksFilt(pks2Keep);

% Remove peaks below peakThreshold
locsFilt(pksFilt < peakThreshold) = [];
pksFilt(pksFilt < peakThreshold) = [];
% plot(locsFilt, kineticFilt(locsFilt), 'b*')

% Find peaks corresponding to beat onsets
minPeak = -50;
[pks,locs] = findpeaks(Kinetics, 'MinPeakHeight', minPeak);

stepOnsets = []; stepValues = [];
singleIndex = 1;
for iPksFilt = 2:length(pksFilt)
    nPeaks = 70; %Number of peaks to include before trigger
    [M, I] = min(abs(locs-locsFilt(iPksFilt)));
    if iPksFilt == 1 && I < nPeaks
        nPeaks = I-1;
    elseif ~isempty(pksSingle) && singleIndex <= length(pksSingle) && locsFilt(iPksFilt) == pksSingle(singleIndex)
        nPeaks = nPeaks*2; %*2
        singleIndex = singleIndex+1;
    end
    tempKinetic = Kinetics(locs(I-nPeaks:I));
    tempFrames = locs(I-nPeaks:I);
    kineticRound = round(tempKinetic,1);
    if kineticRound(1) > 0
        for iKineticRound = 1:length(kineticRound)
            if kineticRound(iKineticRound) <= 0 && kineticRound(iKineticRound+1) <= 0
                kineticRoundIndex = iKineticRound-1;
                break;
            end
        end
        exist kineticRoundIndex
        if ans == 0
            kineticRoundIndex = 1;
        end
        kineticRound(1:kineticRoundIndex) = [];
        tempFrames(1:kineticRoundIndex)   = [];
        tempKinetic(1:kineticRoundIndex) = [];

    end
    kineticRound(kineticRound<=peakThreshold) = 0;
    kineticRound(kineticRound>peakThreshold) = 1;
    %     plot(tempFrames, tempKinetic, 'k*')

    for i = 1:length(kineticRound)-1
        if kineticRound(i) == 0 && mean(kineticRound(i+1:end)) == 1
            tempFrames(1:i-1) = [];
            break;
        end
    end
    if mean(kineticRound) == 1
        [maxTempKinetic, indexTempKinetic] = max(abs(diff(tempKinetic)));
        tempFrames(2) = tempFrames(indexTempKinetic+1);
    end

    kineticIndex = tempFrames(2);
    while Kinetics(kineticIndex) >= Kinetics(kineticIndex-1)
        kineticIndex = kineticIndex-1;
    end
    stepOnsets = [stepOnsets; kineticIndex];
    stepValues = [stepValues; Kinetics(kineticIndex)];

end
plot(stepOnsets, stepValues, 'r*')

% Removing identical values
stepOnsets = unique(stepOnsets,'rows');
[stepOnsetsUnique iRepeat] = unique(stepOnsets);
stepOnsets = stepOnsetsUnique;
stepValues = Kinetics(stepOnsets);

clear pks locs pksFilt locsFilt pksSingle

% Make sure you only have one value per step and that no steps are missing
stepOnsetDiff = diff(stepOnsets);
for iStep = 1:length(stepOnsetDiff)
    PB = 0;

    if iStep <= length(stepOnsetDiff)

        if stepOnsetDiff(iStep) > mean(stepOnsetDiff) + 150
            warning([' !!! Seems like at least one step is missing around frame ' num2str(stepOnsets(iStep)) ' !!']);
            PB = 1;
        elseif stepOnsetDiff(iStep) < mean(stepOnsetDiff) - 150
            warning([' !!! Seems like there are too many steps around frame ' num2str(stepOnsets(iStep)) ' !!']);
            PB = 1;
        end

        if PB == 1
            Action = input('Do you want to replace step [1], add step [2], remove step [3], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [stepOnsets(end+1), stepValues(end+1)] = ginput(1);
                plot(stepOnsets(end), stepValues(end), 'r*')
                [M, mIndex] = min(abs(stepOnsets(end) - stepOnsets(1:end-1)));
                stepOnsets(mIndex) = [];
                stepOnsets = round(sort(stepOnsets, 'ascend'));
                stepOnsetDiff = diff(stepOnsets);
            elseif Action == 2
                [stepOnsets(end+1), stepValues(end+1)] = ginput(1);
                plot(stepOnsets(end), stepValues(end), 'r*')
                stepOnsets = round(sort(stepOnsets, 'ascend'));
                stepOnsetDiff = diff(stepOnsets);
            elseif Action == 3
                step2remove = input('Which heart beat do you want to remove (index number)?');
                plot(stepOnsets(step2remove), Kinetics(stepOnsets(step2remove)), 'w*')
                stepOnsets(step2remove) = [];
                stepValues(step2remove) = [];
                stepOnsetDiff = diff(stepOnsets);
            end

        end

    end

end


end