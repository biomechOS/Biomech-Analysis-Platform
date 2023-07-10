function []=fillProcessGroupUITree(src)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE.
% If a group is selected in the current analysis UI tree, then put in all
% the elements of the group.
% If a function is selected, then just put in that function.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupNode = handles.Process.analysisUITree.SelectedNodes;

if isempty(groupNode)
    return;
end

initUUID = groupNode.NodeData.UUID;
struct=loadJSON(initUUID);

[initAbbrev] = deText(initUUID);

if isequal(initAbbrev,'PG')
    list = struct.RunList; 
elseif isequal(initAbbrev,'PR')
    list = {initUUID};
end

% texts = getTextsFromUUID(list,handles.Process.allProcessUITree);

uiTree=handles.Process.groupUITree;

delete(uiTree.Children);

for i=1:length(list)
    uuid = list{i};

    struct = loadJSON(uuid);
    newNode=uitreenode(uiTree,'Text',struct.Text);
    newNode.NodeData.UUID = uuid;
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        createProcessGroupNode(newNode,uuid,handles);
    end  

end

if isequal(initAbbrev,'PR') % Process
    node = selectNode(handles.Process.groupUITree,initUUID);
end