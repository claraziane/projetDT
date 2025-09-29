clear all;
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};
Conditions   = {'stimTapST';  'stimTapDT';  'syncTapST'; 'syncTapDT';...
               'stimWalkST'; 'stimWalkDT'; 'syncWalkST'; 'syncWalkDT'};
            
for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        % Load data
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);
        load([pathExport 'dataRAC.mat'])


        for iCondition = 1:length(Conditions)
            stimFreq(iParticipant, iCondition) = RAC.([Conditions{iCondition}]).beatFrequency;
        end

    end

end

for iCondition =1:length(Conditions)
    minFreq(iCondition) = min(stimFreq(:,iCondition));
    maxFreq(iCondition) = max(stimFreq(:,iCondition));
end
