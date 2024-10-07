clear all; 
% close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'};
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

        for iCondition = 1%2:length(Conditions)

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
