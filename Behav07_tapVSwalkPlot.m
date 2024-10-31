clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');

Participants = {'P01'; 'P02'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'none'; 'stim'; 'stim'; 'sync'; 'sync'};
Compare      = {'ST'; 'ST'; 'DT'; 'ST'; 'DT'};

var = {'imiMean'; 'imiCV'; 'cadence'};

xLabels = {'Tap'};
yLabels = {'Walk'};
Titles  = {'Silence (ST)'; 'Ignore (ST)'; 'Ignore (DT)'; 'Sync (ST)'; 'Sync (DT)'};
TitlesCog = {'Ignore'; 'Sync'};

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iVar = 1:length(var)
        xLabel = (xLabels{1});

%         for iY = 1:length(varY)
            yLabel = (yLabels{1});

            for iCondition = 1:length(Conditions)
                condX = strcat(Conditions{iCondition}, 'Tap', Compare{iCondition});
                condY = strcat(Conditions{iCondition}, 'Walk', Compare{iCondition});
                
                
                for iParticipant = 1:length(Participants)

                    if strcmpi(var{iVar}, 'cadence')
                        % Load data
                        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
                        load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);

                        dataX(iParticipant,iCondition) = Taps.(condX).(var{iVar});
                        dataY(iParticipant,iCondition) = Steps.(condY).(var{iVar});

                    else

                        % Load data
                        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBehav.mat'])
                               dataX(iParticipant,iCondition) = resultsBehav.(condX).(var{iVar});
                               dataY(iParticipant,iCondition) = resultsBehav.(condY).(var{iVar});

                        if strcmpi(Compare{iCondition}, 'DT')
                            load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCost.mat'])

                            dataXCog(iParticipant,iCondition) = resultsDtCost.(condX(1:end-2)).(var{iVar});
                            dataYCog(iParticipant,iCondition) = resultsDtCost.(condY(1:end-2)).(var{iVar});

                        end


                    end

                end

            end
            
            % Plot
            plotCorrel(dataX, dataY, xLabel, yLabel, Titles, 'Spearman')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/fig_' var{iVar} '_tapVSwalk.png']);

%             dataXCog(dataXCog == 0) = [];
%             dataYCog(dataYCog == 0) = [];
%             dataXCog = reshape(dataXCog, [], 2);
%             dataYCog = reshape(dataYCog, [], 2);
%             plotCorrel(dataXCog, dataYCog, xLabel, yLabel, TitlesCog, 'Spearman')
%             saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/figCog_' var{iVar} '_tapVSwalk.png']);

            clear dataX dataY dataXCog dataYCog
            iFig = iFig+1;
% 
%         end

    end
    close all;

end