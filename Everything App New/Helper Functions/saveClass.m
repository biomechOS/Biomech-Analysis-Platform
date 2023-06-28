function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO JSON FILE.

[~,~,abstractID]=deText(classStruct.Text);

slash=filesep;

filename=[class '_' classStruct.Text];

rootPath=getCommonPath();

if ~isempty(abstractID)
    rootPath=[rootPath slash class slash 'Instances'];
else
    rootPath=[rootPath slash class];
end

filepath=[rootPath slash filename];

if nargin<3
    date=datetime('now');
end

writeJSON(filepath,classStruct,date);