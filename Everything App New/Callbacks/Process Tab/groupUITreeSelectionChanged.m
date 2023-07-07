function []=groupUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE CURRENT FUNCTION'S VARIABLES IN THE FUNCTIONS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

delete(handles.Process.functionUITree.Children);

abbrev = deText(uuid);
if isequal(abbrev,'PG')
    return;
end

fillCurrentFunctionUITree(fig);

%% Update which specifyTrials are checked.
processStruct=loadJSON(uuid);

specifyTrials=processStruct.SpecifyTrials;

specifyTrialsUITree=handles.Process.allSpecifyTrialsUITree;

checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree);