function []=addGroupButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupName=promptName('Enter Group Name');

if isempty(groupName)
    return;
end

createProcessGroupStruct(fig,groupName);

searchTerm=getSearchTerm(handles.Process.groupsSearchField);

fillUITree(fig,'ProcessGroup',handles.Process.allGroupsUITree, ...
    searchTerm,handles.Process.sortGroupDropDown);