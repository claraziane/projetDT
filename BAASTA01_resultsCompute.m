clear all;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12';...
                'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19'; 'P21'; 'P22'; 'P23'; 'P24';...
                'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35';...
                'P36'; 'P37'; 'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'}; 

testName      = { 'BAT'; 'pacedTap'; 'Adaptive'; 'Anisochrony'}; 
Tests         = {'BAT_fast_dprime'; 'Paced_music_ross_mean'; 'Adaptive_short'; 'ThresholdEstimation_anisochrony_detection_tones'};
extensionNameTapping = {'itiCV'; 'itiMean'; 'Async'; 'Rayleigh'; 'asyncSEM'; 'vectorDir'; 'vectorLength'};
ExtensionsPacedTapping = {'_CV_iti';...
                            '_mean_iti';...
                            '_mean_absolute_asynchrony'; ...
                            '_rayleigh';...
                            '_sem_absolute_asynchrony';...
                            '_vector_direction'; ...
                            '_vector_length'};
ExtensionsAdaptive = {'_adaptation_index_acceleration'; '_adaptation_index_deceleration'; '_iso_600_CV_iti';      '_plus_75_dprime1';      '_plus_75_dprime2';      '_plus_30_dprime1';      '_plus_30_dprime2'; '_minus_75_dprime1'; '_minus_75_dprime2'; '_minus_30_dprime1';                 '_minus_30_dprime2'};
extensionNameAdaptive =           {'indexAcceleration';              'indexDeceleration';  'continuationCV'; 'sensitivityIndex1_p75'; 'sensitivityIndex2_p75'; 'sensitivityIndex1_p30'; 'sensitivityIndex2_p30'; 'sensitivityIndex1_m75'; 'sensitivityIndex2_m75'; 'sensitivityIndex1_m30'; 'sensitivityIndex2_m30'};

ExtensionsAnisochrony    = {'_600_best_thresh'; '_600_mean_thresh'};
extensionNameAnisochrony = {'thresholdBest'; 'thresholdMean'};

% Import test scores
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
            
            elseif strcmpi(testName{iTest}, 'pacedTap')
                iExtension = length(ExtensionsPacedTapping);

                for iVariable = 1:iExtension
                    resultsBAASTA.([testName{iTest}]).([extensionNameTapping{iVariable}]) = Scores.([Tests{iTest} ExtensionsPacedTapping{iVariable}])(participantIndex);

                    if strcmpi(([Tests{iTest} ExtensionsPacedTapping{iVariable}]), 'Paced_music_ross_mean_vector_length')
                        pacedTap(iParticipant, iSession) = Scores.([Tests{iTest} ExtensionsPacedTapping{iVariable}])(participantIndex);
                    end

                end

            elseif strcmpi(testName{iTest}, 'Adaptive')
                iExtension = length(ExtensionsAdaptive);

                for iVariable = 1:iExtension

                    if strfind(extensionNameAdaptive{iVariable}, 'sensitivityIndex1')
                        resultsBAASTA.([testName{iTest}]).([extensionNameAdaptive{iVariable}]) = ((Scores.([Tests{iTest} ExtensionsAdaptive{iVariable}])(participantIndex))+(Scores.([Tests{iTest} ExtensionsAdaptive{iVariable+1}])(participantIndex)))/2;                    
                    
                    elseif strfind(extensionNameAdaptive{iVariable}, 'sensitivityIndex2')
                    else
                        resultsBAASTA.([testName{iTest}]).([extensionNameAdaptive{iVariable}]) = Scores.([Tests{iTest} ExtensionsAdaptive{iVariable}])(participantIndex);

                    end

                end

            elseif strcmpi(testName{iTest}, 'Anisochrony')
                iExtension = length(ExtensionsAnisochrony);
                
                for iVariable = 1:iExtension
                    resultsBAASTA.([testName{iTest}]).([extensionNameAnisochrony{iVariable}]) = Scores.([Tests{iTest} ExtensionsAnisochrony{iVariable}])(participantIndex);
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