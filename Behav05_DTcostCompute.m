clear all;
close all;
clc;

% Declare paths
pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'Pilot07'; 'Pilot08'; 'Pilot09'}; 
Sessions     = {'01'; '02'; '03'};

Conditions   = {'stimTap'; 'stimWalk';...
                'syncTap'; 'syncWalk'};
Variables    = {'imiMean'; 'imiCV'; 'IBIDeviation'; 'phaseAngleMean'; 'resultantLength'; 'power'; 'phaseR'; 'stabilityIndex'};


for iParticipant = 1:length(Participants)

    for iSession = 1%:length(Sessions)

        % Load data
        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsBehav.mat'])
        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsSync.mat'])
        load([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsEEG.mat'])
    
        for iCondition = 1:length(Conditions)

            % DT cost calculation
            for iVar = 1:length(Variables)
                
                if strcmpi(Variables{iVar}, 'imiMean') == 1 || strcmpi(Variables{iVar}, 'imiCV') == 1
                    scoreST = resultsBehav.([Conditions{iCondition} 'ST']).([Variables{iVar}]);
                    scoreDT = resultsBehav.([Conditions{iCondition} 'DT']).([Variables{iVar}]);
                elseif strcmpi(Variables{iVar}, 'IBIDeviation') == 1 || strcmpi(Variables{iVar}, 'phaseAngleMean') == 1 || strcmpi(Variables{iVar}, 'resultantLength') == 1
                    scoreST = resultsSync.([Conditions{iCondition} 'ST']).([Variables{iVar}]);
                    scoreDT = resultsSync.([Conditions{iCondition} 'DT']).([Variables{iVar}]);
                else
                    scoreST = resultsEEG.([Conditions{iCondition} 'ST']).([Variables{iVar}]);
                    scoreDT = resultsEEG.([Conditions{iCondition} 'DT']).([Variables{iVar}]);
                end

                resultsDtCost.(Conditions{iCondition}).(Variables{iVar}) = abs(((scoreDT - scoreST) / scoreST)*100);

            end % end Variables

        end % end Conditions

        % Save results
        save([pathResults  Participants{iParticipant} '/' Sessions{iSession} '/resultsDtCost'], 'resultsDtCost');
        
        clear resultsDtCost resultsBehav resultsSync resultsEEG

    end % end Sessions

end % end Participants