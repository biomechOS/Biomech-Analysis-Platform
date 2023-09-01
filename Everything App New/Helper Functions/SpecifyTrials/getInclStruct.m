function [inclStruct]=getInclStruct(specifyTrials)

%% PURPOSE: RETURN THE INCLUSION CRITERIA FROM THE SPECIFY TRIALS.

global conn;

inclStruct=struct();

if isempty(specifyTrials)
    return;
end

stStr = getCondStr(specifyTrials);

sqlquery = ['SELECT UUID, Logsheet_Parameters FROM SpecifyTrials_Abstract WHERE UUID IN ' stStr];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if ~iscell(t.UUID)
    t.UUID = {t.UUID};
    t.Logsheet_Parameters = {t.Logsheet_Parameters};
end

uuids = t.UUID;
allParams = t.Logsheet_Parameters;

for i=1:length(uuids)

    currST=uuids{i};
    params = allParams{i};

    inclStruct.Include.Condition(i).Name=currST;    

    for j=1:length(params)
        inclStruct.Include.Condition(i).Logsheet(j).Name = params(j).Headers;
        inclStruct.Include.Condition(i).Logsheet(j).Logic = params(j).Logic;
        inclStruct.Include.Condition(i).Logsheet(j).Value = params(j).Value;
    end

end