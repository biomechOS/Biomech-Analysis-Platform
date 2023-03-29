function []=assignGroupButtonPushed(src,text,parentText)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('text','var')~=1
    selNode=handles.Process.allGroupsUITree.SelectedNodes;

    if isempty(selNode)
        return;
    end

    processGroupName=selNode.Text;

    % Create a new project-specific process version
    if (isequal(selNode.Parent,handles.Process.allGroupsUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
        isNew=true;
    else
        isNew=false;
    end

    % PI node selected
    if isequal(selNode.Parent,handles.Process.allGroupsUITree)
        if length(selNode.Children)==1
            selNode=selNode.Children(1);
        elseif length(selNode.Children)>1
            disp('Multiple options, please select a project-specific option!');
            expand(selNode);
            return;
        end
    end
else

    % Create a new project-specific process version
    [name,id,psid]=deText(text);

    % Create a new project-specific process version
    piText=[name '_' id];
    slash=filesep;
    fileNames=getClassFilenames('ProcessGroup',[getCommonPath slash 'ProcessGroup' slash 'Implementations']);
    psNames=fileNames(contains(fileNames,piText));
    if isempty(psid) && isempty(psNames)
        isNew=true;
    else
        isNew=false;
    end

    % PI node selected
    if isempty(psid)
        if length(psNames)==1
            processGroupName=psNames{1}; % Without project-specific ID.
        elseif length(psNames)>1
            disp('Multiple options, please select a project-specific option!');
            return;
        end
    else
        processGroupName=text;
    end
end

if exist('parentText','var')~=1
    projectSettingsFile=getProjectSettingsFile();
    projectSettings=loadJSON(projectSettingsFile);
    Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
else
    Current_ProcessGroup_Name=parentText;
end

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
groupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

switch isNew
    case true
        processGroupPath=getClassFilePath(processGroupName, 'ProcessGroup');
        piStruct=loadJSON(processGroupPath);
        processGroupStruct=createProcessStruct_PS(piStruct);
    case false
        processGroupPath=getClassFilePath_PS(processGroupName, 'ProcessGroup');
        processGroupStruct=loadJSON(processGroupPath);
end

names=[names; {processGroupStruct.Text}];
types=[types; {'ProcessGroup'}];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

linkClasses(processGroupStruct, groupStruct); % Also saves the structs

if ~isequal(groupStruct.Text,handles.Process.currentGroupLabel.Text)
    return;
end

if isNew
    uitreenode(selNode,'Text',processGroupStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end

fillProcessGroupUITree(fig);

% newNode=uitreenode(handles.Process.groupUITree,'Text',processGroupStruct.Text);
% newNode.ContextMenu=handles.Process.psContextMenu;
% newNode.NodeData.Class='ProcessGroup';


