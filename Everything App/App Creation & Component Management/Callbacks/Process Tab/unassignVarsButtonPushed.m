function []=unassignVarsButtonPushed(src,event)

%% PURPOSE: REMOVE AN INPUT OR OUTPUT VARIABLE FROM THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

assert(ismember('Digraph',projectSettingsVarNames));

load(projectSettingsMATPath,'Digraph');

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
a=handles.Process.fcnArgsUITree.SelectedNodes;
b=a.Parent;

if ~isprop(b,'Text') || ~ismember(b.Text,{'Inputs','Outputs'}) % Ensure that this is a variable
    disp('Must have a variable name selected!');
    return;
end

for i=1:2
    if ~isempty(nodeNum)
        break;
    end
    a=a.Parent;
    nodeNum=a.NodeData;
end

assert(~isempty(nodeNum));

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;

if ismember({'Inputs'},b.Text)
    Digraph.Nodes.InputVariableNames{nodeRow}=Digraph.Nodes.InputVariableNames{nodeRow}(~ismember(Digraph.Nodes.InputVariableNames{nodeRow},varName));
    b=findobj(a,'Text','Inputs');
elseif ismember('Outputs',b.Text)
    Digraph.Nodes.OutputVariableNames{nodeRow}=Digraph.Nodes.OutputVariableNames{nodeRow}(~ismember(Digraph.Nodes.OutputVariableNames{nodeRow},varName));
    b=findobj(a,'Text','Outputs');
end

c=findobj(b,'Text',varName);
delete(c);

handles.Process.fcnArgsUITree.SelectedNodes=a;

% highlightedFcnsChanged(fig,Digraph,nodeNum);

save(projectSettingsMATPath,'Digraph','-append');