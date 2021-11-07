function []=openImportSettingsButtonPushed(src, projectName)

%% PURPOSE: ON IMPORT TAB, IF OPEN IMPORT SETTINGS BUTTON PUSHED, OPEN THE IMPORT SETTINGS FILE FOR THE PROJECT.

fig=ancestor(src,'figure','toplevel');
codePath=getappdata(fig,'codePath');
if isempty(codePath)
    warning('Need to enter the code path!');
    return;
end
if exist(codePath,'dir')~=7
    warning(['Fix the code path: ' codePath]);
    return;
end

% Check if Mac or PC
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

importPath=[codePath projectName '_Import' slash];

if ~isfolder(importPath)
    mkdir(importPath);
end

importSettingsName=['importSettings_' projectName '.m'];

if isequal(fig.Children.Children(1,1).Children(8,1).Text(1:6),'Create') % Creating the project's importSetting file for the first time. Also open it.    
    copyfile('importSettingsTemplate.m',[importPath importSettingsName]); % Copy the project-independent template to the new location. Makes the Import folder if it doesn't already exist.
    A=regexp(fileread([importPath importSettingsName]),'\n','split'); % Open the newly created importSettings file.
    A{1}=['function [ProjHelper,dataTypes,segment]=' importSettingsName(1:end-2) '(subjectListInStruct,markerName)'];
    fid=fopen([importPath importSettingsName],'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);    
    fig.Children.Children(1,1).Children(8,1).Text=['Open importSettings ' projectName '.m'];
end

edit([importPath importSettingsName]); % Always open the file.