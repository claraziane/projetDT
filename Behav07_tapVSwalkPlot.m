clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/');
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stim'; 'stim'; 'sync'; 'sync'}; %'none'; 
Compare      = {  'ST';   'DT';   'ST';   'DT'};% {'ST'; 'ST'; 'DT'; 'ST'; 'DT'};

var = {'imiMean'; 'imiCV'; 'cadence'; 'phaseErrorMean'; 'phaseAngleMean'; 'resultantLength'; 'stabilityIndex'}; %{'imiMean'; 'imiCV'; 'cadence'}; 
figTitles = {'Inter-Movement Interval'; 'Variability of Inter-Movement Interval'; 'Cadence'; 'Phase Error'; 'Synchronization Accuracy'; 'Synchronization Consistency'; 'Stability Index (Hz)'}; %{'imiMean'; 'imiCV'; 'cadence'}; 

xLabels = {'Tap'};
yLabels = {'Walk'};
Titles  = {'Ignore (ST)'; 'Ignore (DT)'; 'Sync (ST)'; 'Sync (DT)'}; % 'Silence (ST)'; 
corrType = 'Spearman';

for iSession = 1%:length(Sessions)
    iFig = 1;

    for iVar = 4:length(var)
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

                    elseif strcmpi(var{iVar}, 'phaseErrorMean') || strcmpi(var{iVar}, 'phaseAngleMean') 
                        % Load data
                        load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/resultsSync.mat']);
                         [p] = circ_rtest(deg2rad(resultsSync.(condX).phaseAngle));
                        if p >= .05
                            dataX(iParticipant,iCondition) = NaN;
                            dataY(iParticipant,iCondition) = NaN;

                        else
                            dataX(iParticipant,iCondition) = rad2deg(resultsSync.(condX).(var{iVar}));
                            dataY(iParticipant,iCondition) = rad2deg(resultsSync.(condY).(var{iVar}));
                        end

                    elseif strcmpi(var{iVar}, 'resultantLength')
                        % Load data
                        load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/resultsSync.mat']);
                        dataX(iParticipant,iCondition) = log(resultsSync.(condX).(var{iVar}) ./ (1-resultsSync.(condX).(var{iVar})));
                        dataY(iParticipant,iCondition) = log(resultsSync.(condY).(var{iVar}) ./ (1-resultsSync.(condY).(var{iVar})));

                    elseif strcmpi(var{iVar}, 'stabilityIndex')
                        load([pathResults Participants{iParticipant}  '/' Sessions{iSession} '/RESS/resultsEEG.mat']);
                        dataX(iParticipant,iCondition) = resultsEEG.(condX).(var{iVar});
                        dataY(iParticipant,iCondition) = resultsEEG.(condY).(var{iVar});
                    
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
            plotCorrel(dataX, dataY, xLabel, yLabel, Titles, corrType)
            sgtitle([figTitles{iVar}], 'FontSize', 20, 'FontWeight', 'bold')
            saveas(figure(iFig), ['/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/' Sessions{iSession} '/tapVSwalk/fig_' var{iVar} '_tapVSwalk.png']);

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