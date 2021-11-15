function []=projectNameFieldValueChanged(src)

%% PURPOSE: STORE THE PROJECT NAME TO THE APP DATA, AND TO THE TEXT FILE IN THE DOCUMENTS FOLDER.
% After the project is specified, there will always be a 'allProjects_ProjectNamesPaths.txt' file (unless deleted)

projectName=src.Value;

fig=ancestor(src,'figure','toplevel');
if isempty(projectName)
    src.Value=getappdata(fig,'projectName');
    if isempty(src.Value) % Because there was no prior projectName stored
        src.Value='Project Name';
    end
    return;
end

% Once a project name has been created, make everything visible!
projNameLabel=findobj(fig,'Type','uilabel','Tag','ProjectNameLabel');
projNameField=findobj(fig,'Type','uilabel','Tag','ProjectNameField');
if isempty(getappdata(fig,'projectName'))
    visStat='off';
else
    visStat='on';
end

h=findall(fig.Children.Children(1,1));
for i=1:length(h)
    if ismember(h(i),[projNameLabel projNameField]) % Ignore the project name textbox and label.
        h(i).Visible='on';
    else
        if isfield(h(i),'Visible')
            h(i).Visible=visStat;
        end
    end
end

fileName=getappdata(fig,'allProjectsTxtPath'); % Get the 'allProjects_ProjectNamesPaths.txt' path.
everythingPath=getappdata(fig,'everythingPath');
setappdata(fig,'projectName',projectName); % Store the project name to the app data.

A=readAllProjects(getappdata(fig,'everythingPath')); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
if iscell(A)
    allProjectsList=getAllProjectNames(A);
    existingProject=1;
else
    existingProject=0;
end

