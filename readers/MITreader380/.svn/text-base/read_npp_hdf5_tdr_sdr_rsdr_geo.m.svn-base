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
function [DATA DATA_META TYPE] = read_npp_hdf5_tdr_sdr_rsdr_geo(filename)

DATA      = struct();
DATA_META = struct();
TYPE      = '';

if exist('filename','var') == 0
    [filename, pathname] = uigetfile({'*.H5;*.h5;','HDF5 Files (*.h5)'},'Select HDF5 File');
    if isequal(filename, 0)
        disp('User selected Cancel')
        clear filename pathname
        return
    end
    filename = [pathname filename];
end

if ~exist(filename, 'file'),
    disp('File not found');
    return
end

[~, name, ext] = fileparts(filename);
disp(['Reading: ' name ext]);
clear name ext;

%% Read the hdf5 file info
if verLessThan('matlab', '7.12.0')
    fileinfo = hdf5info(filename);

    % Return the Name of the first Data_Products Group as the TYPE
    [~, TYPE, ~] = fileparts(fileinfo.GroupHierarchy.Groups(1,2).Groups(1,1).Name);
else
    fileinfo = h5info(filename);
    
    % Return the Name of the first Data_Products Group as the TYPE
    [~, TYPE, ~] = fileparts(fileinfo.Groups(2,1).Groups(1,1).Name);
end

% Special Case - ATMS SDR and TDR
% if strcmp(TYPE, 'ATMS-SDR') == 1 || strcmp(TYPE, 'ATMS-TDR') == 1,
%     TYPE = 'ATMS-SDR-TDR';
% end

%% Loop through record types
if verLessThan('matlab', '7.12.0')
    LRT = length(fileinfo.GroupHierarchy.Groups(1,2).Groups);
else
    LRT = length(fileinfo.Groups(2,1).Groups);
end
for iRT = 1:LRT
    if verLessThan('matlab', '7.12.0')
        [~, rec_type, ~] = fileparts(fileinfo.GroupHierarchy.Groups(1,2).Groups(iRT).Name);
    else
        [~, rec_type, ~] = fileparts(fileinfo.Groups(2,1).Groups(iRT).Name);
    end
    % disp(['rec_type: ' rec_type]);
    rec_type = strrep(rec_type, '/', '_');
    rec_type = strrep(rec_type, '-', '_');
    % disp(['rec_type: ' rec_type]);
    eval(['DATA_META.' rec_type ' = struct();']);

    %% Read the Meta Data Attribute values
    if verLessThan('matlab', '7.12.0')
        attrib = fileinfo.GroupHierarchy.Groups(1,2).Groups(iRT).Datasets(1,2).Attributes;
    else
        group = fileinfo.Groups(2,1).Groups(iRT);
        dataset = group.Datasets(2,1);
        attrib = dataset.Attributes;
    end
    for iAttrib = 1:length(attrib)
        if verLessThan('matlab', '7.12.0')
            name = strrep(attrib(iAttrib).Shortname, '/', '_');
            name = strrep(name, '-', '_');
        else
            name = strrep(attrib(iAttrib).Name, '/', '_');
            name = strrep(name, '-', '_');
        end
        if verLessThan('matlab', '7.12.0')
            value = attrib(iAttrib).Value;
            L = length(value);
            if L == 1,
                if isa(attrib(iAttrib).Value, 'hdf5.h5string'),
                    eval(['DATA_META.' rec_type '.' name ' = attrib(iAttrib).Value.Data;']);
                else
                    eval(['DATA_META.' rec_type '.' name ' = hdf5read(attrib(iAttrib));']);
                end
            else
                if isa(attrib(iAttrib).Value, 'hdf5.h5string'),
                    value = hdf5read(attrib(iAttrib));
                    clear s;
                    for iVal = 1:L
                        s{iVal} = value(iVal).Data;
                    end
                    eval(['DATA_META.' rec_type '.' name ' = s;']);
                else
                    eval(['DATA_META.' rec_type '.' name ' = hdf5read(attrib(iAttrib));']);
                end
            end
        else
            attribLoc = [group.Name '/' dataset.Name];
            value = h5readatt(filename, attribLoc, attrib(iAttrib).Name);
            if iscellstr(value)
                value = deblank(value);
            end
            eval(['DATA_META.' rec_type '.' name ' = value;']);
        end
    end

    %% Read the Data values
    if verLessThan('matlab', '7.12.0')
        [~, rec_type, ~] = fileparts(fileinfo.GroupHierarchy.Groups(1,1).Groups(iRT).Name);
    else
        [~, rec_type, ~] = fileparts(fileinfo.Groups(1,1).Groups(iRT).Name);
    end
    %disp(['rec_type: ' rec_type]);
    rec_type = strrep(rec_type, '/', '_');
    rec_type = strrep(rec_type, '-', '_');
    rec_type = rec_type(1:end - 4);
    eval(['DATA.' rec_type ' = struct();']);
    
    if verLessThan('matlab', '7.12.0')
        datasets = fileinfo.GroupHierarchy.Groups(1,1).Groups(iRT).Datasets;
    else
        datasets = fileinfo.Groups(1,1).Groups(iRT).Datasets;
    end
    
    for iDS = 1:length(datasets)
        [~, name, ~] = fileparts(datasets(iDS).Name);
        % Skip RDR Raw Application Packets (ccsds)
        if length(name) > 22,
            if strcmp(name(1:22), 'RawApplicationPackets_'),
                continue
            end
        end
        name = strrep(name, '/', '_');
        name = strrep(name, '-', '_');
        if verLessThan('matlab', '7.12.0')
            value = hdf5read(datasets(iDS));
        else
            dataLoc = fileinfo.Groups(1,1).Groups(iRT).Name;
            value = h5read(filename, [dataLoc '/' datasets(iDS).Name]);
        end
        eval(['DATA.' rec_type '.' name ' = value;']);
    end

    %% Apply Factors
    if verLessThan('matlab', '7.12.0')
        group = fileinfo.GroupHierarchy.Groups(1,1).Groups(iRT);
    else
        group = fileinfo.Groups(1,1).Groups(iRT);
    end
    if strcmp(group.Name, '/All_Data/ATMS-TDR_All') == 1,
        DATA.ATMS_TDR.AntennaTemperatureKelvin = (double(DATA.ATMS_TDR.AntennaTemperature)...
             * DATA.ATMS_TDR.AntennaTemperatureFactors(1)) + DATA.ATMS_TDR.AntennaTemperatureFactors(2);
    elseif strcmp(group.Name, '/All_Data/ATMS-SDR_All') == 1,
        DATA.ATMS_SDR.BrightnessTemperatureKelvin = (double(DATA.ATMS_SDR.BrightnessTemperature)...
             * DATA.ATMS_SDR.BrightnessTemperatureFactors(1)) + DATA.ATMS_SDR.BrightnessTemperatureFactors(2);
    elseif strcmp(group.Name, '/All_Data/ATMS-REMAP-SDR_All') == 1,
        DATA.ATMS_REMAP_SDR.BrightnessTemperatureKelvin = (double(DATA.ATMS_REMAP_SDR.BrightnessTemperature)...
             * DATA.ATMS_REMAP_SDR.BrightnessTemperatureFactors(1)) + DATA.ATMS_REMAP_SDR.BrightnessTemperatureFactors(2);         
    end
    
    eval(['DATA.' rec_type ' = orderfields(DATA.' rec_type ');']);
end

%% Put the fields in alpha order
DATA = orderfields(DATA);
DATA_META = orderfields(DATA_META);

