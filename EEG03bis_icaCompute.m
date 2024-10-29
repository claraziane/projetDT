%% Preprocessing data
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
else
    pathImport = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/';
    addpath('/Users/claraziane/Documents/Acad�mique/Informatique/MATLAB/eeglab2021.1')  % EEGLab
    addpath('/Users/claraziane/Documents/Acad�mique/Informatique/bemobil-pipeline');    % Bemobil pipeline
    addpath('/Users/claraziane/Documents/Acad�mique/Informatique/bemobil-pipeline/EEG_preprocessing')
    addpath('/Users/claraziane/Documents/Acad�mique/Informatique/bemobil-pipeline/AMICA_processing')
end

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'};
Sessions     = {'01'; '02'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';... 
                              'syncTapDT'; 'syncWalkDT'};

fileName  = 'preprocessed.set';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
projectDT_bemobil_config
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        pathExport = [pathImport 'All/' Sessions{iSession} '/'];
        load([pathExport 'icReject.mat'])

        for iCondition = 1:length(Conditions)
           
            condStr = Conditions{iCondition};
            pathRoot  = fullfile(pathImport, '03_Preprocessing', Participants{iParticipant}, Sessions{iSession},Conditions{iCondition});

            % Load
            EEG = pop_loadset('filename', fileName,'filepath', pathRoot);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            % Remove baseline of the signal (must be before filtering)
            EEG = pop_rmbase(EEG, [],[]);
            EEG = eeg_checkset(EEG);

            % ICA decomposition
            [ALLEEG, EEG, CURRENTSET] = bemobil_process_all_AMICA(ALLEEG, EEG, CURRENTSET, str2num(Participants{iParticipant}(end)), Sessions{iSession}, condStr, bemobil_config);

            icReject.([Participants{iParticipant}]).([Conditions{iCondition}]) = EEG.etc.ic_cleaning.ICs_throw;
            save([pathExport '/icReject.mat'], 'icReject');

            ALLEEG = [];

        end
        
    end
    
end