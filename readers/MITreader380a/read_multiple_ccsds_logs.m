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

% Select the log files
[filenames, pathname] = uigetfile({'*.LOG;*.log;*.pkt;*.PKT', 'CCSDS Files (*.log,*.pkt)'}, 'Select CCSDS Files', 'MultiSelect', 'on');
if ~iscell(filenames)
    if isequal(filenames, 0)
        disp('User selected Cancel');
        clear filename pathname;
        return;
    end
end

% User only selected one file
if ~iscell(filenames)
    filename = filenames;
    filenames = cell(1);
    filenames{1} = filename;
    clear filename;
else
    filenames = sort(filenames);
end

% The types of packets to join
packet_type{1} = 'cal_data';
packet_type{2} = 'cte';
packet_type{3} = 'engineering_h_and_s';
packet_type{4} = 'hotcal';
packet_type{5} = 'housekeeping';
packet_type{6} = 'LEOandA';
packet_type{7} = 'science_data';
packet_type{8} = 'science_data_orig';
packet_type{9} = 'science_data_irreg';
packet_type{10} = 'thm';

% First log file
first_log = 1;

% Loop through the log files
for iFile = 1:size(filenames, 2)
    % Construct the log filename
    filename = filenames{iFile};
    
    if ~isempty(dir([pathname filename]))
        % Control output from read_atms_ccsds_data_packets
        VERBOSE = 0;
        
        disp(['Reading: ' filename]);
        
        % Read [pathname filename] ccsds packets
        read_atms_ccsds_data_packets;

        % Save each log files packets to ccsds variable
        for iType = 1:length(packet_type)
            if first_log
                eval(['ccsds.' packet_type{iType} '=' packet_type{iType} ';']);
            else
                eval(['names = fieldnames(' packet_type{iType} ');']);
                for i = 1:length(names)
                    name = names{i};
                    eval(['field = ' packet_type{iType} '.' name ';']);
                    L = length(size(field));
                    if isscalar(field)
                        L = 1;
                    end
                    % Join the new packets to the ccsds structure
                    switch L
                        case 1
                            eval(['ccsds.' packet_type{iType} '.' name ' = ccsds.' packet_type{iType} '.' name ' + ' packet_type{iType} '.' name ';']);
                        case 2
                            eval(['ccsds.' packet_type{iType} '.' name ' = [ccsds.' packet_type{iType} '.' name ' ' packet_type{iType} '.' name '];']);
                        case 3
                            eval(['A = ccsds.' packet_type{iType} '.' name ';']);
                            eval(['B = ' packet_type{iType} '.' name ';']);
                            SA = size(A, 3);
                            SB = size(B, 3);
                            A = reshape(A, 22, 104 * SA);
                            B = reshape(B, 22, 104 * SB);
                            C = [A B];
                            SC = size(C, 2);
                            C = reshape(C, 22, 104, SC/104);
                            eval(['ccsds.' packet_type{iType} '.' name ' = C;']);
                    end
                end
            end
        end
        % No longer the first log file
        first_log = 0;
    end
end

% Pull values out of ccsds so they can be processed by other scripts
for iType = 1:length(packet_type)
    eval(['clear ' packet_type{iType}]);
    eval([packet_type{iType} '= ccsds.' packet_type{iType} ';']);
end
    
% Remove unneeded variables
clear iFile %filenames pathname filename
clear iType packet_type names name A B C SA SB SC
clear first_log field L i
%clear ccsds