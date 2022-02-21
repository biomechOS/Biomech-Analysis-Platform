function setArg(subName,trialName,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

% persistent p;

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=3:nArgs+2
    argNames{i-2}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-2})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-2) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

st=dbstack;
fcnName=st(2).name;
fig=evalin('base','gui;');
methodLetter=getappdata(fig,'methodLetter');
splitName=strsplit(fcnName,'_');
methodNum=splitName{2}(isstrprop(splitName{2},'digit'));

useGroupArgs=0; % 1 to use group args, 0 not to. This will be replaced by GUI checkbox value later.
if useGroupArgs==1
    
else
    argsFuncName=[fcnName methodLetter];
end

saveLevels=cell(length(argNames),1);

for i=1:length(argNames)
    argName=argNames{i};
    argIn=feval(argsFuncName,argName,evalin('base','projectStruct;'),subName,trialName);

    saveLevels{i}='Project';
    
    % Resolve the path names (i.e. subName & trialName)
    splitPath=strsplit(argIn,'.');
    resPath=splitPath{1}; % Initialize the resolved path name
    for j=2:length(splitPath)
        if ismember(j,[2 3]) && isequal(splitPath{j}([1 end]),'()') % Dynamic subject or trial name
            dynamicName=splitPath{j}(2:end-1);
            if any(ismember('()',dynamicName)) % There is an index in this field name
                % error? Or ok for trial names?
            else
                if j==2 && isequal(dynamicName,'subName')
                    resPath=[resPath '.' subName];
                    saveLevels{i}='Subject';
                elseif j==3 && isequal(dynamicName,'trialName')
                    resPath=[resPath '.' trialName];
                    saveLevels{i}='Trial';
                end
            end
        else
            resPath=[resPath '.' splitPath{j}];
        end
    end   
    
    resPath=[resPath '.Method' methodNum methodLetter]; % Automatically assign the method ID
    
    assignin('base','currData',varargin{i}); % Store the data to the base workspace.
    evalin('base',[resPath '=currData;']); % Store the data to the projectStruct in the base workspace.
    
end

evalin('base','clear currData;');

% Save the data to the appropriate file. Use parallel pool if desired.
p=gcp('nocreate');
if isempty(p)
    p=parpool('local',1);
end
f=parfeval(p,@saveDataToFile,0,fig,evalin('base','projectStruct;'),subName,trialName,sort(unique(saveLevels)));
% saveDataToFile(fig,evalin('base','projectStruct;'),subName,trialName,sort(unique(saveLevels)));