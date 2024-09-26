function [heartOnsets, heartRate, BPM,  IBI, ibiMean, ibiCV] = getHeart(heartData, sampFreq)

heartData = (heartData(~isnan(heartData)))* -1;
heartData = detrend(heartData - mean(heartData)); % Center around 0 and remove offset
figure; plot(heartData); title('ECG'); hold on;

% Find envelop peaks
peakThreshold = 50;
[heartValues,heartOnsets] = findpeaks(heartData, 'MinPeakHeight', peakThreshold, 'MinPeakDistance', 250);
plot(heartOnsets, heartValues, 'r*');

% Remove repeating heart beat onsets
heartOnsets = unique(heartOnsets,'rows');
[heartOnsetsUnique iRepeat] = unique(heartOnsets);
heartOnsets = heartOnsetsUnique;
heartValues = heartData(heartOnsets);

% Make sure you only have one value per step and that no steps are missing
IBI = diff(heartOnsets);
for iBeat = 1:length(IBI)

    if iBeat <= length(IBI)

        if IBI(iBeat) > mean(IBI) + 50
            warning([' !!! Seems like at least one heart beat is missing around frame ' num2str(heartOnsets(iBeat)) '!!']);

            Action = input('Do you want to replace heart beat [1], add heart beat [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [heartOnsets(end+1), heartValues(end+1)] = ginput(1);
                plot(heartOnsets(end), heartValues(end), 'r*')
                [M, mIndex] = min(abs(heartOnsets(end) - heartOnsets(1:end-1)));
                heartOnsets(mIndex) = [];
                heartOnsets = round(sort(heartOnsets, 'ascend'));
                IBI = diff(heartOnsets);
            elseif Action == 2
                [heartOnsets(end+1), heartValues(end+1)] = ginput(1);
                plot(heartOnsets(end), heartValues(end), 'r*')
                heartOnsets = round(sort(heartOnsets, 'ascend'));
                IBI = diff(heartOnsets);
            end
        elseif IBI(iBeat) < mean(IBI) - 50
            warning([' !!! Seems like there are too many heart beats around frame ' num2str(heartOnsets(iBeat)) '!!']);

            Action = input('Do you want to replace heart beat [1], remove heart beat [2], or do nothing [0] ?');
            if Action == 0
            elseif Action == 1
                [heartOnsets(end+1), heartValues(end+1)] = ginput(1);
                plot(heartOnsets(end), heartValues(end), 'r*')
                [M, mIndex] = min(abs(heartOnsets(end) - heartOnsets(1:end-1)));
                heartOnsets(mIndex) = [];
                heartOnsets = round(sort(heartOnsets, 'ascend'));
                IBI = diff(heartOnsets);
            elseif Action == 2
                beat2remove = input('Which heart beat do you want to remove (index number)?');
                heartOnsets(beat2remove) = [];
                heartValues(beat2remove) = [];
                IBI = diff(heartOnsets);

            end
        end

    end

end

nBeats    = length(heartOnsets)-1;
heartRate = nBeats / ((heartOnsets(end)-1 - heartOnsets(1))/sampFreq);
BPM       = heartRate * 60;
IBI       = diff(heartOnsets);
IBI       = (IBI / sampFreq) * 1000;  % Convert frames to ms            
ibiMean   = mean(IBI);

% Computing coefficient of variability of inter-beat intervals
ibiStd = std(IBI);
ibiCV = ibiStd/ibiMean;

close;
 
end