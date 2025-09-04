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

    for iInteraction = 2:3

        % Preallocate matrix
        DATA = nan(length(Participants),2*2);

        for iCondition = 1:2

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

                for iCompare = 1:2

                    if iInteraction == 1  % Movement*Difficulty
                        condName = [Mvt{iCondition} Difficulty{iCompare}];
                        if strcmpi(variables{iVariable}, 'resultantLength')
                            a = log(Structure.(structureName).([Instruction{1} condName]).([variables{iVariable}]) ./(1-Structure.(structureName).([Instruction{1} condName]).([variables{iVariable}])));
                            b = log(Structure.(structureName).([Instruction{2} condName]).([variables{iVariable}]) ./(1-Structure.(structureName).([Instruction{2} condName]).([variables{iVariable}])));
                            DATA(iParticipant, iPlot+iCompare-1) = (a + b)/2;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName]).([variables{iVariable}]))/2;
                        end
                    elseif iInteraction == 2 % Movement * Instruction
                        condName = [Instruction{iCompare} Mvt{iCondition}];
                        if strcmpi(variables{iVariable}, 'resultantLength')
                            a = log(Structure.(structureName).([condName Difficulty{1}]).([variables{iVariable}]) ./ (1-Structure.(structureName).([condName Difficulty{1}]).([variables{iVariable}])));
                            b = log(Structure.(structureName).([condName Difficulty{2}]).([variables{iVariable}]) ./ (1-Structure.(structureName).([condName Difficulty{2}]).([variables{iVariable}])));
                            DATA(iParticipant, iPlot+iCompare-1) = (a + b)/2;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condName Difficulty{1}]).([variables{iVariable}]) + Structure.(structureName).([condName Difficulty{2}]).([variables{iVariable}]))/2;
                        end
                    elseif iInteraction == 3 % Difficulty * Instruction
                        condFirst  = [Instruction{iCondition}];
                        condSecond = [Difficulty{iCompare}];
                        if strcmpi(variables{iVariable}, 'resultantLength')
                            a = log(Structure.(structureName).([condFirst Mvt{1} condSecond]).([variables{iVariable}]) ./ (1-Structure.(structureName).([condFirst Mvt{1} condSecond]).([variables{iVariable}])));
                            b = log(Structure.(structureName).([condFirst Mvt{2} condSecond]).([variables{iVariable}]) ./ (1-Structure.(structureName).([condFirst Mvt{2} condSecond]).([variables{iVariable}])));
                            DATA(iParticipant, iPlot+iCompare-1) = (a + b)/2;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condFirst Mvt{1} condSecond]).([variables{iVariable}]) + Structure.(structureName).([condFirst Mvt{2} condSecond]).([variables{iVariable}]))/2;
                        end

                    elseif iInteraction == 4 % Instruction * Beat Perception
                        condName = [Instruction{iCompare}];
                      
                        if strcmpi(beatPerceiver{iCondition}, 'Good')  && resultsBAASTA.BAT > splitBAT
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condName Mvt{1} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{1} Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([condName Mvt{2} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{2} Difficulty{2}]).([variables{iVariable}]))/4;
                        elseif strcmpi(beatPerceiver{iCondition}, 'Poor') && resultsBAASTA.BAT <= splitBAT
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condName Mvt{1} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{1} Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([condName Mvt{2} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{2} Difficulty{2}]).([variables{iVariable}]))/4;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end

                    elseif iInteraction == 5 % Movement * Beat Perception
                        condName = [Mvt{iCondition}];

                        if strcmpi(beatPerceiver{iCompare}, 'Good')  && resultsBAASTA.BAT > splitBAT
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        elseif strcmpi(beatPerceiver{iCompare}, 'Poor') && resultsBAASTA.BAT <= splitBAT
                                  DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end

                    elseif iInteraction == 6 % Mvt * rhythm skills
                        condName = [Mvt{iCondition}];

                        if strcmpi(rhythmSkills{iCompare}, 'Good')  && resultsBAASTA.BTI >= splitBTI
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        elseif strcmpi(rhythmSkills{iCompare}, 'Poor') && resultsBAASTA.BTI < splitBTI
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end

                    elseif iInteraction == 7 % Instruction * Rhythm skills
                        condName = [Instruction{iCondition}];

                        if strcmpi(rhythmSkills{iCompare}, 'Good')  && resultsBAASTA.BTI >= splitBTI
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condName Mvt{1} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{1} Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([condName Mvt{2} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{2} Difficulty{2}]).([variables{iVariable}]))/4;
                        elseif strcmpi(rhythmSkills{iCompare}, 'Poor') && resultsBAASTA.BTI < splitBTI
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([condName Mvt{1} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{1} Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([condName Mvt{2} Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([condName Mvt{2} Difficulty{2}]).([variables{iVariable}]))/4;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end
                    
                    elseif iInteraction == 8 %Diffculty * syncCost
                        condName = [Difficulty{iCondition}];

                        if strcmpi(syncCost{iCompare}, 'Great')  && abs(resultsDtCost.syncTap.resultantLength) > abs(splitRVL)
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
%                                 DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        elseif strcmpi(syncCost{iCompare}, 'Small') && abs(resultsDtCost.syncTap.resultantLength) < abs(splitRVL)
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
%                             DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end

                    elseif iInteraction == 9 %Diffculty * spontaneous tap synchronizers
                        condName = [Difficulty{iCondition}];
                        [p] = circ_rtest(deg2rad(resultsSync.stimTapST.phaseAngle));

                        if strcmpi(Synchronizers{iCompare}, 'issync')  && p < 0.05 %sync 
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
%                                 DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        elseif  strcmpi(Synchronizers{iCompare}, 'unsync')  && p >= 0.05 %unsync
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
%                             DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end
                    elseif iInteraction == 10
                        condName = [Mvt{iCondition}];
                        [p] = circ_rtest(deg2rad(resultsSync.stimTapST.phaseAngle));

                        if strcmpi(Synchronizers{iCompare}, 'issync')  && p < 0.05 %sync 
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        elseif  strcmpi(Synchronizers{iCompare}, 'unsync')  && p >= 0.05 %unsync
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} condName Difficulty{2}]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} condName Difficulty{1} ]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} condName Difficulty{2}]).([variables{iVariable}]))/4;
                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end
                    elseif iInteraction == 11 %Diffculty * spontaneous walk synchronizers
                        condName = [Difficulty{iCondition}];
                        [p] = circ_rtest(deg2rad(resultsSync.stimWalkST.phaseAngle));

                        if strcmpi(Synchronizers{iCompare}, 'issync')  && p < 0.05 %sync 
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
                                DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        elseif  strcmpi(Synchronizers{iCompare}, 'unsync')  && p >= 0.05 %unsync
                            DATA(iParticipant, iPlot+iCompare-1) = (Structure.(structureName).([Instruction{1} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{1} Mvt{2} condName]).([variables{iVariable}])...
                                + Structure.(structureName).([Instruction{2} Mvt{1} condName]).([variables{iVariable}]) + Structure.(structureName).([Instruction{2} Mvt{2} condName]).([variables{iVariable}]))/4;
                            DATA(iParticipant, iPlot) = log(DATA(iParticipant, iPlot) ./ (1-DATA(iParticipant, iPlot)));

                        else
                            DATA(iParticipant, iPlot+iCompare-1) = nan;
                        end




                    end

                end

                if iParticipant == length(Participants)
                    iPlot = iPlot + 2;
                end

            end % End Participants

        end % End Conditions

        if strcmpi(Category, 'EEG')
            Category = 'EEG/RESS';
        end

        if iInteraction == 1
            plotScatter(DATA, Difficulty, Mvt, yLabels{iVariable});
            title('Movement * Difficulty Interaction')
            saveas(figure(1), [pathResults '/All/01/' Category '/fig_' variables{iVariable} '_Mvt-Difficulty.png'])

        elseif iInteraction == 2
            plotScatter(DATA, Instruction, Mvt, yLabels{iVariable});
            title('Movement * Instruction Interaction')
            saveas(figure(2), [pathResults '/All/01/' Category '/fig_' variables{iVariable} '_Mvt-Instruction.png'])

        elseif iInteraction == 3
            plotScatter(DATA, Difficulty, Instruction, yLabels{iVariable});
            title('Instruction * Difficulty Interaction')
            saveas(figure(3), [pathResults '/All/01/' Category '/fig_' variables{iVariable} '_Difficulty-Instruction.png'])
     
