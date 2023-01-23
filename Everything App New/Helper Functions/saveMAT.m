function []=saveMAT(dataPath, desc, psText, Data, subName, trialName)

%% PURPOSE: SAVE DATA TO MAT FILE.

slash=filesep;

matFolder=[dataPath slash 'MAT Data Files'];

if ~exist('subName','var')==1
    matFolder=[matFolder slash 'Project'];    
else
    matFolder=[matFolder slash subName];

    if exist('trialName','var')==1
        matFolder=[matFolder slash trialName];
    else
        matFolder=[matFolder slash 'Subject'];
    end
end

piText=getPITextFromPS(psText);
matFolder=[matFolder slash piText];

currDate=datetime('now');

filePath=[matFolder slash psText '.mat'];

varNames={'Data'};

DateModified=currDate;
Description=desc;

varNames=[varNames, {'DateModified'}, {'Description'}];

try
    save(filePath,varNames{:},'-v6');
catch
    mkdir(matFolder);
    save(filePath,varNames{:},'-v6');
end