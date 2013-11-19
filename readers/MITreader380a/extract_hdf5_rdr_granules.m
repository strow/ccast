%
%      (c) Copyright 2004 Massachusetts Institute of Technology
%
%      In no event shall M.I.T. be liable to any party for direct, 
%      indirect, special, incidental, or consequential damages arising
%      out of the use of this software and its documentation, even if
%      M.I.T. has been advised of the possibility of such damage.
%          
%      M.I.T. specifically disclaims any warranties including, but not
%      limited to, the implied warranties of merchantability, fitness
%      for a particular purpose, and non-infringement.
%
%      The software is provided on an "as is" basis and M.I.T. has no
%      obligation to provide maintenance, support, updates, enhancements,
%      or modifications.

function [saveFilename] = extract_hdf5_rdr_granules(h5Filename, saveFilename)

global VERBOSE
if ~exist('VERBOSE','var') || isempty(VERBOSE)
    VERBOSE = 0;
end

% Variables
GRANULES = struct();
inputPath = '';

if ~exist('saveFilename','var') || isempty(saveFilename)
    saveFilename = tempname;
end

if verLessThan('matlab', '7.12.0')
    saveFilename = '';
    disp('Matlab version R2011a or better required.');
    return
end

% Convert h5Filename to cell
if exist('h5Filename','var') && ~isempty(h5Filename)
    if iscell(h5Filename)
        inputFiles = sort(h5Filename);
    else
        inputFiles = cell(1);
        inputFiles{1} = h5Filename;
    end
end

% Get files from user dialog
if ~exist('inputFiles','var')
    [inputFiles, inputPath] = uigetfile({'*.H5;*.h5;','HDF5 Files (*.h5)'}, ...
      'Select RDR HDF5 Input File', 'MultiSelect', 'on');
  
    % Validate input file selection
    if ~iscell(inputFiles)
        if inputFiles == 0
            return
        end
        inputFileName = inputFiles;
        inputFiles = cell(1);
        inputFiles{1} = inputFileName;
    else
        inputFiles = sort(inputFiles);
    end
end

% open output file (Big Endian) for appending
fid = fopen(saveFilename,'a','b');
if fid == -1
    disp(['Unable to open the save file: ' saveFilename]);
    saveFilename = '';
    return;
end

% Put the files in order prior to reading
inputFiles = sort(inputFiles);

% Process each hdf5 file
for iFile = 1:length(inputFiles)
    h5File = [inputPath inputFiles{iFile}];
    
    if ~exist(h5File,'file')
        disp(['WARNING: Unable to open file: ' h5File]);
        continue
    end
    
    %if VERBOSE
        disp(['Reading: ' inputFiles{iFile}]);
    %end

    try
        fileinfo = h5info(h5File);
    catch ME
        disp(['ERROR reading file: ' h5File]);
        continue
    end
    
    % Loop through each Data_Products Group
    for iGroup = 1:length(fileinfo.Groups(2).Groups)
        group = fileinfo.Groups(2).Groups(iGroup);
        [~, groupName, ~] = fileparts(group.Name);
        
        % Loop through each Group's Datasets
        for iD = 1:length(group.Datasets)
            DS = group.Datasets(iD);
            
            g = strfind(DS.Name,'_Gran_');
            if isempty(g)
                continue
            end
            
            save_granule = 1;
            GranNum = DS.Name(g+6:end);
            location = [group.Name '/' DS.Name];
            Creation_Date = h5readatt(h5File, location, 'N_Creation_Date');
            Creation_Time = h5readatt(h5File, location, 'N_Creation_Time');
            Granule_ID    = h5readatt(h5File, location, 'N_Granule_ID');
            Creation_Date = strtrim(Creation_Date{1});
            Creation_Time = strtrim(Creation_Time{1});
            Granule_ID    = strtrim(Granule_ID{1});
            
            % Strip off trailing "Z"
            Creation_Time = Creation_Time(1:end-1);
            
            % Check if a matching Granule_ID already exists
            if isfield(GRANULES, Granule_ID)
                % Existing Creation Date newer than this Granule's?
                if str2double(GRANULES.(Granule_ID).Creation_Date) > str2double(Creation_Date)
                    save_granule = 0;
                elseif str2double(GRANULES.(Granule_ID).Creation_Date) == str2double(Creation_Date)
                    % Dates are the same; compare Create_Time values
                    if str2double(GRANULES.(Granule_ID).Creation_Time) > str2double(Creation_Time)
                        save_granule = 0;
                    end
                end
            end
            
            % Save or Overwrite the Granule
            if save_granule
                % Build the Raw Application Packets Dataset's name
                RAPName = ['/All_Data/' groupName '_All/RawApplicationPackets_' num2str(GranNum)];
                
                % Read the Dataset's contents
                try
                    RAPData = h5read(h5File, RAPName);
                catch ME
                    disp([RAPName ': ERROR (reading)']);
                    continue
                end
                
                if ~isempty(RAPData),
                    try
                    apStorageStart = bitshift(uint32(RAPData(49)), 24)...
                                   + bitshift(uint32(RAPData(50)), 16)...
                                   + bitshift(uint32(RAPData(51)), 8)...
                                            + uint32(RAPData(52))...
                                            + 1;
                    apStorageEnd = bitshift(uint32(RAPData(53)), 24)...
                                 + bitshift(uint32(RAPData(54)), 16)...
                                 + bitshift(uint32(RAPData(55)), 8)...
                                          + uint32(RAPData(56))...
                                          + apStorageStart...
                                          - 1;
                    catch ME
                        disp([RAPName ': ERROR (invalid)']);
                        continue
                    end
                    
                    % Store the RAPData
                    GRANULES.(Granule_ID) = struct();
                    GRANULES.(Granule_ID).Name = DS.Name;
                    GRANULES.(Granule_ID).Creation_Date = Creation_Date;
                    GRANULES.(Granule_ID).Creation_Time = Creation_Time;
                    
                    % Write the AP Storage to the GRANULES Structure
                    GRANULES.(Granule_ID).RAPData = RAPData(apStorageStart:apStorageEnd);
                    if VERBOSE
                        disp([RAPName ': OK']);
                    end
                end
            end
        end
    end
    
    % After each file, limit the number of Granules in memory
    Granule_IDS = sort(fieldnames(GRANULES));
    if VERBOSE
        disp(['Number of Granules in memory: ' num2str(length(Granule_IDS))]);
    end
    while length(Granule_IDS) > 2500
        if VERBOSE
            disp(['Saving 100 Granules to: ' saveFilename]);
        end
        for i = 1:100
            fwrite(fid, GRANULES.(Granule_IDS{i}).RAPData);
            GRANULES = rmfield(GRANULES, Granule_IDS{i});
        end
        Granule_IDS = sort(fieldnames(GRANULES));
    end
end

% Put the Granules in order
GRANULES = orderfields(GRANULES);
Granule_IDS = fieldnames(GRANULES);

% Write the Raw Application Packets Data to saveFile
if VERBOSE
    disp(['Saving RAPData to: ' saveFilename]);
end
for iG = 1:length(Granule_IDS)
    Granule_ID = Granule_IDS{iG};
    fwrite(fid, GRANULES.(Granule_ID).RAPData);
end

% Returns saveFilename
fclose(fid);
end