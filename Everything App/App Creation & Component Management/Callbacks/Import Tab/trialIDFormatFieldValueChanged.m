function []=trialIDFormatFieldValueChanged(src)

%% PURPOSE: STORE THE SUBJECT ID COLUMN HEADER IN THE LOGSHEET TO A FILE AND TO THE APP DATA

data=src.Value;
if isempty(data)
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

fig=ancestor(src,'figure','toplevel');

setappdata(fig,'trialIDFormat',data);
projectName=getappdata(fig,'projectName');
allProjectsPathTxt=getappdata(fig,'allProjectsTxtPath');

% The project name should ALWAYS be in this file at this point. If not, it's because it's the first time and they've never entered a project name before.
if exist(allProjectsPathTxt,'file')~=2
    warning('ENTER A PROJECT NAME!');
    return;
end

text=regexp(fileread(allProjectsPathTxt),'\n','split'); % Read in the file, where each line is one cell.

prefix='Trial ID Format:';
text=addProjInfoToFile(text,projectName,prefix,data);
fid=fopen(allProjectsPathTxt,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);