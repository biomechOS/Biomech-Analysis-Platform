function []=codePathFieldValueChanged(src,event)

%% PURPOSE: PROPAGATE CHANGES TO THE CODE PATH EDIT FIELD TO THE SAVED SETTINGS AND THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

codePath=handles.Import.codePathField.Value;

if isempty(codePath) || isequal(codePath,'Path to Project Processing Code Folder')
    setappdata(fig,'codePath','');
    return;
end

if exist(codePath,'dir')~=7
    warning(['Selected code path does not exist: ' codePath]);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

if ~isequal(codePath(end),slash)
    codePath=[codePath slash];    
end

handles.Import.codePathField.Value=codePath;

if ~isempty(getappdata(fig,'codePath'))
    warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
    rmpath(genpath(getappdata(fig,'codePath'))); % Remove the old code path (if any) from the matlab path
    warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
end

setappdata(fig,'codePath',codePath);

[~,hostname]=system('hostname'); % Get the name of the current computer
hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.
projectSettingsMATPath=[codePath 'Settings_' projectName '.mat']; % The project-specific settings MAT file in the project's code folder

% 1. Load the project settings structure MAT file, if it exists.
if exist(projectSettingsMATPath,'file')==2
    NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
    NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;
end

% 3. If the project settings structure MAT file does not exist, initialize the project-specific settings with default values for all GUI components.
if exist(projectSettingsMATPath,'file')~=2
    % Just missing the data type-specific trial ID column header, and of course the UI trees and description text areas
    NonFcnSettingsStruct.Import.Paths.(hostVarName).DataPath='Data Path (contains ''Subject Data'' folder)';
    NonFcnSettingsStruct.Import.Paths.(hostVarName).LogsheetPath='Logsheet Path (ends in .xlsx)';
    NonFcnSettingsStruct.Import.Paths.(hostVarName).LogsheetPathMAT='';
    NonFcnSettingsStruct.Import.NumHeaderRows=-1;
    NonFcnSettingsStruct.Import.SubjectIDColHeader='Subject ID Column Header';
    NonFcnSettingsStruct.Import.TargetTrialIDColHeader='Target Trial ID Column Header';
    NonFcnSettingsStruct.Plot.RootSavePath='Root Save Path';
    NonFcnSettingsStruct.ProjectName=projectName;

    % Function-specific settings struct
end

NonFcnSettingsStruct.Import.Paths.(hostVarName).CodePath=codePath;

% eval([projectName '=NonFcnSettingsStruct;']); % Rename the NonFcnSettingsStruct to the projectName
if exist(projectSettingsMATPath,'file')==2
    save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');
else
    save(projectSettingsMATPath,'NonFcnSettingsStruct','-mat','-v6');
end

% Add the projectSettingsMATPath to the project-independent settings MAT path
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

settingsStruct.(hostVarName).projectSettingsMATPath=projectSettingsMATPath; % Store the project's settings MAT file path to the project-independent settings structure.

eval([projectName '=settingsStruct;']); % Rename the settingsStruct to the projectName

save(settingsMATPath,projectName,'-append'); % Save the project-independent settings MAT file.

addpath(genpath(getappdata(fig,'codePath'))); % Add the new code path to the matlab path

% Turn all component visibility on.
tabNames=fieldnames(handles);
tabNames=tabNames(~ismember(tabNames,'Tabs'));
for tabNum=1:length(tabNames) % Iterate through every tab
    compNames=fieldnames(handles.(tabNames{tabNum}));
    for compNum=1:length(compNames)
        if ~isequal(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,'TabGroup')
            handles.(tabNames{tabNum}).(compNames{compNum}).Visible=1;
        end
    end
end

% Propagate changes to the rest of the GUI.
switchProjectsDropDownValueChanged(fig);