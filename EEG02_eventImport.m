%% Importing events
% -Remove data before and after triggers
% -Import all beat onsets within EEG structure
% -Import all tap onsets within EEG structure
% -Import all step onsets within EEG structure

close all;
clear all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');
addpath('/Users/claraziane/Documents/Académique/Informatique/MATLAB/eeglab2021.1')

Participants = {'Pilot07'; 'Pilot08'; 'Pilot09'};
Sessions     = {'01'; '02'};
Conditions   = {'noneRestST'; 'noneTapST'; 'noneWalkST';...
                'stimRestST'; 'stimTapST'; 'stimWalkST';...
                'stimRestDT'; 'stimTapDT'; 'stimWalkDT';...
                              'syncTapST'; 'syncWalkST';... 
                              'syncTapDT'; 'syncWalkDT'};

extRoot  = '.set';
extFinal = '_events.set';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
for iParticipant =  length(Participants)

    for iSession = 1%:length(Sessions)

%         pathRaw = fullfile(pathData,'RAW/', Participants{iParticipant}, '/', Sessions{iSession}, '/EEG/');
        pathProcessed = fullfile(pathData, 'Processed/', Participants{iParticipant}, Sessions{iSession}, '/EEG/');
        
        if ~exist(pathProcessed, 'dir')
            mkdir(pathProcessed)
        end
        
        % Load events
        load([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession}, '/Behavioural/dataRAC.mat'])
        load([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession}, '/Behavioural/dataTap.mat'])
        load([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession}, '/Behavioural/dataStep.mat'])

        for iCondition = 1:length(Conditions)

            fileRead  = [Conditions{iCondition} extRoot];
            fileWrite = [Conditions{iCondition} extFinal];

            % Load data
            EEG = pop_loadset('filename', fileRead,'filepath', pathProcessed);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','on');

            %% Start/End triggers

            % Keep only signal inbetween start and end triggers
            triggers =  [EEG.event.latency];

            for iTrigger = 1:length(triggers)

                if strcmpi(({EEG.event(iTrigger).type(1:4)}), 'S 15')

                    if triggers(iTrigger) == min(triggers(iTrigger:end)) && ~exist('triggerStart','var')
                        triggerStart =  triggers(iTrigger) + (997.5/(1000/EEG.srate)); %Accounts for delay from qualisys and wireless trigger
                        triggerEnd   =  triggerStart + (EEG.srate*60*5) -1;
                    end

                end

            end
            EEG = pop_select(EEG,'time',[triggerStart/ALLEEG.srate triggerEnd/ALLEEG.srate]);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'overwrite', 'on', 'gui','off'); % Edit/save EEG dataset structure information
            
            disp(EEG.pnts)
            if EEG.pnts ~= EEG.srate*60*5
                warning(['Number of points incorrect for ' Participants{iParticipant} ' during ' Conditions{iCondition} '!!'])
                pause()
            end

            %% Beat onsets
            if strcmpi(Conditions{iCondition}(1:4), 'stim') || strcmpi(Conditions{iCondition}(1:4), 'sync')

                % Extract events' acquisition frequency
                beatRate = RAC.(Conditions{iCondition}).sampFreq;

                % Extract events from structure
                beatOnsets = RAC.(Conditions{iCondition}).beatOnset;

                % Interpolate values to fit EEG acquisition frequency
                beatOnsets = round(beatOnsets * (EEG.srate/beatRate));

                nEvents = length(EEG.event);
                for iEvent=1:length(beatOnsets)
                    EEG.event(nEvents+iEvent).type = 'RAC' ;
                    EEG.event(nEvents+iEvent).latency = beatOnsets(iEvent) ;
                    EEG.event(nEvents+iEvent).duration = 1 ;
                    EEG.event(nEvents+iEvent).urevent = nEvents+iEvent  ;
                end
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');

            end

            %% Taps      
            if strcmpi(Conditions{iCondition}(5:8), 'Rest')

            elseif strcmpi(Conditions{iCondition}(5:7), 'Tap')

                % Extract events' acquisition frequency
                tapRate = Taps.(Conditions{iCondition}).sampFreq;

                % Extract events from structure
                tapOnsets = Taps.(Conditions{iCondition}).tapOnset;

                % Interpolate values to fit EEG acquisition frequency
                tapOnsets = round(tapOnsets * (EEG.srate/tapRate));

                nEvents = length(EEG.event);
                for iEvent=1:length(tapOnsets)
                    EEG.event(nEvents+iEvent).type = 'Tap' ;
                    EEG.event(nEvents+iEvent).latency = tapOnsets(iEvent) ;
                    EEG.event(nEvents+iEvent).duration = 1 ;
                    EEG.event(nEvents+iEvent).urevent = nEvents+iEvent  ;
                end
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');

            %% Foot strikes
            else

                % Extract events' acquisition frequency
                stepRate = Steps.(Conditions{iCondition}).sampFreq;

                % Extract events from structure
                stepOnsets   = Steps.(Conditions{iCondition}).stepOnsets;

                % Interpolate values to fit EEG acquisition frequency
                stepOnsets   = round(stepOnsets * (EEG.srate/stepRate));

                nEvents = length(EEG.event);
                for iEvent=1:length(stepOnsets)
                    EEG.event(nEvents+iEvent).type = 'Step' ;
                    EEG.event(nEvents+iEvent).latency = stepOnsets(iEvent) ;
                    EEG.event(nEvents+iEvent).duration = 1 ;
                    EEG.event(nEvents+iEvent).urevent = nEvents+iEvent  ;
                end
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
           
            end

            % Save new _event.set file in preprocessed folder
            EEG = pop_saveset(EEG, 'filename', fileWrite, 'filepath', pathProcessed);

            ALLEEG = []; EEG = [];
            clear beatOnsets tapOnsets stepOnsets triggerStart triggerEnd triggers  

        end % Condtitions

        clear Taps Steps RAC

    end % Sessions

end % Participants