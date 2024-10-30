%% Preprocessing data
% -Detects bad channels
% -Interpolates bad channels
% -Computes average ref
% -Computes ICA
% -Cleans data by removing IC tagged as eye

close all;
clear all;
clc;

[ret, Computer] = system('hostname');
if strcmpi({Computer(end-5:end-1)}, 'BRAMS')
    pathImport = 'C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\DATA\Processed\';
    addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\eeglab2021.1\eeglab2021.1\')  % EEGLab
    addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\bemobil-pipeline\bemobil-pipeline');    % Bemobil pipeline
    addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\bemobil-pipeline\bemobil-pipeline\EEG_preprocessing')
    addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\bemobil-pipeline\bemobil-pipeline\AMICA_processing')
    addpath('C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\zapline-plus-main\zapline-plus-main');
else
    pathImport = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/';
    addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1')  % EEGLab
    addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline');    % Bemobil pipeline
    addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/EEG_preprocessing')
    addpath('/Users/claraziane/Documents/Académique/Informatique/bemobil-pipeline/AMICA_processing')
    addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/zapline-plus-main')
end

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'};
Sessions     = {'01'; '02'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';... 
                              'syncTapDT'; 'syncWalkDT'};

extRoot  = '_events.set';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
projectDT_bemobil_config
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathImport 'All/' Sessions{iSession} '/'];
        pathRoot  = fullfile(pathImport, Participants{iParticipant}, Sessions{iSession}, '/EEG');

        load([pathExport 'chanReject.mat'])

        for iCondition = 1:length(Conditions)
            path2save = [pathImport '03_Preprocessing' filesep  Participants{iParticipant} filesep Sessions{iSession} filesep  Conditions{iCondition}];           

            % Load
            fileRead = [Conditions{iCondition} extRoot];
            EEG = pop_loadset('filename', fileRead,'filepath', pathRoot);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            % Remove line noise
            [ALLEEG EEG CURRENTSET] = bemobil_process_EEG_basics(ALLEEG, EEG, CURRENTSET,  [], {'ECG' 'x_dir' 'y_dir' 'z_dir'}, [], [], 'preprocessed.set', path2save , [], [], bemobil_config.zaplineConfig);

            %% Identify bad channels
            [chans_to_interp, chan_detected_fraction_threshold, detected_bad_channels, rejected_chan_plot_handle, detection_plot_handle] = ...
                bemobil_detect_bad_channels(EEG, ALLEEG, CURRENTSET, .7);

            if length(chans_to_interp) > EEG.nbchan/5
                warndlg(['In subject ' Participants{iParticipant} ', ' num2str(length(chans_to_interp)) ' of ' num2str(EEG.nbchan)...
                    ' channels were rejected, which is more than 1/5th!'])
            end

            EEG.etc.channel_rejection.detection_threshold = chan_detected_fraction_threshold;
            EEG.etc.channel_rejection.bad_channel_detection = detected_bad_channels;
            chanReject.([Participants{iParticipant}]).([Conditions{iCondition}]) = chans_to_interp;
            save([pathExport '/chanReject.mat'], 'chanReject');

            %% Interpolation of bad channels and average reference
            [ALLEEG, EEG, CURRENTSET] = bemobil_interp_avref(EEG , ALLEEG, CURRENTSET, chans_to_interp, 'preprocessed.set', path2save);

        end %Conditions

    end %Sessions
    
end %Participants