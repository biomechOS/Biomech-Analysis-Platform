function []=fillUITree_PS(fig, class, uiTree)

%% PUEPOSE: FILL IN THE CLASS UI TREE WITH PROJECT-SPECIFIC NODES, WITH PARENT NODES THAT ARE PROJECT-INDEPENDENT

handles=getappdata(fig,'handles');

slash=filesep;

if isempty(uiTree.Children)
    return;
end

texts={uiTree.Children.Text}; % The existing nodes' texts

projectPath=getProjectPath(fig); % The current project path

% The project-specific class instances for this project.
filenames=getClassFilenames(fig,class,[projectPath slash 'Project_Settings']);
psTexts=fileNames2Texts(filenames); % Convert those PS file name instances to texts

piTexts=getPITextFromPS(psTexts); % Identify which PI class instances the PS instances derive from.

for i=1:length(texts)    
    idx=contains(piTexts,texts{i}); % Get the PI text for the current node

    if ~any(idx)
        continue; % There are no project-specific texts for this node.
    end

    currNames=psTexts(idx);

    node=uiTree.Children(i);

    existChildren={};
    if ~isempty(node.Children)
        existChildren={node.Children.Text};           
    end

    for j=1:length(currNames)    
        if ismember(currNames{j},existChildren)
            continue; % Child already exists, don't create a new node.
        end

        newNode=uitreenode(node,'Text',currNames{j});

        newNode.ContextMenu=handles.Process.psContextMenu;
    end

end