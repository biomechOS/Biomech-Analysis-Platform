function [newObjs, objsToRename] = newObjVersions(uuid,anList)

%% PURPOSE: CREATE NEW OBJECT VERSIONS FOR NEW ANALYSES. UPDATE THEM IN THE OBJECT TABLES AND JOIN TABLES.

global conn;

Current_Analysis = getCurrent('Current_Analysis');
O = getAllObjLinks(); % Don't need to rename views, but I do need to rename InclNodes in the views.

% Get all of the objects in all shared analysis.
H = transclosure(flipedge(O));
R = full(adjacency(H));
allANIdx = ismember(O.Nodes.Name,anList);
objsInAllAn = O.Nodes.Name(any(logical(R(allANIdx,:))),1); % All objects in all shared analyses.

% Get all objects in the current analysis.
currANIdx = ismember(O.Nodes.Name,Current_Analysis);
objsInCurrAn = O.Nodes.Name(logical(R(currANIdx,:))); % All objects in the current analysis only.
currANObjsInMultAN = objsInCurrAn(ismember(objsInCurrAn, objsInAllAn)); % Objects in this analysis that are also in other analyses.

% Get all of the objects dependent on this object.
H2 = transclosure(O);
R2 = full(adjacency(H2));
depIdx = ismember(O.Nodes.Name,uuid);
allDepObjs = O.Nodes.Name(logical(R2(depIdx,:)));

% Get all of the objects dependent on this PR in this analysis that are also in other analyses.
% Removes AN objects, which is correct!
objsToRename = allDepObjs(ismember(allDepObjs,currANObjsInMultAN));

if isempty(objsToRename)
    objsToRename = {};
    newObjs = {};
    return;
end

%% 1. Copy the objects in their object tables to new rows with new
% UUID's (same abstract ID's).
newObjs = cell(size(objsToRename));
[types,abstractIDs] = deText(objsToRename);
types = unique(types,'stable');
for i=1:length(types)
    tablename = getTableName(types{i}, true);
    currTypeIdx = contains(objsToRename, types{i});
    currTypeObjs = objsToRename(currTypeIdx);     
    uuidStr = getCondStr(currTypeObjs);
    sqlquery = ['SELECT * FROM ' tablename ' WHERE UUID IN ' uuidStr ';'];
    t = fetch(conn, sqlquery);
    allStruct = table2MyStruct(t,'struct');
    [~,order] = sort(currTypeObjs);
    allStruct(order) = allStruct; % Reorder struct fields to match currTypeObjs

    % Create new UUID's with same abstract ID.    
    sqlquery = ['SELECT UUID FROM ' tablename];
    uuids = fetch(conn, sqlquery);
    uuids = table2MyStruct(uuids);
    uuids = uuids.UUID;

    currTypeAbstractIDs = abstractIDs(currTypeIdx);
    currTypeIdxNums = find(currTypeIdx);
    for j=1:length(currTypeIdxNums)
        instanceID = createID_Instance(currTypeAbstractIDs{j}, types{i}, uuids);
        newObjs{currTypeIdxNums(j)} = genUUID(types{i}, currTypeAbstractIDs{j}, instanceID);
        uuids = [uuids; newObjs(currTypeIdxNums(j))];
        % Replace the UUID. In the future should also change date created/modified & who it was created by, but not worried about that right now.
        allStruct(j).UUID = newObjs{currTypeIdxNums(j)};
    end    
        
    % Save the objects
    sqlquery = struct2SQL(tablename, allStruct, 'INSERT');
    execute(conn, sqlquery);

end

%% 2. Copy the links in the join tables, changing UUID's
tablenames = sqlfind(conn, '');
idx = contains(tablenames.Table,types);
tablenames(~idx,:) = [];
for i=1:length(tablenames.Table)
    tablename = char(tablenames.Table(i));
    tmpName = strsplit(tablename,'_');
    type1 = tmpName{1};
    type2 = tmpName{2};
    col1 = [type1 '_ID'];
    col2 = [type2 '_ID'];    

    if isequal(col1,col2)
        col1 = ['Parent_' col1];
        col2 = ['Child_' col2];
    end

    % Change names of both columns
    if any(contains(types,type1)) && any(contains(types,type2))

        currTypeObjsIdx1 = contains(objsToRename,type1);
        currTypeObjsIdx2 = contains(objsToRename,type2);
        currTypeObjs1 = objsToRename(currTypeObjsIdx1);
        currTypeObjs2 = objsToRename(currTypeObjsIdx2);
        currObjsStr1 = getCondStr(currTypeObjs1);
        currObjsStr2 = getCondStr(currTypeObjs2);     

        if isempty(currTypeObjs1) && isempty(currTypeObjs2)
            continue;
        end

        % The 'OR' is important when looking at PR, maybe don't change their
        % input VR's. For all other tables/types, 'OR' may as well be
        % 'AND', because changing the contained object also changes the container.
        sqlquery = ['SELECT * FROM ' tablename ' WHERE ' col1 ' IN ' currObjsStr1 ' OR ' col2 ' IN ' currObjsStr2];
        t = fetch(conn, sqlquery);
        if isempty(t)
            continue;
        end
        allStruct = table2MyStruct(t,'struct');

        % Rename the links
        currTypeIdxNums1 = find(currTypeObjsIdx1);
        currTypeIdxNums2 = find(currTypeObjsIdx2);
        [~,order1] = sort(currTypeObjs1);
        allStruct(order1) = allStruct(currTypeObjsIdx1);
        for j=1:length(currTypeIdxNums1)
            allStruct(currTypeIdxNums1(j)).(col1) = newObjs{currTypeIdxNums1(j)}; % Change the UUID to the new UUID.
        end
        [~,order2] = sort(currTypeObjs2);
        allStruct(order2) = allStruct(currTypeObjsIdx2);
        for j=1:length(currTypeIdxNums2)
            allStruct(currTypeIdxNums2(j)).(col2) = newObjs{currTypeIdxNums2(j)}; % Change the UUID to the new UUID.
        end

    else % Change names of entries in just one column, e.g. AN_PG or AN_PR

        if any(contains(types,type1))
            col = col1;
            type = type1;
        elseif any(contains(types,type2))
            col = col2;
            type = type2;
        end
        currTypeObjsIdx = contains(objsToRename,type);
        currTypeObjs = objsToRename(currTypeObjsIdx);

        if isempty(currTypeObjs)
            continue;
        end

        % Get the existing links.
        currObjsStr = getCondStr(currTypeObjs);
        sqlquery = ['SELECT * FROM ' tablename ' WHERE ' col ' IN ' currObjsStr];
        t = fetch(conn, sqlquery);
        if isempty(t)
            continue;
        end
        allStruct = table2MyStruct(t,'struct');
        currANIdx = ismember({allStruct.AN_ID},Current_Analysis);
        allStruct(~currANIdx) = [];

        % Rename the links.
        [~,order] = sort(currTypeObjs);
        allStruct(order) = allStruct;
        currTypeIdxNums = find(currTypeObjsIdx);
        for j=1:length(allStruct)
            allStruct(j).(col) = newObjs{currTypeIdxNums(j)}; % Change the UUID to the new UUID.
        end

        % Delete the links
        sqlquery = ['DELETE FROM ' tablename ' WHERE AN_ID = ''' Current_Analysis ''' AND ' col ' IN ' currObjsStr ';'];
        execute(conn, sqlquery);        

    end           

    % Save the links
    sqlquery = struct2SQL(tablename, allStruct, 'INSERT');
    execute(conn, sqlquery);

end