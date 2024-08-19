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

function[beatFreq, BPM, IOI, beatOnset] = getBeat_contaminatedSignal(Audio, Freq, preferredBPM)

figure; plot(Audio); hold on;

[beatOnset, y] = ginput(1);
IOI = (Freq*60*5)/(preferredBPM*5);


for i =  2:(preferredBPM*5)
    beatOnset(i) = beatOnset(i-1)+IOI;
    
end
beatOnset= round(beatOnset);

% Plot 
plot(beatOnset, Audio(beatOnset), 'r*')

% Extract metronome IOI, frequency & BPM
nBeats   = length(beatOnset);

% Make sure no beat is missing
for iIOI = 1:length(IOI)-1
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

beatFreq = nBeats / ((beatOnset(end) - beatOnset(1))/Freq);
BPM      = beatFreq * 60;

clear pks locs pksFilt locsFilt pksSingle


end
