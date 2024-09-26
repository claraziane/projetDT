clear;
close all;
clc;

% Declare paths
pathData    = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/RAW/';
pathResults = '/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/';

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'};
Sessions     = {'01'; '02'};
Conditions   = {'stimRest_DT'; 'stimTap_DT'; 'stimWalk_DT'; 'syncTap_DT'; 'syncWalk_DT'};

for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)
        dataCog = readtable([pathData Participants{iParticipant} '/' Sessions{iSession} '/Expe/oddball.xlsx']);


        for iCondition = 1:length(Conditions)
            for iLine = 1:size(dataCog,1)
                if strcmpi(dataCog.Var1{iLine}, Conditions{iCondition})
                    Condline = iLine;
                end
            end

            lowError  = abs(dataCog.TrueValue(Condline) - dataCog.Counted(Condline));
            highError = abs(dataCog.TrueValue_1(Condline) - dataCog.Counted_1(Condline));


            resultsOddball.(Conditions{iCondition}) = (lowError + highError)/2;

        end
        save([pathResults Participants{iParticipant} '/' Sessions{iSession} '/resultsOddball.mat'], 'resultsOddball');
        clear resultsOddball

    end


end
