clear all;
close all;
clc;

% Declare paths
[ret, Computer] = system('hostname');
if strcmpi({Computer(end-5:end-1)}, 'BRAMS')
    pathData = ('C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\DATA\');
    data     = readtable('C:\Users\p1208638\OneDrive - Universite de Montreal\Projets\projetDT\Results\All\demographicInfo.xlsx');
else
    pathData = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/');
    data     = readtable('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/demographicInfo.xlsx');
end

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'};
Sessions     = {'01'};
Conditions   = {'noneWalkST';
    'stimWalkST'; 'stimWalkDT';...
    'syncWalkST'; 'syncWalkDT'};

distance = (28.31*2.54)*10;

for iParticipant = 2:length(Participants)

    for iSession = 1%:length(Sessions)

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/QTM/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        for iLine = 1:size(data,1)
            if strcmpi(data.Var1{iLine}, Participants{iParticipant})
                treadmillSpeed = table2array(data(iLine,8));
            end
        end
   
        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataStep.mat'], 'file')
            load([pathExport 'dataStep.mat'])
        end

        for iCondition = 1:length(Conditions)

            Kinetics  = load([pathImport Conditions{iCondition} '.mat']);
            Freq  = Kinetics.(Conditions{iCondition}).Force(1).Frequency;
            frameHour = Freq*3600;
            speedFrame = (treadmillSpeed*1000000)/frameHour; %in cm by frame

            % Extact kenetic data from structure
            copForwardFront = Kinetics.(Conditions{iCondition}).Force(2).COP(2,:);
            copForwardFront = copForwardFront(~isnan(copForwardFront));

            copOnset = [];
            copLoc   = [];
            stepOnsets = Steps.(Conditions{iCondition}).stepOnsets;
            for iStep = 2:length(stepOnsets)-1
                copFrontTemp = copForwardFront(stepOnsets(iStep)-100:stepOnsets(iStep)+100);
                [frontMax, frontFrame] = max(copFrontTemp);

                    copOnset = [copOnset; frontFrame];
                    copLoc   = [copLoc; frontMax];

                if copOnset(end) < 101
                    copOnset(end) = stepOnsets(iStep) - (101 - copOnset(end));
                elseif copOnset(end) > 101
                    copOnset(end) = stepOnsets(iStep) + (copOnset(end) - 101);
                else
                    copOnset(end) = stepOnsets(iStep);
                end

            end
            
            stepLength = [];
            for iStep = 1:length(copOnset)-1
                time = copOnset(iStep+1) - copOnset(iStep);
                copDist = copLoc(iStep+1) - copLoc(iStep);
                stepLength = [stepLength;(speedFrame*time)+copDist];
            end
           
            stepLength(stepLength > (mean(stepLength)*2)) = [];
            stepLength(stepLength < 0) = [];
            figure; plot(stepLength)
            
            % Store data in structure
            Steps.(Conditions{iCondition}).stepLength = stepLength;
            
            % Save structure
            save([pathExport '/dataStep'], 'Steps');

            clear copForwardFront copFrontTemp stepOnsets Kinetics
            close;
            
        end
        clear Steps 

    end

end
