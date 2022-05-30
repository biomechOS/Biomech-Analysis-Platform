function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE NUMBER OF HEADER ROWS IN THIS PROJECT'S LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

numHeaderRows=handles.Import.numHeaderRowsField.Value;

if isempty(numHeaderRows)
    return;
end

if numHeaderRows<0
    warning(['Number of header rows in logsheet cannot be negative']);
    return;
end

% Save the number of header rows to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

[~,hostname]=system('hostname'); % Get the name of the current computer
hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.NumHeaderRows=numHeaderRows;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

%% Check if the logsheet can/should be modified, if all metadata has been specified.
logsheetPath=NonFcnSettingsStruct.Import.Paths.(hostVarName).LogsheetPath;
logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(hostVarName).LogsheetPathMAT;
if exist(logsheetPath,'file')~=2
    return;
end

[~,~,logsheetVar]=xlsread(logsheetPath,1); % Reload the logsheet to accommodate any changes made. Has the downside of sometimes reading Excel files is glitchy.

subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;

% load(logsheetPathMAT,'logsheetVar'); % To load and modify the previously saved MAT logsheet

if all(ismember({subjIDColHeader,targetTrialIDColHeader},logsheetVar(1,:)))
    subjCodenames=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader));
    targetTrialIDs=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader));
    for i=1:length(subjCodenames)
        if ~isvarname(subjCodenames{i}) && ~isempty(subjCodenames{i})
            subjCodenames{i}=genvarname(subjCodenames{i});            
        end
        if ~isvarname(targetTrialIDs{i}) && ~isempty(targetTrialIDs{i})
            targetTrialIDs{i}=genvarname(targetTrialIDs{i});
        end
    end
    logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader))=subjCodenames;
    logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader))=targetTrialIDs;
    save(logsheetPathMAT,'logsheetVar','-v6'); % Save the MAT file version of the logsheet.
end

if exist(logsheetPathMAT,'file')~=2
    save(logsheetPathMAT,'logsheetVar','-v6'); % Save the MAT file version of the logsheet.
end