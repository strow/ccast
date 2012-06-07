%
%        (c) Copyright 2004 Massachusetts Institute of Technology
%
%        In no event shall M.I.T. be liable to any party for direct, 
%        indirect, special, incidental, or consequential damages arising
%        out of the use of this software and its documentation, even if
%        M.I.T. has been advised of the possibility of such damage.
%          
%        M.I.T. specifically disclaims any warranties including, but not
%        limited to, the implied warranties of merchantability, fitness
%        for a particular purpose, and non-infringement.
%
%        The software is provided on an "as is" basis and M.I.T. has no
%        obligation to provide maintenance, support, updates, enhancements,
%        or modifications.

% Preexisting filenames cell array
if exist('filenames','var') == 1,
    if iscell(filenames),
        inputFileNames = filenames;
    end
end

% Get files from user dialog
if exist('inputFileNames','var') ~= 1,
    [inputFileNames, inputPath] = uigetfile('*.h5', ...
      'Select RDR HDF5 Input File', 'MultiSelect', 'on');
end
if exist('inputPath','var') ~= 1,
    if exist('pathname','var') == 1,
        inputPath = pathname;
    else
        inputPath = '';
    end
end

% Validate input file selection
if ~iscell(inputFileNames)
    if inputFileNames == 0
        return;
    end
    inputFileName = inputFileNames;
    inputFileNames = cell(1);
    inputFileNames{1} = inputFileName;
else
    inputFileNames = sort(inputFileNames);
end

outputPath = tempdir;
outputFileName = tempname;
outputFileAndPath = outputFileName;

% open and clear the output file
fid = fopen(outputFileName, 'w', 'b');
if fid == -1
    return;
else
    fclose(fid);
end

% Loop through inputFileNames
for iFile = 1:size(inputFileNames, 2)
    h5FileName = [inputPath inputFileNames{iFile}];
    % Extract the Raw Application Packets from the hdf5 file
    outputFileName = extract_hdf5_rdr(h5FileName, outputFileName);
    if isempty(outputFileName),
        return
    end
end

disp('Conversion from hdf5 to ccsds binary finished.');

filename = outputFileName;
pathname = '';

clear fid;

% Bypass trim code in ccsds reader
no_trim = 1;
if exist('VERBOSE','var') ~= 1
    VERBOSE = 0;
end

read_atms_ccsds_data_packets;
[hdf5_data meta_data filetype] = read_npp_hdf5_tdr_sdr_rsdr_geo(h5FileName);

% Clean up variables and temp files
delete(outputFileName);
clear inputFileName inputFileNames inputPath iFile
clear outputPath outputFileName outputFileAndPath
clear filename pathname
clear h5group h5GroupData
clear apStorageStart apStorageEnd
clear no_trim
% end of file