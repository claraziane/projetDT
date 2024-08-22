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

function[tapOnset, tapFreq, ITI, tapCadence] = getTaps(tapData, Freq)

tapData = tapData(~isnan(tapData));
figure; plot(tapData); title('Tap Data'); hold on;

% Low-pass filter audio signal at 5 Hz to get signal envelop
[f,e] = butter(2,2*5/Freq);
tapFilt = filtfilt(f,e,abs(tapData));
% plot(tapFilt)

% Find envelop peaks
peakThreshold = .3;
[pksFilt, locsFilt] = findpeaks(tapFilt);

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
    elseif pksFiltTemp(iPksFilt) == 1 && pksFiltTemp(iPksFilt-1) == 0 && pksFiltTemp(iPksFilt+1) == 0
        pksSingle = [pksSingle; locsFilt(iPksFilt)];
    end
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
% plot(locsFilt, tapFilt(locsFilt), 'b*')

% Find peaks corresponding to tap max force
itiTemp =  min(diff(locsFilt));
[pks,locs] = findpeaks(tapData, 'MinPeakHeight', peakThreshold, 'MinPeakDistance', itiTemp/2);
% plot(locs, tapData(locs), 'k*')

% Find tap onsets
tapOnset = []; tapValue = [];
for iTap = 1:length(pks)

    frameIndex = locs(iTap);
    while tapData(frameIndex) > tapData(frameIndex-1)
        frameIndex = frameIndex - 1;
        if frameIndex == 1
            break;
        end
    end

    if frameIndex > 1
        if tapData(frameIndex) > peakThreshold
            while tapData(frameIndex) > peakThreshold
                frameIndex = frameIndex - 1;
                if frameIndex == 1
                    break;
                end
            end

            if frameIndex > 1
                while tapData(frameIndex) > tapData(frameIndex-1)
                    frameIndex = frameIndex - 1;
                end

            end

        end

        if frameIndex > 1
            tapOnset = [tapOnset; frameIndex-1];
            tapValue = [tapValue; tapData(frameIndex-1)];
        end

    end

end
plot(tapOnset, tapValue, 'r*');

% Remove repeating tap onsets
tapOnset = unique(tapOnset,'rows');
[tapOnsetsUnique iRepeat] = unique(tapOnset);
tapOnset = tapOnsetsUnique;
tapValue = tapData(tapOnset);

clear pks locs pksFilt pks2keep locsFilt pksFiltTemp pksSingle

% Make sure you only have one value per step and that no steps are missing
ITI = diff(tapOnset);
for iTap = 1:length(ITI)

    if iTap <= length(ITI)

        if ITI(iTap) > mean(ITI) + 250
            warning([' !!! Seems like at least one tap is missing around frame ' num2str(tapOnset(iTap)) '!!']);

            Action = input('Do you want to replace tap [1], add tap [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [tapOnset(end+1), tapValue(end+1)] = ginput(1);
                plot(tapOnset(end), tapValue(end), 'r*')
                [M, mIndex] = min(abs(tapOnset(end) - tapOnset(1:end-1)));
                tapOnset(mIndex) = [];
                tapOnset = round(sort(tapOnset, 'ascend'));
                ITI = diff(tapOnset);
            elseif Action == 2
                [tapOnset(end+1), tapValue(end+1)] = ginput(1);
                plot(tapOnset(end), tapValue(end), 'r*')
                tapOnset = round(sort(tapOnset, 'ascend'));
                ITI = diff(tapOnset);
            end
        elseif ITI(iTap) < mean(ITI) - 250
            warning([' !!! Seems like there are too many taps around frame ' num2str(tapOnset(iTap)) '!!']);

            Action = input('Do you want to replace tap [1], remove tap [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [tapOnset(end+1), tapValue(end+1)] = ginput(1);
                plot(tapOnset(end), tapValue(end), 'r*')
                [M, mIndex] = min(abs(tapOnset(end) - tapOnset(1:end-1)));
                tapOnset(mIndex) = [];
                tapOnset = round(sort(tapOnset, 'ascend'));
                ITI = diff(tapOnset);
            elseif Action == 2
                tap2remove = input('Which tap do you want to remove (index number)?');
                tapOnset(tap2remove) = [];
                tapValue(tap2remove) = [];
                ITI = diff(tapOnset);

            end
        end

    end

end

nTaps       = length(tapOnset)-1;
tapFreq     = nTaps / ((tapOnset(end)-1 - tapOnset(1))/Freq);
tapCadence  = tapFreq * 60;

end