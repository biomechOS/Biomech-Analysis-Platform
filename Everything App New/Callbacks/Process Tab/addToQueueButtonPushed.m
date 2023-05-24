function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

checkedNodes=handles.Process.groupUITree.CheckedNodes;

if isempty(checkedNodes)
    checkedNodes=handles.Process.groupUITree.SelectedNodes;
    if isempty(checkedNodes)
        return;
    end
end

delIdx=[];
for i=1:length(checkedNodes)
    if ~isempty(checkedNodes(i).Children)
        delIdx=[delIdx; i];
    end
end

checkedNodes(delIdx)=[];

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);

if isfield(projectSettings,'ProcessQueue')
    queue={};
else
    queue=projectSettings.ProcessQueue;
end

if ~iscell(queue)
    queue={};
end

texts={checkedNodes.Text}'; % The process functions to add (checked in the process group list)

inQueueIdx=ismember(texts,queue);

if any(inQueueIdx)
    disp('No action taken. Already present in queue!');
    disp(texts(inQueueIdx));
    beep;
    return;
end

%% Check whether all pre-requisite variables are up to date.
% [texts]=checkDeps(texts);

queue=[queue; texts];

projectSettings.ProcessQueue=queue;

writeJSON(projectSettingsFile,projectSettings);

delete(handles.Process.queueUITree.Children);

for i=1:length(queue)
    uitreenode(handles.Process.queueUITree,'Text',queue{i});
end