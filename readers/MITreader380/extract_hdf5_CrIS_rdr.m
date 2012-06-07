% function [saveFilename] = extract_hdf5_rdr(h5Filename, saveFilename)
%
% This function extracts the Raw Application Packets from an HDF5 file,
% and appends them to a file. That file may then be read using a CCSDS
% packet reader.
%
% It has two arguments:
% h5Filename = the name of the hdf5 file, with path if not in the current
% directory.
% saveFilename (optional) = the name of the file to which the Raw
% Application Packets will be appended.  If not provided, a temp file will
% be created.
%
% Returns:
% It returns the name of the file to which the Raw Application Packets have
% been appended - either the provided saveFilename or the temp file.
%
% File Endianess:
% Regardless of operating system, the file is saved Big Endian.  This is
% because the Raw Application Packets are stored within the HDF5 file Big 
% Endian.  The CCSDS packet reader will have to be set accordingly.
%
% The function will extract ALL Raw Application Packets within the hdf5
% file's /All_Data Group and append them into one file.
%
% If you have multiple hdf5 files, you may call this function multiple
% times with the same saveFilename argument to combine them a single file
% for later processing.
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


function [saveFilename] = extract_hdf5_CrIS_rdr(h5Filename, saveFilename)

global VERBOSE

% Set the Save filename
if ~exist('saveFilename','var') || isempty(saveFilename),
    saveFilename = tempname;
end

% h5Filename valid
if ~exist('h5Filename','var') || ~exist(h5Filename,'file')
    disp(['Unable to open h5Filename: ' h5Filename]);
    saveFilename = '';
    return;
end

% open output file (Big Endian)
fid = fopen(saveFilename, 'a','b');
if fid == -1
    disp(['Unable to open the save file: ' saveFilename]);
    saveFilename = '';
    return;
end

% Read the hdf5 file info
fileinfo = hdf5info(h5Filename);

groups = fileinfo.GroupHierarchy.Groups(1).Groups;
for iGroup = 1:length(groups)
    datasets = groups(iGroup).Datasets;
    counter = 0;
    for iDS = 1:length(datasets)
        [~, name, ~] = fileparts(datasets(iDS).Name);
        % Extract RDR Raw Application Packets (ccsds)
        if length(name) > 22,
            if strcmp(name(1:22), 'RawApplicationPackets_'),
                % Inspired by Raytheon QCV Tool
                try

                    h5GroupData = hdf5read(h5Filename, name);
                    if ~isempty(h5GroupData),
                        apStorageStart = bitshift(uint32(h5GroupData(49)), 24)...
                                       + bitshift(uint32(h5GroupData(50)), 16)...
                                       + bitshift(uint32(h5GroupData(51)), 8)...
                                                + uint32(h5GroupData(52))...
                                                + 1;
                        apStorageEnd = bitshift(uint32(h5GroupData(53)), 24)...
                                     + bitshift(uint32(h5GroupData(54)), 16)...
                                     + bitshift(uint32(h5GroupData(55)), 8)...
                                              + uint32(h5GroupData(56))...
                                              + apStorageStart...
                                              - 1;

                        % apStorageStart
                        % apStorageEnd

                        % Write the AP Storage to the output file
                        
                        if counter==1
                            fwrite(fid, h5GroupData(apStorageStart:apStorageEnd));
                            name = [groups(iGroup).Name '/' 'RawApplicationPackets_' int2str(counter)];
                                if VERBOSE,
                                    disp(name);
                                end
                        end
                        
                        
                        disp([name ': OK']);
                    end
                    counter = counter + 1;
                catch ME
                    disp('Error extracting RawApplicationPackets');
                    disp(name);
                    fclose(fid);
                    delete(saveFilename);
                    saveFilename = '';
                    return;
                end
            end
        end
    end
end

% Close saveFilename
fclose(fid);

if VERBOSE,
    disp 'RawAppliationPackets extraction completed.';
end

end