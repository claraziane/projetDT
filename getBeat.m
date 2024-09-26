%% This function extracts participants' step onsets from left and right kinetic data
%
% Input variables:
% -Audio:      stimulus data (vector of length = total number of frames)
% -Freq:       acquisition frequency (single value variable)
% -bpmInitial: BPM at which stimulus was set (single value variable)
%
% Output variables:
% -beatFreq:  stimulus frequency calculated after beat onset extraction (single value variable)
% -BPM:       stimulus bpm recalculated after beat onset extraction (single value variable)
% -IOI:       interonset intervals (vector of length = number of beats-1)
% -beatOnset: beat onset time values in frames (vector of length = number of beats)
%
% C. Ziane

function[beatFreq, BPM, IOI, beatOnset] = getBeat(Audio, Freq, preferredBPM)

figure; plot(Audio); hold on;

% Centering the signal around 0
audioInv = detrend(Audio - mean(Audio));
beatFreq = (Freq*60)/preferredBPM; % Number of frames inbetween two beats

[pks, locs] = findpeaks(audioInv, 'MinPeakHeight', 0);
audioEnv = interp1(locs, pks, [1:length(audioInv)])';
audioEnv(isnan(audioEnv)) = 0;
% figure; plot(audioEnv); hold on;

% Low-pass filter audio signal at 5 Hz to get signal envelop
[f,e] = butter(2,2*5/Freq);
envFilt = filtfilt(f,e,abs(audioEnv));
% plot(envFilt)

% Find envelop peaks
peakThreshold = 0.03;
[pksFilt, locsFilt] = findpeaks(envFilt); %plot(locsFilt, envFilt(locsFilt), 'r*')

% Only keep one peak per beat
locsFilt(pksFilt < peakThreshold) = [];
pksFilt(pksFilt < peakThreshold)  = [];
pksFilt = envFilt(locsFilt);

% Find peaks corresponding to beat onsets
minPeak =  -0.01;
peakThreshold = 0.01;
[pks,locs] = findpeaks(audioInv, 'MinPeakHeight', minPeak);

beatOnset = []; beatValue = [];
singleIndex = 1;
for iPksFilt = 2:length(pksFilt)
    nPeaks = 100; %Number of peaks to include before trigger
    [M, I] = min(abs(locs-locsFilt(iPksFilt)));
    singleIndex = singleIndex+1;
    tempBeat = audioInv(locs(I-nPeaks:I));
    tempFrames = locs(I-nPeaks:I);
    beatRound = round(tempBeat,3);
    
    % beatRound must be in one column
    if size(beatRound,1) == 1
        beatRound = beatRound';
    end

    if beatRound(1) > 0
        for iBeatRound = 1:length(beatRound)
            if beatRound(iBeatRound) <= peakThreshold && beatRound(iBeatRound+1) <= peakThreshold
                beatRoundIndex = iBeatRound-1;
                break;
            end
        end
        beatRound(1:beatRoundIndex) = [];
        tempFrames(1:beatRoundIndex)   = [];
        tempBeat(1:beatRoundIndex) = [];
    end
    beatRound(beatRound<peakThreshold) = 0;
    beatRound(beatRound>=peakThreshold) = 1;
%     plot(tempFrames, Audio(tempFrames), 'k*')

    for i = 2:length(beatRound)-1
        if beatRound(i) == 0 && beatRound(i+1) == 1
            if beatRound(i-1) == 1
                beatRound(i) = 1;
            end
        end
    end
    beatRound(end) = 1;

     for i = 2:length(beatRound)-1
        if beatRound(i) == 1 && beatRound(i+1) == 0
            if beatRound(i-1) == 0
                beatRound(i) = 0;
            end
        end
    end

    for i = 1:length(beatRound)-1
        if beatRound(i) == 1 && mean(beatRound(1:i-1)) == 0
            tempFrames(1:i-2) = [];
            break;
        end
    end

    if mean(beatRound) == 1
        [maxTempBeat, indexTempBeat] = max(abs(diff(tempBeat)));
        tempFrames(2) = tempFrames(indexTempBeat+1);
    end

    if tempFrames(2) - tempFrames(1) > beatFreq/4
        tempFrames(1) = [];
    end
    beatIndex = tempFrames(1);
%     while audioInv(beatIndex) <= 0
%         beatIndex = beatIndex-1;
%     end
    beatOnset = [beatOnset; beatIndex];
    beatValue = [beatValue; Audio(beatIndex)];

end
plot(beatOnset, beatValue, 'r*')

% Extract metronome IOI, frequency & BPM
beatOnset = unique(beatOnset,'rows');
[beatOnsetUnique iRepeat] = unique(beatOnset);
beatOnset = beatOnsetUnique;
beatValue = Audio(beatOnset);

% Make sure no beat is missing
IOI = diff(beatOnset);
for iIOI = 1:length(IOI)-1

    if iIOI <= length(IOI)

        if IOI(iIOI) > mean(IOI) + 50
            warning([' !!! Seems like at least one beat is missing around frame number ' num2str(beatOnset(iIOI)) '!!']);

            Action = input('Do you want to replace beat [1], add beat [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [beatOnset(end+1), beatValue(end+1)] = ginput(1);
                plot(beatOnset(end), beatValue(end), 'r*')
                [M, mIndex] = min(abs(beatOnset(end) - beatOnset(1:end-1)));
                beatOnset(mIndex) = [];
                beatOnset = round(sort(beatOnset, 'ascend'));
                IOI = diff(beatOnset);
            elseif Action == 2
                [beatOnset(end+1), beatValue(end+1)] = ginput(1);
                plot(beatOnset(end), beatValue(end), 'r*')
                beatOnset = round(sort(beatOnset, 'ascend'));
                IOI = diff(beatOnset);
            end

        elseif IOI(iIOI) < mean(IOI) - 50
            warning([' !!! Seems like there are too many beats around frame number ' num2str(beatOnset(iIOI)) '!!']);

            Action = input('Do you want to replace beat [1], remove beat [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [beatOnset(end+1), beatValue(end+1)] = ginput(1);
                plot(beatOnset(end), beatValue(end), 'r*')
                [M, mIndex] = min(abs(beatOnset(end) - beatOnset(1:end-1)));
                beatOnset(mIndex) = [];
                beatOnset = round(sort(beatOnset, 'ascend'));
                IOI = diff(beatOnset);
            elseif Action == 2
                beat2remove = input('Which beat do you want to remove (index number)');
                beatOnset(beat2remove) = [];
                beatValue(beat2remove) = [];
                IOI = diff(beatOnset);
            end
        end
    end
end

warning('Check last beat has been identified for beat categorization !!')

nBeats   = length(beatOnset)-1;
beatFreq = nBeats / ((beatOnset(end)-1 - beatOnset(1))/Freq);
BPM      = beatFreq * 60;

clear pks locs pksFilt locsFilt pksSingle

end
