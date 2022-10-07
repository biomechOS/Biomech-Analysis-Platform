function []=varUpButtonPushed(src,event)

%% PURPOSE: MOVE A REPETITION OR DATA VARIABLE UP IN THE UITREE (LEFT IN THE TABLE)
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if isequal(class(selNode.Parent),'matlab.ui.container.Tree')
    disp('Must select the variable name!');
    return;
end

if ~isequal(class(selNode.Parent.Parent),'matlab.ui.container.Tree')
    disp('Must select the variable, not the function!');
    return;
end

parentNode=selNode.Parent;
cat=parentNode.Text;

nodeIdxNum=find(ismember(parentNode.Children,selNode)==1);

newIdx=nodeIdxNum-1; % Move it upwards in the list/left in the table

if newIdx==0
    return; % Was already at the top of the list
end

Stats.Tables.(tableName).([cat 'Columns'])([newIdx nodeIdxNum])=Stats.Tables.(tableName).([cat 'Columns'])([nodeIdxNum newIdx]); % Move the node in the temp var

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);
