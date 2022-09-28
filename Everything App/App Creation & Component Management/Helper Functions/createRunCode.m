function []=createRunCode(fig,path,archiveFolder,codePath)

%% PURPOSE: GENERATE A RUN CODE TO BE STORED IN THE PROJECT'S ARCHIVE

% handles=getappdata(fig,'handles');

slash=filesep;

projectName=getappdata(fig,'projectName');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

load(getappdata(fig,'logsheetPathMAT'),'logVar');

[folderPath,name]=fileparts(path);

macAddress=getComputerID();

logsheetPath=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath;
codePath=NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath;
dataPath=NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath;

%% Initialize the run code script
text{1}=['% function [] = ' name '()'];
text{2,1}='';
text{3}=['% Generated by '];
text{4}=['% From archive folder: ' archiveFolder];
text{5}='';
text{6}='% Must be located in the project''s code path to run (use the ''Load Archive'' button on the Projects tab)';
text{7}='% After using ''Load Archive'' all folder & file names must be named the same as they are in the archive (default names)';
text{8}='';
text{9}='% Set the projectSettingsMATPath';
text{10}=['projectSettingsMATPath = ''' projectSettingsMATPath ''';'];
text{11}='';
text{12}='% Load the project settings variables';
text{13}='load(projectSettingsMATPath,''Digraph'',''VariableNamesList'',''NonFcnSettingsStruct'');';
text{14}='';
text{15}=['logsheetPath = ''' logsheetPath ''';'];
text{16}=['dataPath = ''' dataPath ''';'];
text{17}=['codePath = ''' codePath ''';'];
text{18}='NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath = logsheetPath;';
text{19}='[path,name] = fileparts(logsheetPath);';
text{20}='slash = filesep;';
text{21}='logsheetPathMAT = [path slash name ''.mat'']; % The path name to the MAT file copy of the logsheet';
text{22}='';
text{23}='macAddress=getComputerID(); % Get the unique ID for this computer';
text{24}='NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT = logsheetPathMAT;';
text{25}='NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath = dataPath;';
text{26}='NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath = codePath;';
text{27}='';
text{28}='% Initialize a figure just for storing data';
text{29}='pguiHandle=findall(0,''Name'',''pgui''); % Get the handle to the processing GUI, if it exists';
text{30}='close(pguiHandle); clear pguiHandle; % Close and delete the processing GUI (does nothing if not open)';
text{31}='runCodeHiddenGUI=findall(0,''Name'',''runCodeHiddenGUI''); % Find all prior iterations of the hidden GUI';
text{32}='close(runCodeHiddenGUI); % Close prior iterations of the hidden GUI';
text{33}='runCodeHiddenGUI=uifigure(''Visible'',''off'',''Name'',''runCodeHiddenGUI'',''HandleVisibility'',''On'');';
text{34}=['setappdata(runCodeHiddenGUI,''projectName'',''' projectName ''');'];
text{35}='% close(runCodeHiddenGUI); clear runCodeHiddenGUI; % To close and delete the uifigure (which deletes all of its data)';
text{36}='setappdata(runCodeHiddenGUI, ''logsheetPath'', NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath);';
text{37}='setappdata(runCodeHiddenGUI, ''logsheetPathMAT'', NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT);';
text{38}='setappdata(runCodeHiddenGUI, ''dataPath'', NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath);';
text{39}='setappdata(runCodeHiddenGUI, ''codePath'', NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath);';
text{40}='load(logsheetPathMAT, ''logVar''); % Load the logsheet variable';
text{41}='';
text{42}='setappdata(runCodeHiddenGUI, ''NonFcnSettingsStruct'', NonFcnSettingsStruct);';
text{43}='setappdata(runCodeHiddenGUI, ''Digraph'', Digraph);';
text{44}='setappdata(runCodeHiddenGUI, ''VariableNamesList'', VariableNamesList);';
text{45}=['projectName=' '''' projectName '''' ';'];
text{46}='';
text{47}='%% Initialize the projectStruct';
text{48}='projectStruct=[];';
text{49}='';

%% Set up logsheet import code
if ~(isempty(Digraph.Nodes.RunOrder{1}) || Digraph.Nodes.RunOrder{1}.Default_001==0)
    disp('Logsheet wrong, but do I care?');
    return;
end

n=length(text);
n=n+1;
text{n}='%% Import metadata from the logsheet';
n=n+1;

columnHeaders=logVar(1,:);
columnHeadersChar='{';
for i=1:length(columnHeaders)
    columnHeadersChar=[columnHeadersChar '''' columnHeaders{i} ''', '];
end
columnHeadersChar=[columnHeadersChar(1:end-2) '}'];

dataTypesChar='{';
trialSubjectChar='{';
for i=1:length(columnHeaders)
    useHeaderName=genvarname(columnHeaders{i});
    dataTypesChar=[dataTypesChar '''' NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderName).DataType ''', '];
    trialSubjectChar=[trialSubjectChar '''' NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderName).TrialSubject ''', '];
end
dataTypesChar=[dataTypesChar(1:end-2) '}'];
trialSubjectChar=[trialSubjectChar(1:end-2) '}'];

numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;
subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
trialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;

text{n}=['columnHeaders = ' columnHeadersChar ';'];
n=n+1;
text{n}=['dataTypes = ' dataTypesChar ';'];
n=n+1;
text{n}=['trialSubject = ' trialSubjectChar ';'];
n=n+1;
text{n}='addLogVarsRunCode(columnHeaders, dataTypes, trialSubject); % Add the logsheet info metadata to the NonFcnSettingsStruct variable'; 
n=n+1;
text{n}=['numHeaderRows = ' num2str(numHeaderRows) ';'];
n=n+1;
text{n}=['subjIDColHeader = ''' subjIDColHeader ''';'];
n=n+1;
text{n}=['trialIDColHeader = ''' trialIDColHeader ''';'];
n=n+1;
text{n}='runLogImportButtonPushed(runCodeHiddenGUI, [], columnHeaders, numHeaderRows, subjIDColHeader, trialIDColHeader); % Import the metadata from the logsheet.';
n=n+1;
text{n}='';

%% Set up processing functions' metadata for the run code

numNodes=length(Digraph.Nodes.RunOrder)-1; % -1 because of the logsheet node already existing

allNums=NaN(numNodes,1);
fcnNames=cell(numNodes,1);
splitNames_Codes=cell(numNodes,1);
nodeNums=NaN(numNodes,1);
isImport=NaN(numNodes,1);
desc=cell(numNodes,1);
varNamesIn=cell(numNodes,1);
varNamesOut=cell(numNodes,1);
varNamesInCodeIn=cell(numNodes,1);
varNamesInCodeOut=cell(numNodes,1);
specifyTrials=cell(numNodes,1);
coords=NaN(numNodes,2);
levels=cell(numNodes,1);

for i=2:length(Digraph.Nodes.RunOrder) % Iterate over each function node, excluding the logsheet
    if ~isstruct(Digraph.Nodes.RunOrder{i})
        continue;
    end
    currSplits=fieldnames(Digraph.Nodes.RunOrder{i}); % The splits for the current function node.

    for j=1:length(currSplits) % Iterate over each split for this function node

        orderNum=Digraph.Nodes.RunOrder{i}.(currSplits{j}); % Get the run order for this node/split
        if orderNum==0
            beep;
            disp([Digraph.Nodes.FunctionNames{i} ' ' currSplits{j}])
            disp('Archive terminated. Cannot have a run order of zero!');
            return;
        end

        % Get all of the metadata for this function node
        allNums(orderNum)=orderNum;
        fcnNames{orderNum}=Digraph.Nodes.FunctionNames{i};
        splitNames_Codes{orderNum}=currSplits{j};
        nodeNums(orderNum)=Digraph.Nodes.NodeNumber(i);
        isImport(orderNum)=Digraph.Nodes.IsImport(i);
        desc{orderNum}=Digraph.Nodes.Descriptions{i};
        specifyTrials{orderNum}=Digraph.Nodes.SpecifyTrials{i};
        coords(orderNum,1:2)=Digraph.Nodes.Coordinates(i,:);
        levels{orderNum}=readLevel([codePath 'Processing Functions' slash fcnNames{orderNum} '.m'],isImport(orderNum));
        if isfield(Digraph.Nodes.InputVariableNames{i},currSplits{j})
            varNamesIn{orderNum}=Digraph.Nodes.InputVariableNames{i}.(currSplits{j});            
            varNamesInCodeIn{orderNum}=Digraph.Nodes.InputVariableNamesInCode{i}.(currSplits{j});            
        end     

        if isstruct(Digraph.Nodes.OutputVariableNames{i}) && isfield(Digraph.Nodes.OutputVariableNames{i},currSplits{j})
            varNamesOut{orderNum}=Digraph.Nodes.OutputVariableNames{i}.(currSplits{j});
            varNamesInCodeOut{orderNum}=Digraph.Nodes.OutputVariableNamesInCode{i}.(currSplits{j});
        end

    end

end

%% Check that the function numbers are 1-N (logsheet is 0) with no doubles or skips.
try
    assert(isequal(allNums,(1:length(allNums))')); % Assert that all numbers are present with no doubles or skips
catch

end
n=length(text); % Number of lines initialized

%% Fill in each function in the script. First, add the function to the settings variables. Then, run the function.
for i=1:length(allNums)
    
    n=n+1; % Line to put comment on
    text{n}=['%% ' fcnNames{i} ' (Node #' num2str(nodeNums(i)) ' Split ' splitNames_Codes{i} ')'];
    n=n+1;
    text{n}=['fcnName = ' '''' fcnNames{i} '''' ';'];
    n=n+1;
    text{n}=['fcnSplit = ' '''' splitNames_Codes{i} '''' ';'];
    n=n+1;
    text{n}=['nodeNumber = ' num2str(nodeNums(i)) ';'];
    n=n+1;
%     text{n}=['specifyTrials = ' '''' specifyTrials{i} '''' ';'];
    if ~isempty(specifyTrials{i})
        text{n}=['specifyTrials = ' '''' specifyTrials{i} '''' ';'];
    else
        text{n}=['specifyTrials = ' '''''' ';'];
    end
    n=n+1;
    text{n}=['runOrder = ' num2str(i) ';'];

    underscoreIdx=strfind(splitNames_Codes{i},'_');
    splitCode=splitNames_Codes{i}(underscoreIdx+1:end);
    splitName=splitNames_Codes{i}(1:underscoreIdx-1);
    nodeRow=find(ismember(Digraph.Nodes.NodeNumber,nodeNums(i))==1);
%     edgeRow=find((ismember(Digraph.Edges.NodeNumber(:,2),nodeNums(i)) & ismember(Digraph.Edges.SplitCode,splitCode))==1);
    edgeRow=find(ismember(Digraph.Edges.NodeNumber(:,2),nodeNums(i))==1);
    edgeRow=edgeRow(1); % Because all entries should be identical.

    n=n+1;
    text{n}=['prevFcnNodeNumber = ' num2str(Digraph.Edges.NodeNumber(edgeRow,1)) ';'];
    n=n+1;
    text{n}=['isImport = ' num2str(isImport(i)) ';'];
    n=n+1;
    text{n}=['coordinate = [' num2str(coords(i,1)) ', ' num2str(coords(i,2)) '];'];    

    % Input variable names
    varNamesInText='';
    for j=1:length(varNamesIn{i})
        if j>1
            varNamesInText=[varNamesInText '; ' '''' varNamesIn{i}{j} ''''];
        else
            varNamesInText=['{''' varNamesIn{i}{j} ''''];
        end
    end
    varNamesInText=[varNamesInText '}'];
    if isempty(varNamesIn{i})
        varNamesInText='{''''}';
    end
    n=n+1;
    text{n}=['inputVarNames = ' varNamesInText ';'];

    % Input variable names in code
    varNamesInCodeText='';
    for j=1:length(varNamesInCodeIn{i})
        if j>1
            varNamesInCodeText=[varNamesInCodeText '; ' '''' varNamesInCodeIn{i}{j} ''''];
        else
            varNamesInCodeText=['{''' varNamesInCodeIn{i}{j} ''''];
        end
    end
    varNamesInCodeText=[varNamesInCodeText '}'];
    if isempty(varNamesInCodeIn{i})
        varNamesInCodeText='{''''}';
    end
    n=n+1;
    text{n}=['inputVarNamesInCode = ' varNamesInCodeText ';'];

    % Output variable names
    varNamesInText='';
    for j=1:length(varNamesOut{i})
        if j>1
            varNamesInText=[varNamesInText '; ' '''' varNamesOut{i}{j} ''''];
        else
            varNamesInText=['{''' varNamesOut{i}{j} ''''];
        end
    end
    varNamesInText=[varNamesInText '}'];
    if isempty(varNamesOut{i})
        varNamesInText='{''''}';
    end
    n=n+1;
    text{n}=['outputVarNames = ' varNamesInText ';'];

    % Output variable names in code
    varNamesInCodeText='';
    for j=1:length(varNamesInCodeOut{i})
        if j>1
            varNamesInCodeText=[varNamesInCodeText '; ' '''' varNamesInCodeOut{i}{j} ''''];
        else
            varNamesInCodeText=['{''' varNamesInCodeOut{i}{j} ''''];
        end
    end
    varNamesInCodeText=[varNamesInCodeText '}'];
    if isempty(varNamesInCodeOut{i})
        varNamesInCodeText='{''''}';
    end
    n=n+1;
    text{n}=['outputVarNamesInCode = ' varNamesInCodeText ';'];

    n=n+1;
    text{n}='addFuncRunCode(fcnName, fcnSplit, inputVarNames, inputVarNamesInCode, outputVarNames, outputVarNamesInCode, nodeNumber, specifyTrials, runOrder, prevFcnNodeNumber, isImport, coordinate);';

    %% Run the function
    n=n+1;
    text{n}='inclStruct = feval(specifyTrials); % Returns the structure specifying metadata for which trials to include';
    n=n+1;
    text{n}='allTrialNames = getTrialNames(inclStruct, logVar, runCodeHiddenGUI, 0, []);';
    n=n+1;    
    text{n}=['setappdata(runCodeHiddenGUI, ''splitName'', ' '''' splitName '''' ');'];
    n=n+1;
    text{n}=['setappdata(runCodeHiddenGUI, ''splitCode'', ' '''' splitCode '''' ');'];
    n=n+1;
    text{n}=['setappdata(runCodeHiddenGUI, ''nodeRow'', ' num2str(nodeRow) ');'];

    level=levels{i};
    n=n+1;
    if ismember('P',level)
        if ismember('T',level)
            text{n}=[fcnNames{i} '(projectStruct, allTrialNames);'];
        elseif ismember('S',level)
            text{n}='subNames = fieldnames(allTrialNames);';
            n=n+1;
            text{n}=[fcnNames{i} '(projectStruct, subNames);'];
        else
            text{n}=[fcnNames{i} '(projectStruct);'];
        end
        n=n+1;
        text{n}='';
        continue;
    end

    text{n}='subNames = fieldnames(allTrialNames);';
    n=n+1;
    text{n}='for sub = 1:length(subNames)';
    n=n+1;
    text{n}='    subName = subNames{sub};';    

    if ~ismember('S',level)
        n=n+1;
        text{n}='    currTrials = fieldnames(allTrialNames.(subName));';
    else
        n=n+1;
        text{n}=['    disp([''Running ' fcnNames{i} ' '' fcnSplit '' Subject '' subName]);'];
    end
    
    n=n+1;
    if ismember('S',level)
        if ismember('T',level)
            text{n}=['    ' fcnNames{i} '(projectStruct, subName, allTrialNames.(subName));'];
        else
            text{n}=['    ' fcnNames{i} '(projectStruct, subName);'];
        end
    end

    n=n+1;
    if ismember('T',level) && ~ismember('S',level)
        text{n}='    for trialNum = 1:length(currTrials)';
        n=n+1;
        text{n}='        trialName = currTrials{trialNum};';
        n=n+1;
        text{n}=['        disp([''Running ' fcnNames{i} ' '' fcnSplit '' Subject '' subName '' Trial '' trialName]);'];
        n=n+1;
        text{n}='        for repNum = allTrialNames.(subName).(trialName)';
        n=n+1;
        switch isImport(i)            
            case 0
                text{n}=['            ' fcnNames{i} '(projectStruct, subName, trialName, repNum);'];
            case 1
                text{n}='            filePath = [dataPath subName slash trialName ''_'' subName ''_'' projectName ''.c3d''];';
                n=n+1;
                text{n}=['            ' fcnNames{i} '(filePath, projectStruct, subName, trialName, repNum);'];
        end

        n=n+1;
        text{n}='        end';
        n=n+1;
        text{n}='    end';
        
    elseif ~ismember('S',level) % Improperly read level
        error('Read error!');
    end

    n=n+1;
    text{n}='end';
    n=n+1;
    text{n}=''; % Space between functions

end

%% Write the text to the path
fid=fopen(path,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);