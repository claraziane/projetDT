clear all; 
close all;
clc;

% Declare paths
[ret, Computer] = system('hostname');
if strcmpi({Computer(end-5:end-1)}, 'BRAMS')
    pathData = ('C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\DATA\');
else
    pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');
end

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';... 
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36';...
                'P37'; 'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'};
Conditions   = {'testWalk';
                'noneWalkST';
                'stimWalkST'; 'stimWalkDT';...
                'syncWalkST'; 'syncWalkDT'};
            
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/QTM/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataStep.mat'], 'file')
            load([pathExport 'dataStep.mat'])
        end

        for iCondition = 1:length(Conditions)

            Data  = load([pathImport Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Force(1).Frequency;

            if strcmpi(Conditions{iCondition}(1:4), 'test')
                Time = Freq*60*1;
            else
                Time = Freq*60*5;
            end

            % Extact kenetic data from structure
            Kinetics = Data.(Conditions{iCondition}).Force(1).Force(3,1:Time)+...
                       Data.(Conditions{iCondition}).Force(2).Force(3,1:Time);

            % Extract step onsets
            [stepOnsets] = getSteps(Kinetics, Freq);

            % Extract cadence and step frequency
            [cadence, stepFreq] = getCadence(stepOnsets, Freq);

            % Store data in structure
            Steps.(Conditions{iCondition}).stepOnsets = stepOnsets;
            Steps.(Conditions{iCondition}).stepFreq   = stepFreq;
            Steps.(Conditions{iCondition}).cadence    = cadence;
            Steps.(Conditions{iCondition}).sampFreq   = Freq;
            
            % Save structure
            save([pathExport '/dataStep'], 'Steps');

            clear Kinetics stepOnsets Data
            close all;

        end
        clear Steps

    end

end
