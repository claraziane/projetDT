clear all;
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'};
Sessions     = {'01'};
Conditions   = {'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                'syncTapST'; 'syncWalkST';...
                'syncTapDT'; 'syncWalkDT'};
            
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataRAC.mat'], 'file')
            load([pathExport 'dataRAC.mat'])
        end

        for iCondition = 1:length(Conditions) 

            % Load data
            load([pathImport '/Audio/' Conditions{iCondition} '.mat'], 'dataAudio')
            Data  = load([pathImport '/QTM/' Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Analog.Frequency;

            % Define BPM
            if strcmp(Conditions{iCondition}(5:8), 'Walk') || strcmp(Conditions{iCondition}(5:8), 'Rest')
                preferredBPM = dataAudio.walkBPM;
            elseif strcmp(Conditions{iCondition}(5:7), 'Tap')
                preferredBPM = dataAudio.tapBPM  ;
            end
            
            % Extact audio data from structure
            Audio = Data.([Conditions{iCondition}]).Analog.Data(1,1:Freq*60*5);

            % Extract beat frequency, BPM, and IOI
            [beatFreq, BPM, IOI, beatOnset] = getBeat(Audio, Freq, preferredBPM);

            % Extract beat category
            if strcmpi(Conditions{iCondition}(end-1:end), 'DT')
                load([pathImport '/Expe/' Conditions{iCondition} '_Targets.mat'], 'Beats');
                Beats(Beats   == 0) = [];
                Beats = Beats(end-length(beatOnset)+1:end);
                 for iBeat = 1:length(beatOnset)
                     if Beats(iBeat) == 1
                         beatCat{iBeat, 1} = 'Standard';
                     elseif Beats(iBeat) == 2
                         beatCat{iBeat, 1} = 'targetLow';
                     elseif Beats(iBeat) == 3
                         beatCat{iBeat, 1} = 'targetHigh';
                     end
                end
            else
                for iBeat = 1:length(beatOnset)
                    beatCat{iBeat, 1} = 'Standard';
                end
            end

            % Store data in structure
            RAC.([Conditions{iCondition}]).beatOnset(:,1)     = beatOnset; % Store beat onsets in structure
            RAC.([Conditions{iCondition}]).beatFrequency(1,1) = beatFreq;  % Store frequency in structure (other method)
            RAC.([Conditions{iCondition}]).BPM(1,1)           = BPM;       % Store BPM in structure
            RAC.(Conditions{iCondition}).sampFreq             = Freq;
            RAC.(Conditions{iCondition}).beatCat              = beatCat;

            % Save structure
            save([pathExport 'dataRAC.mat'], 'RAC');
            
            clear Audio beatOnset IOI dataAudio         
            close all;

        end %Conditions
        clear RAC 

    end %Sessions

end %Participants
