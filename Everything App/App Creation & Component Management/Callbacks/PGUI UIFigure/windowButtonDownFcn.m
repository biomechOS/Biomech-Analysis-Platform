function []=windowButtonDownFcn(src,currPoint)

%% PURPOSE: RECORD WHEN THE MOUSE BUTTON IS CLICKED (DOWN). ONLY ACTIVATES IF THE CLICK WAS ON THE UIAXES OBJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

if isempty(fig.CurrentObject)
    return;
end

xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;

if exist('currPoint','var')~=1
    currPoint=handles.Process.mapFigure.CurrentPoint;
    currPoint=currPoint(1,1:2);
    runLog=true;
else
    runLog=false;
end

if currPoint(1)>=xlims(1) && currPoint(1)<=xlims(2) && currPoint(2)>=ylims(1) && currPoint(2)<=ylims(2) % Ensure the cursor is within the uiaxes
    setappdata(fig,'currentPointDown',currPoint);    
    if isequal(fig.SelectionType,'open')
        isIn=1;
        openMFile(fig,currPoint,isIn);
    end
    return;
end

isIn=0;
if isequal(fig.SelectionType,'open')
%     openMFile(fig,currPoint,isIn);
    return;
end

if isIn==1
    return; % Stop processing this if the click was inside the UIAxes.
end

if isequal(fig.CurrentObject.Tag,'VarsListbox')
    varName=handles.Process.varsListbox.Value;
    desc='Clicked on the variables UI tree';
elseif isprop(fig.CurrentObject,'NodeData') % isequal(fig.CurrentObject.Tag,'FunctionsUITree') %isequal(fig.CurrentObject,handles.Process.fcnArgsUITree)
    if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
        return;
    end
    %         if ismember(fig.CurrentObject.Parent.Text,{'Inputs','Outputs'}
    varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;
    a=handles.Process.fcnArgsUITree.SelectedNodes.Parent;
    desc='Clicked on a variable in the functions UI tree';
    if ~isprop(a,'Text') || ~ismember(a.Text,{'Inputs','Outputs'}) % Ensure this is a variable name
        return;
    end
else
    return;
end

if runLog    
    updateLog(fig,desc);
end