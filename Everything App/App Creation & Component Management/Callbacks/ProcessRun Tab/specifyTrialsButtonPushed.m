function []=specifyTrialsButtonPushed(src)

%% PURPOSE: OPEN THE FUNCTION'S SPECIFY TRIALS FILE

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;

if ~isletter(currTag(end-1)) % 2 digits
    currRow=str2double(currTag(end-1:end));
else % 1 digit
    currRow=str2double(currTag(end));
end

hArgsButton=findobj(fig,'Type','uibutton','Tag',['FcnArgsButton' num2str(currRow)]);

fcnNames=getappdata(fig,'processFcnNames');
fcnName=fcnNames{currRow}; % Format: 'fcnName_Process#'
fcnNameClean=strsplit(fcnName,'_Process');

specifyTrialsName=[fcnNameClean{1} '_Process' fcnNameClean{2} hArgsButton.Text '_SpecifyTrials.m'];

if ismac==1 
    slash='/';
else
    slash='\';
end

specifyTrialsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash specifyTrialsName];
if exist(specifyTrialsPath,'file')==2
    edit(specifyTrialsPath);
    return;
end

if exist([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials'],'dir')~=7
    mkdir([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials']);
end

% If the file does not exist yet, create it from the template.
templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'specifyTrials_Template.m'];

firstLine=['function [inclStruct]=' specifyTrialsName(1:end-2) '()'];
createFileFromTemplate(templatePath,specifyTrialsPath,firstLine)