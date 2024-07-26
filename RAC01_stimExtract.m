clear all;
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');

Participants = {'Pilot02'; 'Pilot03'; 'Pilot04'; 'Pilot05'; 'Pilot06'; 'Pilot07'; 'Pilot08'; 'Pilot09'};
Sessions     = {'01'; '02'};
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
            load([pathImport '/Audio/' Conditions{iCondition} '.mat'])
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

            % Store data in structure
            RAC.([Conditions{iCondition}]).beatOnset(:,1)     = beatOnset; % Store beat onsets in structure
            RAC.([Conditions{iCondition}]).beatFrequency(1,1) = beatFreq;  % Store frequency in structure (other method)
            RAC.([Conditions{iCondition}]).BPM(1,1)           = BPM;       % Store BPM in structure
            RAC.(Conditions{iCondition}).sampFreq             = Freq;

            % Save structure
            save([pathExport 'dataRAC.mat'], 'RAC');
            
            clear Audio beatOnset IOI dataAll            
            close all;

        end %Conditions
        clear RAC dataAudio

    end %Sessions

end %Participants
