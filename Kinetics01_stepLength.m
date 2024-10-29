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

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'};
Sessions     = {'01'};
Conditions   = {'noneWalkST';
                'stimWalkST'; 'stimWalkDT';...
                'syncWalkST'; 'syncWalkDT'};

distance = (28.31*2.54)*10;     

for iParticipant = length(Participants)-1

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
             Kinetics = Kinetics(~isnan(Kinetics));

            copLatFront = Data.(Conditions{iCondition}).Force(2).COP(1,:);
            copLatFront = copLatFront(~isnan(copLatFront));
            copForwardFront = Data.(Conditions{iCondition}).Force(2).COP(2,:);
            copForwardFront = copForwardFront(~isnan(copForwardFront));
          
            copLatRear = Data.(Conditions{iCondition}).Force(1).COP(1,:);
            copLatRear = copLatRear(~isnan(copLatRear));
            copForwardRear = Data.(Conditions{iCondition}).Force(1).COP(2,:) - distance;
            copForwardRear = copForwardRear(~isnan(copForwardRear));
            
            copOnset = [];
            copLoc   = [];
            stepOnsets = Steps.(Conditions{iCondition}).stepOnsets;
            for iStep = 2:length(stepOnsets)-1
                copFrontTemp = copForwardFront(stepOnsets(iStep)-100:stepOnsets(iStep)+100);
                copRearTemp  = copForwardRear(stepOnsets(iStep)-100:stepOnsets(iStep)+100);
                % figure; plot(copForward);
                [frontMax, frontFrame] = max(copFrontTemp);
                [rearMax, rearFrame] = max(copRearTemp);
                if rearMax < frontMax
                    copOnset = [copOnset; frontFrame];
                    copLoc   = [copLoc; frontMax];

                elseif rearMax > frontMax
                    copOnset = [copOnset; rearFrame];
                    copLoc   = [copLoc; rearMax];
                end
                
                if copOnset(end) < 101
                    copOnset(end) = stepOnsets(iStep) - (101 - copOnset(end));
                elseif copOnset(end) > 101
                    copOnset(end) = stepOnsets(iStep) + (copOnset(end) - 101);
                else
                    copOnset(end) = stepOnsets(iStep);
                end
                
            end

%             % Low-pass filter audio signal at 5 Hz to get signal envelop
%             [f,e] = butter(2,5*10/Freq);
%             copLatRearFilt = filtfilt(f,e,copLatRear);
%             copForwardRearFilt = filtfilt(f,e,copForwardRear);
%             copLatFrontFilt = filtfilt(f,e,copLatFront);
%             copForwardFrontFilt = filtfilt(f,e,copForwardFront);
% 
%             for iStep = 1:length(stepOnsets)
%                 figure;
%                 subplot(2,2,1); plot(copLatFrontFilt(stepOnsets(iStep):stepOnsets(iStep+1)-1)); ylabel('Medio-Lateral Displacement'); title('Front')
%                 subplot(2,2,2); plot(copLatRearFilt(stepOnsets(iStep):stepOnsets(iStep+1)-1)); title('Rear')
%                 subplot(2,2,3); plot(copForwardFrontFilt(stepOnsets(iStep):stepOnsets(iStep+1)-1)); ylabel('Antero-Posterior Displacement')  
%                 subplot(2,2,4); plot(copForwardRearFilt(stepOnsets(iStep):stepOnsets(iStep+1)-1));
%             end

            clear copLatRear copForwardRear stepOnsets 
            close all;

        end
        clear Steps

    end

end
