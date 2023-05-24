function []=assignLogsheetHeaderButtonPushed(src,event)

%% PURPOSE: ADD A LOGSHEET HEADER TO THE CURRENT SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.logsheetHeadersUITree.SelectedNodes;

if isempty(selNode)
    return;
end

title=fig.Name;
titleSplit=strsplit(title,' ');
specifyTrials=titleSplit{end};

fullPath=getClassFilePath(specifyTrials,'SpecifyTrials');
stStruct=loadJSON(fullPath);

%% Add header
header=selNode.Text;

uitreenode(handles.selectedLogsheetHeadersUITree,'Text',header);

stStruct.Logsheet_Headers=[stStruct.Logsheet_Headers; {header}];

%% Add logic
handles.logsheetLogicDropDown.Value='ignore';

stStruct.Logsheet_Logic=[stStruct.Logsheet_Logic; {'ignore'}];

%% Add logic value
handles.logsheetLogicValueEditField.Value='';

stStruct.Logsheet_Value=[stStruct.Logsheet_Value; {''}];

saveClass('SpecifyTrials', stStruct);

handles.selectedLogsheetHeadersUITree.SelectedNodes=handles.selectedLogsheetHeadersUITree.Children(end);