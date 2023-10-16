function [] = linkObjs_showNode(lUUID, rUUID, handles)

%% PURPOSE: LINK THE OBJECTS TOGETHER, AND CREATE THE NODE IN THE UI TREE.
% THIS MUST BE DONE DIFFERENTLY FOR SOME CLASSES VS. OTHERS.

global conn;

lType = deText(lUUID);
rType = deText(rUUID);

EndNodes = {lUUID, rUUID};

title = handles.Process.subtabCurrent.SelectedTab.Title;

% VR & PR. (covers input and output variables)
if all(ismember({lType, rType}, {'VR','PR'}))
    selNode = handles.Process.currentFunctionUITree.SelectedNodes;
    nodeText = strsplit(selNode.Text,' ');    
    struct.NameInCode = nodeText{1};
    if isequal(lType,'VR')
        tablename = 'VR_PR';
        struct.VR_ID = lUUID;
        struct.PR_ID = rUUID;
    else
        tablename = 'PR_VR';
        struct.PR_ID = lUUID;
        struct.VR_ID = rUUID;
    end
    sqlquery = ['DELETE FROM ' tablename ' WHERE PR_ID = ''' struct.PR_ID ''' AND NameInCode = ''' struct.NameInCode ''';'];
    execute(conn, sqlquery);
    if isequal(tablename,'VR_PR')
        struct.Subvariable = 'NULL';
        sqluery = ['INSERT INTO ' tablename '(PR_ID, VR_ID, NameInCode, Subvariable) VALUES (''' struct.PR_ID ''', ''' struct.VR_ID ''', ''' struct.NameInCode ''', ''' struct.Subvariable ''');'];
    else
        sqluery = ['INSERT INTO ' tablename '(PR_ID, VR_ID, NameInCode) VALUES (''' struct.PR_ID ''', ''' struct.VR_ID ''', ''' struct.NameInCode ''');'];
    end
    execute(conn, sqlquery);
    Current_Analysis = getCurrent('Current_Analysis');
    bool = linkObjs(struct.VR_ID, Current_Analysis);
else
    edgeTable = table(EndNodes);
    bool = linkObjs(edgeTable);
end

if ~bool
    return; % No new edge made.
end


%% Show the node.
if all(ismember({lType, rType}, {'VR', 'PR'})) && isequal(title,'Function')
    if isequal(lType,'VR')
        uuid = lUUID;
    else
        uuid = rUUID;
    end
    selNode.Text = [NameInCode ' (' uuid ')'];
end

% Create the node.
if isequal(title, 'Group')
    uiTree = handles.Process.groupUITree;    
elseif isequal(title,'Analysis')
    uiTree = handles.Process.analysisUITree;
end
selNode = getNode(uiTree, rUUID);
if isempty(selNode)
    selNode = uiTree;
end
node = addNewNode(selNode, lUUID, getName(lUUID));
uiTree.SelectedNodes = node;
selectNode(uiTree, node);
processCallbacks(uiTree);

