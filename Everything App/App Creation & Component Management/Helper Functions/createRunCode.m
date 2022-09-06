function []=createRunCode(fig,path,archiveFolder,logsheetPathMAT,codePath,dataPath)

%% PURPOSE: GENERATE A RUN CODE TO BE STORED IN THE PROJECT'S ARCHIVE

% handles=getappdata(fig,'handles');

projectName=getappdata(fig,'projectName');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

[folderPath,name]=fileparts(path);

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
text{15}='macAddress=getComputerID(); % Get the unique ID for this computer';
text{16}='';
text{17}='% Initialize figure just for storing data';
text{18}='if exist(''gui'',''var'')==1';
text{19}='    close(gui); clear gui; % Close and delete the processing GUI';
text{20}='end';
text{21}='runCodeGUI=uifigure(''Visible'',''off'');';
text{22}=['setappdata(runCodeGUI,''projectName'',''' projectName ''');'];
text{23}='% close(runCodeGUI); clear runCodeGUI; % To close and delete the uifigure (which deletes all of the data)';
text{24}=['setappdata(runCodeGUI,''logsheetPathMAT'', NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT);'];
text{25}=['setappdata(runCodeGUI,''dataPath'', NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath);'];
text{26}=['setappdata(runCodeGUI,''codePath'', NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath);'];
text{27}='';

%% Check that the function numbers are 1-N (logsheet is 0) with no doubles or skips.
if ~(isempty(Digraph.Nodes.RunOrder{1}) || Digraph.Nodes.RunOrder{1}.Default_001==0)
    disp('Logsheet wrong, but do I care?');
    return;
end

allNums=NaN(length(Digraph.Nodes.RunOrder)-1,1);
fcnNames=cell(length(Digraph.Nodes.FunctionNames),1);
splitNames_Codes=cell(length(Digraph.Nodes.FunctionNames),1);
nodeNums=NaN(length(Digraph.Nodes.RunOrder),1);
for i=2:length(Digraph.Nodes.RunOrder) % Start with the logsheet
    if ~isstruct(Digraph.Nodes.RunOrder{i})
        continue;
    end
    currSplits=fieldnames(Digraph.Nodes.RunOrder{i});

    for j=1:length(currSplits)

        orderNum=Digraph.Nodes.RunOrder{i}.(currSplits{j});
        allNums(orderNum)=orderNum;
        fcnNames{orderNum}=Digraph.Nodes.FunctionNames{i};
        splitNames_Codes{orderNum}=currSplits{j};
        nodeNums(orderNum)=Digraph.Nodes.NodeNumber(i);

    end

end

try
    assert(isequal(allNums,(1:length(allNums))')); % Assert that all numbers are present with no doubles or skips
catch

end
n=length(text); % Number of lines initialized

%% Fill in each function in the script
for i=1:length(allNums)
    
    n=n+1; % Line to put comment on
    text{n}=['% #' num2str(i) ' ' fcnNames{i}];
    n=n+1;
    text{n}=['runCodeFunc(runCodeGUI, ''' fcnNames{i} ''', ''' splitNames_Codes{i} ''', ' num2str(nodeNums(i)) ');'];
    n=n+1;
    text{n}=''; % Space between functions

end

%% Write the text to the path
fid=fopen(path,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);