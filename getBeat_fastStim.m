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

function[beatFreq, BPM, IOI, beatOnset] = getBeat_fastStim(Audio, Freq, preferredBPM)

figure; plot(Audio); hold on;

[pks, locs] = findpeaks(Audio, 'MinPeakHeight', 0);
plot(locs, pks, 'k*'); hold on;
interval = 2000/(preferredBPM/60);
beatOnset = [];
beatValue = [];
nBeats = preferredBPM*5;

first = 1;
[value, index] = min(abs(locs-interval));
for iBeat = 1:nBeats
    [value, minIndex] = min((pks(first:index)));

    beatOnset = [beatOnset; locs(minIndex+(first-1))];
    beatValue = [beatValue; value];
 
    first = index+1;
    [value, index] = min(abs(locs-(locs(index)+interval-1)));
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
