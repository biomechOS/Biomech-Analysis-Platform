function []=plotButtonPushed(src,event)

%% PURPOSE: PLOT ALL SPECIFIED DATA.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile(fig);
projectSettings=loadJSON(projectSettingsFile);
plotName=projectSettings.Current_Plot_Name;

fullPath=getClassFilePath(plotName, 'Plot', fig);
plotStructPS=loadJSON(fullPath);

[plotNamePI,id]=deText(plotName);
plotNamePI=[plotNamePI '_' id];
fullPathPI=getClassFilePath(plotNamePI, 'Plot', fig);
plotStructPI=loadJSON(fullPathPI);

level=plotStructPS.Level; % How often the plot function is called.
multi=plotStructPS.Multi; % How many trials/subjects/conditions to put on each plot. Same valid values as "level"
isMovie=plotStructPI.IsMovie;
if isMovie==1
    level='T'; % Overriden because movies can only be trial level (currently)
end

opts={'T','SC','S','C','P'}; % In order lowest to highest
multiIdx=find(ismember(opts,multi)==1);
levelIdx=find(ismember(opts,level)==1);
if levelIdx==length(opts) && isempty(multiIdx)
    multiIdx=length(opts);
end
assert(~isempty(multiIdx) && ~isempty(levelIdx));
if multiIdx<levelIdx
    error('''Multi'' must be a higher or equal level than ''level''');
end

%% Specify trials
specifyTrials=plotStructPS.SpecifyTrials;
inclStruct=getInclStruct(fig,specifyTrials);

logsheetText=handles.Import.allLogsheetsUITree.SelectedNodes.Text;
logPath=getClassFilePath(logsheetText, 'Logsheet', fig);
logsheetStruct=loadJSON(logPath);
isCond=contains(multi,'C') | contains(level,'C');
computerID=getComputerID();
logsheetPath=logsheetStruct.LogsheetPath.(computerID);
[logFolder,logName]=fileparts(logsheetPath);
logsheetPathMAT=[logFolder filesep logName '.mat'];
load(logsheetPathMAT,'logVar');
allTrialNames=getTrialNames(inclStruct, logVar, fig, isCond, logsheetStruct);

if ~isCond
    subNames=fieldnames(allTrialNames);
    numConds=1;
else
    numConds=length(allTrialNames.Condition);
end

if isequal(multi,'P')
    Q=figure;
    currFig=Q;
end
if isequal(level,'P')
    plotComponents(fig,currFig,plotStructPS);
    return;
end
for condNum=1:numConds

    if isequal(multi,'C')
        Q(condNum)=figure('Name',['Condition ' num2str(condNum)]);
        currFig=Q(condNum);
    end

    if isequal(level,'C')

    end

    for subNum=1:length(subNames)

        subName=subNames{subNum};
        trialNames=fieldnames(allTrialNames.(subName));

        if isequal(multi,'S')
            Q.(subName)=figure('Name',subName);
            currFig=Q.(subName);
        elseif isequal(multi,'SC')
            Q(condNum).(subName)=figure('Name',['Condition ' num2str(condNum) ' ' subName]);
            currFig=Q(condNum).(subName);
        end

        if ismember(level,{'S','SC'})
            plotComponents(fig,currFig,plotStructPS,subName);
        end

        for trialNum=1:length(trialNames)
            trialName=trialNames{trialNum};

            % 1. Create figure
            if isequal(multi,'T')
                Q.(subName).(trialName)=figure('Name',[subName '_' trialName]);
                currFig=Q.(subName).(trialName);
            elseif isequal(multi,'SC')
                figure(Q(condNum).(subName));
                currFig=Q(condNum).(subName);
            elseif isequal(multi,'S')
                figure(Q.(subName));
                currFig=Q.(subName);
            elseif isequal(multi,'C')
                figure(Q(condNum));
                currFig=Q(condNum);
            elseif isequal(multi,'P')
                figure(Q);
                currFig=Q;
            end

            % 2. Plot the components
            plotComponents(fig,currFig,plotStructPS,subName,trialName);

        end

    end

end