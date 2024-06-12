clear all; 
close all;
clc;

% Declare paths
pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');

Participants = {'Pilot02'; 'Pilot03'; 'Pilot04'; 'Pilot06'};
Sessions     = {'01'; '02'};
Conditions   = {'stimWalkST'; 'stimWalkDT';...
                'syncWalkST'; 'syncWalkDT'};
            
for iParticipant = length(Participants)

    for iSession = 1%:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/QTM/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        end

        for iCondition = 1%:length(Conditions)

            Data  = load([pathImport Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Force(1).Frequency;

            % Extact kenetic data from structure
            Kinetics = Data.(Conditions{iCondition}).Force(1).Force(3,~isnan(Data.(Conditions{iCondition}).Force(1).Force(3,:)))+...
                       Data.(Conditions{iCondition}).Force(2).Force(3,~isnan(Data.(Conditions{iCondition}).Force(2).Force(3,:)));

            % Extract step onsets
            [stepOnsets] = getSteps(Kinetics, Freq);

            % Extract cadence and step frequency
            [cadence, stepFreq] = getCadence(stepOnsets, Freq);

            % Store data in structure
            Steps.(Conditions{iCondition}).stepOnsets   = stepOnsets;
            Steps.(Conditions{iCondition}).stepFreq     = stepFreq;
            Steps.(Conditions{iCondition}).cadence      = cadence;
            Steps.(Conditions{iCondition}).sampFreq     = Freq;
            
            % Save structure
            save([pathExport '/dataStep'], 'Steps');

            clear Kinetics stepOnsets dataAll
            close all;

        end
        clear Steps

    end

end
