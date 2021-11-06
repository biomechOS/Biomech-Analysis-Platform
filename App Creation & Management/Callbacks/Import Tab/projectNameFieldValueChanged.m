function []=projectNameFieldValueChanged(src)

%% PURPOSE: STORE THE PROJECT NAME TO THE APP DATA, AND TO THE TEXT FILE IN THE DOCUMENTS FOLDER.

projectName=src.Value;

if isempty(projectName)
    return;
end

fig=ancestor(src,'figure','toplevel');
setappdata(fig,'projectName',projectName); % Store the project name to the app data.

% Check if this project name is already part of the drop down list (e.g. it's already an existing project, at least in name)
% If so, just change the drop down entry and update the metadata/edit fields accordingly.
dropDownList=fig.Children.Children(1,1).Children(5,1).Items;
existingProject=0; % Initialize that this project does not exist yet.
for i=1:length(dropDownList)
    if isequal(dropDownList{i},projectName) % If the new project name and one of the drop down items matches exactly
        fig.Children.Children(1,1).Children(5,1).Value=projectName;
        existingProject=1; % Indicates that this project was pre-existing.
        break;
    end
end

% If the project was pre-existing
if existingProject==1
    A=readAllProjects(); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
    projectNamePaths=isolateProjectNamesPaths(A,projectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data, & update the displays
    if isfield(projectNamePaths,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNamePaths.LogsheetPath);
        fig.Children.Children(1,1).Children(11,1).Value=getappdata(fig,'logsheetPath');
    end
    if isfield(projectNamePaths,'DataPath')
        setappdata(fig,'dataPath',projectNamePaths.DataPath);
        fig.Children.Children(1,1).Children(10,1).Value=getappdata(fig,'dataPath');
    end
    if isfield(projectNamePaths,'CodePath')
        setappdata(fig,'codePath',projectNamePaths.CodePath);
        fig.Children.Children(1,1).Children(9,1).Value=getappdata(fig,'codePath');
    end
    if isfield(projectNamePaths,'RootSavePlotPath')
        setappdata(fig,'rootSavePlotPath',projectNamePaths.RootSavePlotPath);
    end        
elseif existingProject==0
    % If not already existing, check if the allProjects file exists and/or make a new entry in the 'allProjects_ProjectNamesPaths.txt' file and save it.
    
end

%% Set the entered project name as the most recently used project at the end of the file.
mostRecentProjPrefix='Most Recent Project Name:';
for i=length(A):-1:1
    if length(A{i})>length(mostRecentProjPrefix) && isequal(A{i}(1:length(mostRecentProjPrefix)),mostRecentProjPrefix)
        A{i}=mostRecentProjPrefix;
        A{i}(length(mostRecentProjPrefix)+2:length(mostRecentProjPrefix)+2+length(projectName)-1)=projectName;
        break;
    end
end
fileName=getappdata(fig,'allProjectsTxtPath');
fid=fopen(fileName,'w');
fprintf(fid,'%s\n',A{1:end-1});
fprintf(fid,'%s',A{end});
fclose(fid);