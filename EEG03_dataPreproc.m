%% Preprocessing data
% -Detects bad channels
% -Interpolates bad channels
% -Computes average ref
% -Computes ICA
% -Cleans data by removing IC tagged as eye, heart, muscle, heart, line
%  noise, channel noise


close all;
clear all;
clc;

pathImport = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/';
pathExport = [pathImport 'All/'];
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1'); %EEGLab
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline');    %Bemobil pipeline
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/EEG_preprocessing')
addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/AMICA_processing')

load([pathExport 'chanReject.mat'])
load([pathExport 'icReject.mat'])

Participants = {'Pilot07'; 'Pilot08'; 'Pilot09'};
Sessions     = {'01'; '02'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                 'syncTapST'; 'syncWalkST';...
                 'syncTapDT'; 'syncWalkDT'};

extRoot  = '_events.set';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
projectDT_bemobil_config
for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        pathRoot  = fullfile(pathImport, Participants{iParticipant}, Sessions{iSession}, '/EEG');

        for iCondition = 1:length(Conditions)
            condStr = Conditions{iCondition};

            % Load
            fileRead = [Conditions{iCondition} extRoot];
            EEG = pop_loadset('filename', fileRead,'filepath', pathRoot);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            % Remove line noise
            %        [ALLEEG EEG CURRENTSET] = bemobil_process_EEG_basics(ALLEEG, EEG, CURRENTSET, pathChan, [], [], [], 'Preproc', pathPreproc, [], 'FCz');

            %% Identify bad channels
            [chans_to_interp, chan_detected_fraction_threshold, detected_bad_channels, rejected_chan_plot_handle, detection_plot_handle] = ...
                bemobil_detect_bad_channels(EEG, ALLEEG, CURRENTSET, .6);

            if length(chans_to_interp) > EEG.nbchan/5
                warndlg(['In subject ' Participants{iParticipant} ', ' num2str(length(chans_to_interp)) ' of ' num2str(EEG.nbchan)...
                    ' channels were rejected, which is more than 1/5th!'])
            end

            EEG.etc.channel_rejection.detection_threshold = chan_detected_fraction_threshold;
            EEG.etc.channel_rejection.bad_channel_detection = detected_bad_channels;
            chanReject.([Participants{iParticipant}]).([Conditions{iCondition}]) = chans_to_interp;
            save([pathExport '/' Sessions{iSession} '/chanReject.mat'], 'chanReject');

            %% Interpolation of bad channels and average reference
            [ALLEEG, EEG, CURRENTSET] = bemobil_interp_avref(EEG , ALLEEG, CURRENTSET, chans_to_interp);
            EEG = eeg_checkset(EEG);

            % Remove baseline of the signal (must be before filtering)
            EEG = pop_rmbase(EEG, [],[]);
            EEG = eeg_checkset(EEG);

            %% ICA decomposition

            [ALLEEG, EEG, CURRENTSET] = bemobil_process_all_AMICA(ALLEEG, EEG, CURRENTSET, str2num(Participants{iParticipant}(end)), Sessions{iSession}, condStr, bemobil_config);

            icReject.([Participants{iParticipant}]).([Conditions{iCondition}]) = EEG.etc.ic_cleaning.ICs_throw;
            save([pathExport '/' Sessions{iSession} '/icReject.mat'], 'icReject');

            ALLEEG = [];

        end %Conditions

    end %Sessions
    
end %Participants