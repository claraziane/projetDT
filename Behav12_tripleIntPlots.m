clear all;
close all;
clc;

% Declare paths
pathData    = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/DATA/Processed/');
pathResults = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');
addpath('/Users/claraziane/Documents/Académique/Informatique/projectFig/'); %Functions for figures
addpath('/Users/claraziane/Documents/Académique/Informatique/Toolbox/CircStat2012a/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
    'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
    'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};

Mvt           = {'Tap'; 'Walk'};
Instruction   = {'stim'; 'sync'};
Difficulty    = {'ST'; 'DT'};
beatPerceiver = {'Good'; 'Poor'};
rhythmSkills  = {'Good'; 'Poor'};
syncCost      = {'Small'; 'Great'};
Synchronizers = {'issync'; 'unsync'};
mvtsyncCost   = {'smallTap'; 'greatTap'; 'smallWalk'; 'greatWalk'};
mvtSync       = {'syncTap'; 'unsyncTap'; 'syncWalk'; 'unsyncWalk'};


variables = {'imiCV'; 'imiMean'; 'resultantLength'; 'phaseR'; 'stabilityIndex'};
yLabels   = {'Coefficient of Variation_{Inter-Movement Interval}'; 'Inter-Movement Interval (ms)'; 'Synchronization Consistency'; 'Inter-Trial Phase Coherence'; 'Stability Index (Hz)'};

iPlot = 1;
for iVariable = 3

    if strcmpi(variables{iVariable}, 'imiCV') || strcmpi(variables{iVariable}, 'imiMean')
        Category = 'Motor';
        structureName = 'resultsBehav';
    elseif strcmpi(variables{iVariable}, 'resultantLength')
        Category = 'Sync';
        structureName = 'resultsSync';
    elseif strcmpi(variables{iVariable}, 'phaseR') || strcmpi(variables{iVariable}, 'stabilityIndex')
         Category = 'EEG';
         structureName = 'resultsEEG';
    end

    for iInteraction = 2

        % Preallocate matrix
        DATA = nan(length(Participants),2*2*2);

        for iParticipant = 1:length(Participants)

            % Load data
            pathImport = [pathResults Participants{iParticipant} '/01/'];
            load([pathImport 'resultsBAASTA.mat']);
            load([pathImport 'resultsDtCost.mat']);
            load([pathImport 'resultsSync.mat']);
            if strcmpi(Category, 'Motor') || strcmpi(Category, 'Sync')
                Structure = load([pathImport structureName '.mat']);
            elseif strcmpi(Category, 'EEG')
                Structure = load([pathImport 'RESS/' structureName '.mat']);
            end

            [splitBAT] = findMedianSplit('BAT', [], 'resultsBAASTA');
            [splitBTI] = findMedianSplit('BTI', [], 'resultsBAASTA');
            [splitRVL] = findMedianSplit('resultantLength', 'syncTap', 'resultsDtCost');

            for  iCondition = 1:2

                for iCompare = 1:2

                    if iInteraction == 1  % Mvt * Difficulty + SyncCost
 
                        condName = [Mvt{iCondition}];

                        for iDifficulty = 1:length(Difficulty)

                            if strcmpi(syncCost{iCompare}, 'Great')  && abs(resultsDtCost.syncTap.resultantLength) > abs(splitRVL)
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{1} condName Difficulty{iDifficulty}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{iDifficulty}]).([variables{iVariable}]))/2;
                            elseif strcmpi(syncCost{iCompare}, 'Small') && abs(resultsDtCost.syncTap.resultantLength) < abs(splitRVL)
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{1} condName Difficulty{iDifficulty}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{iDifficulty}]).([variables{iVariable}]))/2;
                            else
                                DATA(iParticipant, iPlot) = nan;
                            end
                            iPlot = iPlot+1;
                        end
                    
                    elseif iInteraction == 2  % Mvt * Instruction + SynchronizersTap
                    
                        [p] = circ_rtest(deg2rad(resultsSync.stimTapST.phaseAngle));

                        condName = [Mvt{iCondition}];

                        for iInstruction = 1:length(Instruction)

                            if strcmpi(Synchronizers{iCompare}, 'issync')  && p < 0.05 %sync 
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{iInstruction} condName Difficulty{1}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{iInstruction} condName Difficulty{2}]).([variables{iVariable}]))/2;
                                DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));
                            elseif strcmpi(Synchronizers{iCompare}, 'unsync')  && p >= 0.05 %unsync
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{iInstruction} condName Difficulty{1}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{iInstruction} condName Difficulty{2}]).([variables{iVariable}]))/2;
                                DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));
                            else
                                DATA(iParticipant, iPlot) = nan;
                            end
                            iPlot = iPlot+1;
                        end
                    elseif iInteraction == 3  % Mvt * Instruction * SyncCost
 
                        condName = [Mvt{iCondition}];

                        for iInstruction = 1:length(Instruction)


                            if strcmpi(syncCost{iCompare}, 'Great')  && abs(resultsDtCost.syncTap.resultantLength) > abs(splitRVL)
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{iInstruction} condName Difficulty{1}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{iInstruction} condName Difficulty{2}]).([variables{iVariable}]))/2;
%                                 DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));
                            elseif strcmpi(syncCost{iCompare}, 'Small') && abs(resultsDtCost.syncTap.resultantLength) < abs(splitRVL)
                                DATA(iParticipant, iPlot) = (Structure.(structureName).([Instruction{iInstruction} condName Difficulty{1}]).([variables{iVariable}]) + Structure.(structureName).([Instruction{iInstruction} condName Difficulty{2}]).([variables{iVariable}]))/2;
%                                 DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));
                            else
                                DATA(iParticipant, iPlot) = nan;
                            end
                            iPlot = iPlot+1;
                        end
                    end

                end


            end % End Participants

            if iCondition == 2
                iPlot = 1;
            end


        end % End Conditions

        if iInteraction == 1
            plotScatter(DATA, Difficulty, mvtsyncCost, yLabels{iVariable});
            title('Movement * Difficulty * syncCost Interaction')
            saveas(figure(1), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'syncCost-Mvt-Difficulty.png'])
        elseif iInteraction == 2
            plotScatter(DATA, Instruction, mvtSync, yLabels{iVariable});
            title('Movement * Instruction * Spontaneous Tap Synchronizers Interaction')
            saveas(figure(2), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'syncTap-Mvt-Instruction.png'])
        elseif iInteraction == 3
            plotScatter(DATA, Instruction, mvtsyncCost, yLabels{iVariable});
            title('Movement * Instruction * syncCost Interaction')
            saveas(figure(3), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'syncCost-Mvt-Instruction.png'])
        end
        iPlot = 1;

    end % End Interactions

end % End Variables