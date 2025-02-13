%% This script converts .eeg files to .set files
% -Load .eeg file
% -Import channel locations
% -Remove accelerometer data
% -Save as .set file

close all;
clear all;
clc;

% Declare paths
[ret, Computer] = system('hostname');
if strcmpi({Computer(end-5:end-1)}, 'BRAMS')
    pathData = ('C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\DATA\');
    addpath 'C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\eeglab2021.1\eeglab2021.1'
    chanStr = 'C:\Users\p1208638\OneDrive - Universite de Montreal\Documents\MATLAB\Toolbox\eeglab2021.1\eeglab2021.1\plugins\dipfit5.4\standard_BESA\standard-10-5-cap385.elp';

else
    pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');
    addpath('/Users/claraziane/Documents/Acad�mique/Informatique/MATLAB/eeglab2021.1')
    chanStr = '/Users/claraziane/Documents/Acad�mique/Informatique/MATLAB/eeglab2021.1/plugins/dipfit5.4/standard_BESA/standard-10-5-cap385.elp';
end

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29';  'P30'; 'P31'; 'P33'; 'P34'; 'P35'};
Sessions     = {'01'; '02'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';... 
                              'syncTapDT'; 'syncWalkDT'};

extRoot   = sprintf('.eeg');
extFinal  = sprintf('.set');

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        pathRaw       = fullfile(pathData, 'RAW/', Participants{iParticipant},  Sessions{iSession}, '/EEG/');
        pathProcessed = fullfile(pathData, 'Processed/', Participants{iParticipant},  Sessions{iSession}, '/EEG/');

        for iCondition = 1:length(Conditions)

            fileRead  = [pathRaw Conditions{iCondition} extRoot];
            fileWrite = [pathProcessed Conditions{iCondition} extFinal];

            % Create folder for participant's processed data
            if ~exist(pathProcessed, 'dir')
                mkdir(pathProcessed)
            end

            % Import .eeg data into EEGLab
            EEG = pop_fileio(fileRead);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); % Edit/save EEG dataset structure information
            EEG = eeg_checkset(EEG);
          
            % Remove accelerometer data
             EEG = pop_chanedit(EEG, 'changefield',{65,'type','ECG'}, 'changefield',{66,'type','Acc'}, 'changefield',{67,'type','Acc'},'changefield',{68,'type','Acc'});
             EEG = eeg_checkset(EEG);

            % Add channel location
            EEG = pop_chanedit(EEG, 'lookup',chanStr);
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); % Stores specified EEG dataset(s) in the ALLEEG variable

            % Save
            EEG = pop_saveset(EEG, fileWrite);

            % Delete data from ALLEEG
            ALLEEG = [];

        end % Conditions

    end % Sessions

end % Participants
