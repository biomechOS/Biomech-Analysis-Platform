function []=currentProjectButtonPushed(src)

%% PURPOSE: SELECT THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

handles.Projects.projectsLabel.Text=selNode.Text;

rootSettingsFile=getRootSettingsFile();

Current_Project_Name=selNode.Text;

searchTerm=getSearchTerm(handles.Process.groupsSearchField);
sortDropDown=handles.Process.sortGroupsDropDown;
fillUITree(fig,'ProcessGroup',handles.Process.allGroupsUITree,searchTerm,sortDropDown);

save(rootSettingsFile,'Current_Project_Name','-append');

% Update visible group, update visible process functions, etc.
if ~isempty(getProjectPath)
    groupName=getCurrentProcessGroup();
    if isempty(groupName)
        return;
    end
    selectGroupButtonPushed(fig,groupName);
end