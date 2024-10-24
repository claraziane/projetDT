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
Conditions   = {'testTap';
                'noneTapST';
                'stimTapST'; 'stimTapDT';...
                'syncTapST'; 'syncTapDT'};
            
for iParticipant = length(Participants)-1

    for iSession = 1

        % Declare paths
        pathImport = ([pathData 'RAW/' Participants{iParticipant} '/' Sessions{iSession} '/QTM/']);
        pathExport = ([pathData 'Processed/' Participants{iParticipant} '/' Sessions{iSession} '/Behavioural/']);

        if ~exist(pathExport, 'dir')
            mkdir(pathExport)
        elseif exist([pathExport 'dataTap.mat'], 'file')
            load([pathExport 'dataTap.mat'])
        end

        for iCondition = 2:length(Conditions)

            Data  = load([pathImport Conditions{iCondition} '.mat']);
            Freq  = Data.(Conditions{iCondition}).Analog.Frequency;

            if strcmpi(Conditions{iCondition}(1:4), 'test')
                Time = Freq*60*1;
            else
                Time = Freq*60*5;
            end

            % Extact tap data from structure
            tapData = Data.(Conditions{iCondition}).Analog.Data(2,1:Time);

            % Extract tap onsets
            [tapOnset, tapFreq, ITI, tapCadence] = getTaps(tapData, Freq);

            % Store data in structure
            Taps.([Conditions{iCondition}]).tapOnset(:,1) = tapOnset;   % Store tap onsets in structure
            Taps.([Conditions{iCondition}]).tapFreq(1,1)  = tapFreq;    % Store tap frequency in structure
            Taps.(Conditions{iCondition}).cadence         = tapCadence; % Store number of taps per minute in structure
            Taps.([Conditions{iCondition}]).ITI(:,1)      = ITI;        % Store inter-tap interval in structure
            Taps.(Conditions{iCondition}).sampFreq        = Freq;
            
            % Save structure
            save([pathExport 'dataTap.mat'], 'Taps');

            clear tapData tapOnset Data
            close all;

        end
        clear Taps

    end %Sessions

end %Participants
