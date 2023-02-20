function [newNode]=selectNeighborNode(currNode,dir)

%% PURPOSE: SELECT THE NEIGHBORING NODE IN UI TREE. IF NONE, SELECT THE PARENT NODE.

if exist('dir','var')~=1
    dir=1; % Select the next node down.
    % dir=0; % Select the next node up.
end

uiTree=getUITreeFromNode(currNode);

if isempty(currNode)
    newNode=[];
    uiTree.SelectedNodes=newNode;
    return;
end

parent=currNode.Parent;
children=parent.Children;

if length(children)==1
    newNode=parent;
    uiTree.SelectedNodes=newNode;
    return;
end

currIdx=find(ismember(children,currNode)==1);

if currIdx==1
    dir=1;
elseif currIdx==length(children)
    dir=0;
end

if dir==0
    newIdx=currIdx-1;
    if newIdx==0
        newIdx=newIdx+1;
    end
elseif dir==1
    newIdx=currIdx+1;
    if newIdx>length(children)
        newIdx=newIdx-1;
    end
end

newNode=children(newIdx);
uiTree.SelectedNodes=newNode;