% Check if this project name is already part of the drop down list (e.g. it's already an existing project, at least in name)
% If so, just change the drop down entry and update the metadata/edit fields accordingly.
hDropdown=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
if existingProject==1
    hDropdown.Items=allProjectsList;
    dropDownList=hDropdown.Items;
    for i=1:length(dropDownList)
        if isequal(dropDownList{i},projectName) % If the new project name and one of the drop down items matches exactly
            hDropdown.Value=projectName;
            break;
        end
    end
end

hLog=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
hData=findobj(fig,'Type','uieditfield','Tag','DataPathField');
hCode=findobj(fig,'Type','uieditfield','Tag','CodePathField');
hRootSave=findobj(fig,'Type','uieditfield','Tag','RootSavePlotPathField');
hNumHeaderRows=findobj(fig,'Type','uinumericeditfield','Tag','NumHeaderRowsField');
hSubjIDColHeader=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
hTrialIDColHeader=findobj(fig,'Type','uieditfield','Tag','TrialIDColumnHeaderField');
hTrialIDFormat=findobj(fig,'Type','uieditfield','Tag','TrialIDFormatField');
hTargetTrialIDFormat=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDFormatField');
hGroupsDataToLoad=findobj(fig,'Type','uipanel','Tag','SelectDataPanel');
% If the project was pre-existing
if existingProject==1    
    projectNameInfo=isolateProjectNamesInfo(A,projectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data, & update the displays   
    % Logsheet Path
    if isfield(projectNameInfo,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNameInfo.LogsheetPath);        
        hLog.Value=getappdata(fig,'logsheetPath');
    else% Set to default
        setappdata(fig,'logsheetPath','');
        hLog.Value='Set Logsheet Path';
    end
        
    % Data Path
    if isfield(projectNameInfo,'DataPath')
        setappdata(fig,'dataPath',projectNameInfo.DataPath);
        hData.Value=getappdata(fig,'dataPath');
    else
        setappdata(fig,'dataPath','');
        hData.Value='Data Path (contains ''Subject Data'' folder)';
    end
        
    % Code Path
    if isfield(projectNameInfo,'CodePath')
        setappdata(fig,'codePath',projectNameInfo.CodePath);
        hCode.Value=getappdata(fig,'codePath');
    else
        setappdata(fig,'codePath','');
        hCode.Value='Path to Project Processing Code Folder';
    end
    
    % Root Save Plot Path
    if isfield(projectNameInfo,'RootSavePlotPath')
        setappdata(fig,'rootSavePlotPath',projectNameInfo.RootSavePlotPath);
        hRootSave.Value=getappdata(fig,'rootSavePlotPath');
    else
        hRootSave.Value='Set Root Plot Save Path';
        setappdata(fig,'rootSavePlotPath','');
    end
    
    % Num Header Rows
    if isfield(projectNameInfo,'NumHeaderRows')
        setappdata(fig,'numHeaderRows',projectNameInfo.NumHeaderRows);
        hNumHeaderRows.Value=getappdata(fig,'numHeaderRows');
    else
        hNumHeaderRows.Value=0;
        setappdata(fig,'numHeaderRows','');
    end
    
    % Subject ID Col Header
    if isfield(projectNameInfo,'SubjIDColHeader')
        setappdata(fig,'subjIDColHeader',projectNameInfo.SubjIDColHeader);
        hSubjIDColHeader.Value=getappdata(fig,'subjIDColHeader');
    else
        hSubjIDColHeader.Value='Set Subject ID Column Header';
        setappdata(fig,'subjIDColHeader','');
    end
    
    % Trial ID Col Header
    if isfield(projectNameInfo,'TrialIDColHeader')
        setappdata(fig,'trialIDColHeader',projectNameInfo.TrialIDColHeader);
        hTrialIDColHeader.Value=getappdata(fig,'trialIDColHeader');
    else
        hTrialIDColHeader.Value='Set Trial ID Column Header';
        setappdata(fig,'trialIDColHeader');
    end
    
    % Trial ID Format
    if isfield(projectNameInfo,'TrialIDFormat')
        setappdata(fig,'trialIDFormat',projectNameInfo.TrialIDFormat);
        hTrialIDFormat.Value=getappdata(fig,'trialIDFormat');
    else
        hTrialIDFormat.Value='Set Trial ID Format';
        setappdata(fig,'trialIDFormat','');
    end
    
    % Target Trial ID Format
    if isfield(projectNameInfo,'TargetTrialIDFormat')
        setappdata(fig,'targetTrialIDFormat',projectNameInfo.TargetTrialIDFormat);
        hTargetTrialIDFormat.Value=getappdata(fig,'targetTrialIDFormat');
    else
        hTargetTrialIDFormat.Value='Set Target Trial ID Format';
        setappdata(fig,'targetTrialIDFormat','');
    end
    
    % Groups Data to Load
    if isfield(projectNameInfo,'GroupsDataToLoad')
        setappdata(fig,'groupsDataToLoad',projectNameInfo.GroupsDataToLoad);
%         hGroupsDataToLoad.Value=getappdata(fig,'groupsDataToLoad');
    else
%         hGroupsDataToLoad.Value='Set Data To Load';
        setappdata(fig,'groupsDataToLoad','');
    end    
    
    saveFile=0; % Indicates to not save the file again.
elseif existingProject==0
    % If not already existing, check if the allProjects file exists and/or make a new entry in the 'allProjects_ProjectNamesPaths.txt' file and save it.
    if exist(fileName,'file')~=2 % File does not exist.
        fid=fopen(fileName,'w'); % Create & open the file
        A{1}=['Project Name: ' projectName];
        A{2}='';
        A{3}=['Most Recent Project Name: ' projectName];
        fprintf(fid,'%s\n',A{1:end-1});
        fprintf(fid,'%s',A{end});
        fclose(fid); % Close the file
        saveFile=0; % Indicates to not save the file again.
    else % If file already exists, put new project at the end
        saveFile=1; % Indicates to save the file.
        A=readAllProjects(everythingPath);
        mostRecent=A(end-1:end); % Isolate last two lines (empty & most recent project name)
        A(end)={['Project Name: ' projectName]}; % Replace last line with project name
        A(length(A)+1:length(A)+2)=mostRecent; % Add two more lines
    end
    allProjectsList=getAllProjectNames(A);
    
    % Update the drop down list, and put the new project name as the current value.
    hDropdown.Items=allProjectsList;
    hDropdown.Value=projectName;
    
    % Set the other fields to their default values
    setappdata(fig,'logsheetPath','');
    hLog.Value='Set Logsheet Path';
    setappdata(fig,'dataPath','');
    hData.Value='Data Path (contains ''Subject Data'' folder)';
    setappdata(fig,'codePath','');
    hCode.Value='Path to Project Processing Code Folder';
    setappdata(fig,'rootSavePlotPath','');
    
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Change the project suffix for the importSettings, specifyTrials, and specifyVars buttons.
h=findobj(fig,'Type','uibutton','Tag','OpenImportSettingsButton');
% Check if the new project's importSettings file exists. If not, label it
% 'Create'. If so, label it 'Open'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'importSettings_' projectName '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
h.Text=[prefix ' importSettings_' projectName '.m'];

h=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
% Check if the new project's specifyTrials file exists. If not, label it
% 'Create'. If so, label it 'Open'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'specifyTrials_Import' projectName '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
h.Text=[prefix ' specifyTrials_Import' projectName '.m'];

%% Set the entered project name as the most recently used project at the end of the file.
if saveFile==1 % Indicates to save the file
    mostRecentProjPrefix='Most Recent Project Name:';
    for i=length(A):-1:1
        if length(A{i})>length(mostRecentProjPrefix) && isequal(A{i}(1:length(mostRecentProjPrefix)),mostRecentProjPrefix)
            A{i}=[mostRecentProjPrefix ' ' projectName];
            break;
        end
    end
    fid=fopen(fileName,'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);
end