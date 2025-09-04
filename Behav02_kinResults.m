clear all; 
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};
Sessions     = {'01'; '02'};

Conditions   = {'stimTap'; 'syncTap'; 'stimWalk'; 'syncWalk'}; % 'noneTap'; 'noneWalk'; 
Comparisons  = {'ST'; 'DT'};

for iSession = 1%:length(Sessions)
    iPlot = 1;

    % Preallocate matrix
    imiCV      = nan(length(Participants),length(Conditions)*length(Comparisons));
    imiMean    = nan(length(Participants),length(Conditions)*length(Comparisons));
    cadence    = nan(length(Participants),length(Conditions)*length(Comparisons));
    stepLength = nan(length(Participants),length(Conditions)*length(Comparisons));
    lengthCV   = nan(length(Participants),length(Conditions)*length(Comparisons));

    for iCondition = 1:length(Conditions)

        for iParticipant = 1:length(Participants)

            % Load data
            pathImport = [pathResults Participants{iParticipant} '/' Sessions{iSession} '/'];
            load([pathImport 'resultsBehav.mat']);
            load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataStep.mat']);
            load([pathData Participants{iParticipant}  '/' Sessions{iSession} '/Behavioural/dataTap.mat']);

            for iCompare = 1:length(Comparisons)
                condName = [Conditions{iCondition} Comparisons{iCompare}];

                if  strcmpi(Conditions{iCondition}(1:4), 'none') == 1 && strcmpi(Comparisons{iCompare}, 'DT') == 1 %There is no DT condition in the none conditions
                else
                    imiCV(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiCV;
                    imiMean(iParticipant, iPlot+iCompare-1) = resultsBehav.(condName).imiMean;

                    if strcmpi(Conditions{iCondition}(5:7), 'Tap')
                        cadence(iParticipant, iPlot+iCompare-1) = Taps.(condName).cadence;
                    elseif strcmpi(Conditions{iCondition}(5:8), 'Walk')
                        cadence(iParticipant, iPlot+iCompare-1) = Steps.(condName).cadence;
%                         stepLength(iParticipant, iPlot+iCompare-1) = mean(Steps.(condName).stepLength);
%                         lengthCV(iParticipant, iPlot+iCompare-1) = std(Steps.(condName).stepLength)/mean(Steps.(condName).stepLength);

                    end

                end

            end % End Comparisons

            if iParticipant == length(Participants)
                iPlot = iPlot + 2; 
            end

        end % End Participants

    end % End Conditions
%     stepLength(isnan(stepLength)) = [];
%     stepLength = reshape(stepLength, length(Participants), []);
%     stepLength(:,3:6) = stepLength(:,2:5);
%     stepLength(:,2) = NaN;
% 
%     lengthCV(isnan(lengthCV)) = [];
%     lengthCV = reshape(lengthCV, length(Participants), []);
%     lengthCV(:,3:6) = lengthCV(:,2:5);
%     lengthCV(:,2) = NaN;

    % Plot
    plotScatter(imiCV, Comparisons, Conditions, 'Coefficient of Variation_{Inter-Movement Interval}');
    plotScatter(imiMean, Comparisons, Conditions, 'Inter-Movement Interval (ms)');
    plotScatter(cadence, Comparisons, Conditions, 'Cadence (movements per minute)');
%     plotScatter(stepLength, Comparisons, Conditions(4:end), 'Step Length (mm)');
%     plotScatter(lengthCV, Comparisons, Conditions(4:end), 'Coefficient of Variation_{stepLength}');


    % Save
    saveas(figure(1), [pathResults '/All/' Sessions{iSession} '/Motor/fig_mvtCV.png'])
    saveas(figure(2), [pathResults '/All/' Sessions{iSession} '/Motor/fig_mvtIMI.png'])
    saveas(figure(3), [pathResults '/All/' Sessions{iSession} '/Motor/fig_mvtCadence.png'])
%     saveas(figure(4), [pathResults '/All/' Sessions{iSession} '/Motor/fig_mvLength.png'])
    close all;

end % End Sessions