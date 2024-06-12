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
Kinetics = Kinetics-mean(Kinetics);
Kinetics = (Kinetics/max(Kinetics))*100;

figure; plot(Kinetics); title('Force Plate Data'); hold on;

% Find envelop peaks
peakThreshold = 40;
[pksKin, locsKin] = findpeaks(Kinetics);

% Find first stepOnset and remove peaks before first stepOnset
[minPks, minIndexPks] = min(pksKin(1:3));
if minIndexPks > 1
    locsKin(1:minIndexPks-1) = [];
    pksKin(1:minIndexPks-1) = [];
end

% Only keep one peak per step
pksTemp = pksKin;
pksTemp(pksKin < peakThreshold) = 0;
pksTemp(pksKin > peakThreshold) = 1;
pks2Keep = [];

% if one zero value is missing
pksSingle = [];
for iPks = 1:length(pksKin)-3
    if mean(pksTemp(iPks:iPks+3)) == 1
        pksTemp(iPks+3:end+1) = pksTemp(iPks+2:end);
        pksTemp(iPks+2) = 0;

        pksKin(iPks+3:end+1) = pksKin(iPks+2:end);
        pksKin(iPks+2) = 0;

        locsKin(iPks+3:end+1) = locsKin(iPks+2:end);
        locsKin(iPks+2) = locsKin(iPks+2)-1;
    elseif pksTemp(iPks) == 1 && pksTemp(iPks-1) == 0 && pksTemp(iPks+1) == 0
        pksSingle = [pksSingle; locsKin(iPks)];
    end
end

for iPks = 1:length(pksKin)
    if pksTemp(iPks) == 0 && iPks ~= length(pksKin)
        pks2Keep = [pks2Keep; iPks+1];
    end
end
locsKin = locsKin(pks2Keep);
pksKin = pksKin(pks2Keep);

% Remove peaks below peakThreshold
locsKin(pksKin < peakThreshold) = [];
pksKin(pksKin < peakThreshold) = [];
% plot(locsKin, Kinetics(locsKin), 'b*')

% Find peaks corresponding to step onsets
minPeak = 40;

stepOnsets = []; stepValues = [];
for iPks = 1:length(pksKin)
    
    iFrame = locsKin(iPks);
    while Kinetics(iFrame) > Kinetics(iFrame-1)
        iFrame = iFrame -1;

        if Kinetics(iFrame) <= 0
            diffKin = flip(diff(Kinetics(locsKin(iPks)-10:locsKin(iPks))));
            
            for iDiff = 1:length(diffKin)
                iFrame = locsKin(iPks) - iDiff;

                if diffKin(iDiff) >= diffKin(iDiff+1) && Kinetics(iFrame) < minPeak
                    break;
                end
            end
            break;

        end
        
    end
    stepOnsets = [stepOnsets; iFrame];
    stepValues = [stepValues; Kinetics(iFrame)];

end
plot(stepOnsets, stepValues, 'r*')

% Removing identical values
stepOnsets = unique(stepOnsets,'rows');

[stepOnsetsUnique iRepeat] = unique(stepOnsets);
stepDiff = diff(iRepeat);
stepOnsets(stepDiff>1) = [];
stepValues(stepDiff>1) = [];

clear pksKin locsKin pksSingle

% Make sure you only have one value per step and that no steps are missing
stepOnsetDiff = diff(stepOnsets);
for iStep = 1:length(stepOnsetDiff)-1
    if stepOnsetDiff(iStep) > mean(stepOnsetDiff) + 5
        warning([' !!! Seems like at least one step is missing around frame ' num2str(stepOnsets(iStep)) '!!' ]);
        Action = input('Do you want to replace step [1], add step [2], or do nothing [0] ?');
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
        end
    elseif stepOnsetDiff(iStep) < mean(stepOnsetDiff) - 5
        warning([' !!! Seems like there are too many steps around frame ' num2str(stepOnsets(iStep)) '!!' ]);
        Action = input('Do you want to replace step [1], remove step [2], or do nothing [0] ?');
        if Action == 0
        elseif Action == 1
            [stepOnsets(end+1), stepValues(end+1)] = ginput(1);
            plot(stepOnsets(end), stepValues(end), 'r*')
            [M, mIndex] = min(abs(stepOnsets(end) - stepOnsets(1:end-1)));
            stepOnsets(mIndex) = [];
            stepOnsets = round(sort(stepOnsets, 'ascend'));
            stepOnsetDiff = diff(stepOnsets);
        elseif Action == 2
            step2remove = input('Which step do you want to remove (index number)?');
            stepOnsets(step2remove) = [];
            stepValues(step2remove) = [];
            stepOnsetDiff = diff(stepOnsets);

        end
    end
end

end