%         elseif iInteraction == 4
%             plotScatter(DATA, Instruction, beatPerceiver, yLabels{iVariable});
%             title('Instruction * Beat Perception Interaction')
%             saveas(figure(4), [pathResults '/All/01/' Category '/fig_' variables{iVariable} '_Instruction-beatPerception.png'])
%         elseif iInteraction == 5
%             plotScatter(DATA, beatPerceiver, Mvt, yLabels{iVariable});
%             title('Beat Perception * Movement Interaction')
%             saveas(figure(5), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'beatPerception-Mvt.png'])
%         elseif iInteraction == 6
%             plotScatter(DATA, rhythmSkills, Mvt, yLabels{iVariable});
%             title('Rhythm Skills * Movement Interaction')
%             saveas(figure(6), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'rhythmSkills-Mvt.png'])
%         elseif iInteraction == 7
%             plotScatter(DATA, rhythmSkills, Instruction, yLabels{iVariable});
%             title('Rhythm Skills * Instruction Interaction')
%             saveas(figure(7), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'rhythmSkills-Instruction.png'])
%         elseif iInteraction == 8
%             plotScatter(DATA, Difficulty, syncCost, yLabels{iVariable});
%             title('Sync cost * Difficulty Interaction')
%             saveas(figure(8), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'syncCost-Difficulty.png'])
%         elseif iInteraction == 9
%             plotScatter(DATA, Difficulty, Synchronizers, yLabels{iVariable});
%             title('Spontaneous Tap Synchronizers * Difficulty Interaction')
%             saveas(figure(9), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'spontTapSync-Difficulty.png'])
%         elseif iInteraction == 10
%             plotScatter(DATA, Synchronizers, Mvt, yLabels{iVariable});
%             title('Spontaneous Tap Synchronizers * Movement Interaction')
%             saveas(figure(10), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'spontTapSync-Mvt.png'])
%         elseif iInteraction == 11
%             plotScatter(DATA, Difficulty, Synchronizers, yLabels{iVariable});
%             title('Spontaneous Walk Synchronizers * Movement Interaction')
%             saveas(figure(11), [pathResults '/All/01/' Category '/fig_' variables{iVariable} 'spontWalkSync-Mvt.png'])

       end
        iPlot = 1;

    end % End Interactions

end % End Variables