clear all;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'};
Sessions     = {'01'}; %; '02'

testName      = { 'BAT'; 'pacedTap'}; %'Anisochrony'; ; 'Adaptive'
extensionName = {'itiCV'; 'itiMean'; 'Async'; 'Rayleigh'; 'asyncSEM'; 'vectorDir'; 'vectorLength'};
Tests         = {'BAT_fast_dprime'; 'Paced_music_ross_mean'}; %'XX'; ; 'Adaptive_short'
Extensions    = {'_CV_iti';...
                 '_mean_iti';...
                 '_mean_absolute_asynchrony'; ...
                 '_rayleigh';...
                 '_sem_absolute_asynchrony';...
                 '_vector_direction'; ...
                 '_vector_length'};
% '_adaptation_index_acceleration'; '_adaptation_index_decelaration'; '_iso_600_CV_iti'; '_plus_75_dprime1'; '_plus_75_dprime2'; '_plus_30_dprime1'; '_plus_30_dprime2'; '_minus_75_dprime1'; '_minus_75_dprime2'; '_minus_30_dprime1'; '_minus_30_dprime2';

% Import test scores
% Scores = readtable('/Volumes/p-rwage-indivdiff/baasta-scored/_SUMMARY_scored-pybaasta-0.8.1-newscoring.dev24-modified-TABA/all-scores.csv');
Scores = readtable([pathResults 'All/BAASTA_all-scores.csv']);

for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        % Create folder for participant's results if does not exist
        pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/');
        if ~exist(pathParticipant, 'dir')
            mkdir(pathParticipant)
        end

        % Find participant line in CSV file
        participantLine = Scores.subject;
                                        
        for iLine = 1:length(participantLine)
            if strcmpi(Participants{iParticipant}, participantLine{iLine})
                participantIndex = iLine;
            end
        end

        for iTest = 1:length(Tests)

            if strcmpi(testName{iTest}, 'BAT')
                resultsBAASTA.([testName{iTest}]) = Scores.([Tests{iTest}])(participantIndex);
                BAT(iParticipant, iSession) = Scores.([Tests{iTest}])(participantIndex);
            else
                iExtension = length(Extensions);

                for iVariable = 1:iExtension
                    resultsBAASTA.([testName{iTest}]).([extensionName{iVariable}]) = Scores.([Tests{iTest} Extensions{iVariable}])(participantIndex);

                    if strcmpi(([Tests{iTest} Extensions{iVariable}]), 'Paced_music_ross_mean_vector_length')
                        pacedTap(iParticipant, iSession) = Scores.([Tests{iTest} Extensions{iVariable}])(participantIndex);
                    end

                end
            end

        end
        %% Save results
        save([pathParticipant '/resultsBAASTA.mat'], 'resultsBAASTA');

    end

end

%% Compute Beat Tracking Index

% Z-score transform
for iSession = 1:length(Sessions)
    zBAT(:,iSession)    = (BAT(:,iSession) - mean(BAT(:,iSession)))/std(BAT(:,iSession));
    zTap(:,iSession)   = (pacedTap(:,iSession) - mean(pacedTap(:,iSession)))/std(pacedTap(:,iSession));

    % Compute beat tracking index
    BTI(:,iSession)  = mean(horzcat(zBAT, zTap),2);

    for iParticipant = 1:length(Participants)
        pathParticipant = fullfile(pathResults, Participants{iParticipant}, '/', Sessions{iSession}, '/');
        load([pathParticipant '/resultsBAASTA.mat'])
        
        % Store results in structure
        resultsBAASTA.BTI = BTI(iParticipant,iSession);

        %% Save results
        save([pathParticipant '/resultsBAASTA.mat'], 'resultsBAASTA');
                 
    end

end