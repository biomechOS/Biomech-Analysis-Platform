function []=runLogsheetButtonPushed(src,event)

%% PURPOSE: RUN THE LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

fullPath=getClassFilePath(selNode);
struct=loadJSON(fullPath);

numHeaderRows=struct.NumHeaderRows;
subjIDColHeader=struct.SubjectCodenameHeader;
targetTrialIDColHeader=struct.TargetTrialIDHeader;

computerID=getComputerID();

path=struct.LogsheetPath.(computerID);

[folder,file,ext]=fileparts(path);

pathMAT=[folder slash file '.mat'];

checkedIdx=ismember(handles.Import.headersUITree.Children,handles.Import.headersUITree.CheckedNodes);

if ~any(checkedIdx)
    disp('No variables selected!');
    return;
end

load(pathMAT,'logVar');

headers=struct.Headers;
levels=struct.Level;
type=struct.Type;

trialIdx=ismember(levels,'Trial') & checkedIdx; % The trial level variables idx that were checked.
subjectIdx=ismember(levels,'Subject') & checkedIdx; % The subject level variables idx that were checked.

useHeaderDataTypes=cell(sum(checkedIdx),1);
useHeaderTrialSubject=cell(sum(checkedIdx),1);

useHeaderNames=headers(checkedIdx);

subjIDCol=ismember(headers,subjIDColHeader);
targetTrialIDCol=ismember(headers,targetTrialIDColHeader);

specTrialsName=struct.SpecifyTrials;
if isempty(specTrialsName)
    beep;
    disp('Need to select specify trials for the logsheet import!');
    return;
end

fullPath=getClassFilePath(projectNode);
projectStruct=loadJSON(fullPath);
projectPath=projectStruct.ProjectPath;

oldPath=cd([projectPath slash 'SpecifyTrials']);
inclStruct=feval(specTrialsName);
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
rowsIdx=false(size(logVar,1),1);
subNames=fieldnames(allTrialNames);
%% Apply specify trials
for i=1:length(subNames)    
    subName=subNames{i};
    trialNames=allTrialNames.(subName);
    trialNames=fieldnames(trialNames);
    rowsIdxCurrent=ismember(logVar(:,subjIDCol),subName) & ismember(logVar(:,targetTrialIDCol),trialNames);
    rowsIdx(rowsIdxCurrent)=true;

end
cd(oldPath);

% Get the row numbers from the specify trials selected
rowNums=find(rowsIdx==1);
rowNums=rowNums(rowNums>=numHeaderRows+1); % Specify trials has already been applied

%% Remove rep numbers that are not desired (from desired trials)
rowNumsReps=[];
count=0;
for i=1:length(rowNums) % Iterate over each row to decide at the repetition level if it should be included.
    subName=logVar{rowNums(i),subjIDCol};
    trialName=logVar{rowNums(i),targetTrialIDCol};
    if i==1
        repNum=1;
        if allTrialNames.(subName).(trialName)==1
            trialNamePrev=trialName;
            count=count+1;
            rowNumsReps(count)=rowNums(i);
            continue;
        end
    end

    if isequal(trialNamePrev,trialName)
        repNum=repNum+1;
    else
        repNum=1;
    end

    if allTrialNames.(subName).(trialName)==repNum
        count=count+1;
        rowNumsReps(count,1)=rowNums(i);
    end

    trialNamePrev=trialName;

end

dataPath=projectStruct.DataPath;

%% Trial level data
trialIdxNums=find(trialIdx==1);
if any(trialIdx) % There is at least one trial level variable
    for rowNumIdx=1:length(rowNumsReps)
        rowNum=rowNumsReps(rowNumIdx);

        rowDataTrial=logVar(rowNum,trialIdxNums);
        subName=logVar{rowNum,subjIDCol};
        trialName=logVar{rowNum,targetTrialIDCol};        

        % Handle trial level data
        for varNum=1:length(rowDataTrial)

            var=rowDataTrial{varNum};

            if isa(var,'cell')
                var=var{1};
            end

            switch useHeaderDataTypesTrial{varNum}
                case 'char'
                    if isa(var,'double')
                        if isnan(var)
                            var='';
                        else
                            var=num2str(var);
                        end
                    end
                case 'double'
                    if isa(var,'char')
                        var=str2double(var);
                    end
            end

            assert(isa(var,useHeaderDataTypesTrial{varNum}));

%             rowDataTrialStruct.([useHeaderVarNamesTrial{varNum} '_' splitCode])=var;

        end        

        folderName=[dataPath 'MAT Data Files' slash subName slash];

        % Save trial level data
        if exist(folderName,'dir')~=7
            mkdir(folderName);
        end

        fileName=[folderName trialName '_' subName '_' projectName '.mat'];

        if exist(fileName,'file')~=2
            save(fileName,'-struct','rowDataTrialStruct','-v6','-mat');
        else
            save(fileName,'-struct','rowDataTrialStruct','-append');
        end

    end
end

%% Subject level data
% Need to incorporate specifyTrials here too

subNamesAll=logVar(numHeaderRows+1:end,subjIDCol);
subNames=unique(subNamesAll); % The complete list of subject names

rowNums=cell(length(subNames),1);
for i=1:length(subNames)

    subName=subNames{i};

    rowNums{i}=[zeros(numHeaderRows,1); ismember(subNamesAll,subName)];

end

subjectIdxNums=find(subjectIdx==1);
if any(subjectIdx)
    for subNum=1:length(subNames)
        currSubRows=logical(rowNums{subNum});

        subName=subNames{subNum};

        folderName=[dataPath 'MAT Data Files' slash subName slash];

        for varNum=1:length(subjectIdxNums)

            varAll=logVar(currSubRows,subjectIdxNums(varNum));

            count=0;
            for i=1:length(varAll)

                if any(isnan(varAll{i})) || isempty(varAll{i})
                    continue;
                end

                count=count+1;
                if count==1
                    var=varAll{i};
                else
                    if ~isequal(var,varAll{i})
                        disp(['Non-unique entries in logsheet for subject ' subName ' variable ' headerNames{useHeadersIdxNumsSubject(varNum)}]);
                        return;
                    end
                end

            end

            if isa(var,'cell')
                var=var{1};
            end

            switch useHeaderDataTypesSubject{varNum}
                case 'char'
                    if isa(var,'double')
                        if isnan(var)
                            var='';
                        else
                            var=num2str(var);
                        end
                    end
                case 'double'
                    if isa(var,'char')
                        var=str2double(var);
                    end
            end

            assert(isa(var,useHeaderDataTypesSubject{varNum}));            

            rowDataSubjectStruct.([useHeaderVarNamesSubject{varNum} '_' splitCode])=var;

        end

        % Save subject level data
        if exist(folderName,'dir')~=7
            mkdir(folderName);
        end

        fileName=[folderName subName '_' projectName '.mat'];               

        if exist(fileName,'file')~=2
            save(fileName,'-struct','rowDataSubjectStruct','-v6','-mat');
        else
            save(fileName,'-struct','rowDataSubjectStruct','-append');
        end

    end
end