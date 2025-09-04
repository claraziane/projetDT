function[splitValue] = findMedianSplit(Variable, Condition, Structure)

pathResults  = ('/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/');

Participants = {'P01'; 'P02'; 'P03'; 'P04'; 'P07'; 'P08'; 'P09'; 'P10'; 'P11'; 'P12'; 'P13'; 'P15'; 'P16'; 'P17'; 'P18'; 'P19';...
                'P21'; 'P22'; 'P23'; 'P24'; 'P25'; 'P26'; 'P27'; 'P28'; 'P29'; 'P30'; 'P31'; 'P33'; 'P34'; 'P35'; 'P36'; 'P37';...
                'P38'; 'P39'; 'P40'; 'P41'; 'P42'; 'P43'; 'P44'; 'P45'};

for iParticipant = 1:length(Participants)

    % Load data
    DATA = load([pathResults Participants{iParticipant} '/01/' Structure '.mat']);
    if isempty(Condition)
        dataAll(iParticipant) = DATA.(Structure).(Variable);
    else
        dataAll(iParticipant) = DATA.(Structure).(Condition).(Variable);
    end

end
splitValue = nanmedian(dataAll);

end