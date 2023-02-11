function [struct]=createComponentStruct(name,id)

%% PURPOSE: CREATE A NEW COMPONENT STRUCT

struct.Name=name;

struct.Class='Component';

struct.MFileName=struct.Name;

if nargin==1
    id=createID('Component');
end
struct.ID=id;

currDate=datetime('now');
struct.DateCreated=currDate;
struct.DateModified=currDate;

user='MT'; % Stand-in for username
struct.CreatedBy=user;

user2=user; % Stand-in for username
struct.LastModifiedBy=user2;

struct.Description='';

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

struct.Project={Current_Project_Name};

struct.InputVariablesNamesInCode={};

struct.ModifiedDefaultProperties={}; % List of property names to have the defaults modified for
struct.ModifiedPropertyValues={}; % The new default values of those properties

struct.Archived=false; % If true, this will not show up in the uitree unless it is un-archived.

struct.OutOfDate=true;

struct.Checked=true;

struct.Visible=true;

struct.Text=[name '_' id];
struct.Parent=''; % The folder that this node is located within. If empty, then it is root level.

saveClass('Component',struct);

%% Assign the newly created plot component struct to the current project struct.
assignToProject(struct);