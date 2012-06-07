%          (c) Copyright 2004 Massachusetts Institute of Technology
%
%          In no event shall M.I.T. be liable to any party for direct, 
%          indirect, special, incidental, or consequential damages arising
%          out of the use of this software and its documentation, even if
%          M.I.T. has been advised of the possibility of such damage.
%          
%          M.I.T. specifically disclaims any warranties including, but not
%          limited to, the implied warranties of merchantability, fitness
%          for a particular purpose, and non-infringement.
%
%          The software is provided on an "as is" basis and M.I.T. has no
%          obligation to provide maintenance, support, updates, enhancements,
%          or modifications.

% Removed reserved but unused part
if length(science_data.day) > science_data.scan_counter,
    science_data.day(:,(science_data.scan_counter+1):end) = [];
    science_data.msec_of_day(:,(science_data.scan_counter+1):end) = [];
    science_data.usec_of_msec(:,(science_data.scan_counter+1):end) = [];
    science_data.scan_angle_degrees(:,(science_data.scan_counter+1):end) = [];
    science_data.error_status_flags(:,(science_data.scan_counter+1):end) = [];
    science_data.radiometric_counts(:,(science_data.scan_counter+1):end) = [];
    science_data.pacseq(:,(science_data.scan_counter+1):end) = [];
    science_data.seqnum(:,(science_data.scan_counter+1):end) = [];
end

if science_data.scan_counter > 1    
    
    if NO_STARE_FLAG,
        fprintf('No stare data found.\n')
        
        % reshape count matrix to 22x104xN  4*HOT + 96*SCENE + 4*COLD

        % The next bit of code truncates the science packets so it ends 
        % with a spot at the end of a scan and begins with a spot at 
        % the beginning of a scan

        % Ideally, this would mean that the packets evenly divided into
        % scans of 104 spots, but the NGES test equipment loses packets,
        % so this doesn't always work.
        
        % Variable set by read_atms_rdr_hdf5.m to bypass the trim code
        %if exist('no_trim','var') ~=1 || no_trim ~= 1,
        if rem(length(science_data.scan_angle_degrees), 104) ~= 0 || ...
                exist('no_trim','var') ~=1 || no_trim ~= 1,
            % find 1st scene data (307.5 degrees)
            test = science_data.scan_angle_degrees(1:104);
            h_ind = find(abs(test - 307.5) == min(abs(test - 307.5)));

            science_data.day(:,1:(h_ind-1)) = [];
            science_data.msec_of_day(:,1:(h_ind-1))  = [];
            science_data.usec_of_msec(:,1:(h_ind-1)) = [];
            science_data.scan_angle_degrees(:,1:(h_ind-1)) = [];
            science_data.error_status_flags(:,1:(h_ind-1)) = [];
            science_data.radiometric_counts(:,1:(h_ind-1)) = [];
            science_data.pacseq(:,1:(h_ind-1)) = [];
            science_data.seqnum(:,1:(h_ind-1)) = [];

            % find last hot cal (196.5 degrees)
            L = length(science_data.scan_angle_degrees);
            %test = science_data.scan_angle_degrees((L-103):L);
            %c_ind = find(abs(test - 196.5) == min(abs(test - 196.5)))+L-103+1;
            test = science_data.scan_angle_degrees;
            c_ind = find(test > 196.5 & test < 198);

            if isempty(c_ind) ~= 1
                if L > length(c_ind)
                    science_data.day(:,c_ind(end)+1:L) = [];
                    science_data.msec_of_day(:,c_ind(end)+1:L)  = [];
                    science_data.usec_of_msec(:,c_ind(end)+1:L) = [];
                    science_data.scan_angle_degrees(:,c_ind(end)+1:L) = [];
                    science_data.error_status_flags(:,c_ind(end)+1:L) = [];
                    science_data.radiometric_counts(:,c_ind(end)+1:L) = [];
                    science_data.pacseq(:,c_ind(end)+1:L) = [];
                    science_data.seqnum(:,c_ind(end)+1:L) = [];
                end
            end
        else
            disp('NOT TRIMMING RECORDS');
        end

        % This test determines if there are missing or extra science packets.
        % If there are, any scans that aren't 104 in size are removed.
        if MISSING_SEQNUM || rem(length(science_data.scan_angle_degrees), 104) > 0,
            % Attempt to remove scans with missing science packets
            disp('Original science packets saved in science_data_orig.');
            science_data_orig = science_data;
            test = science_data.scan_angle_degrees;
            c_ind = find(test > 196.5 & test < 198);
            c_ind = [0 c_ind];
            c_diff = diff(c_ind);
            bad_ind = find(c_diff ~= 104);
            if ~isempty(bad_ind)
                disp('Irregular science packets saved in science_data_irreg.');
                for iBad = length(bad_ind):-1:1
                    % Save irregular science packets
                    if exist('science_data_irreg', 'var') ~= 1,
                        % Create science_data_irreg
                        science_data_irreg.day = science_data.day(c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.msec_of_day  = science_data.msec_of_day(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.usec_of_msec = science_data.usec_of_msec(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.scan_angle_degrees = science_data.scan_angle_degrees(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.error_status_flags = science_data.error_status_flags(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.radiometric_counts = science_data.radiometric_counts(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.pacseq = science_data.pacseq(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                        science_data_irreg.seqnum = science_data.seqnum(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1));
                    else
                        % Prepend to science_data_irreg
                        science_data_irreg.day = [science_data.day(c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.day];
                        science_data_irreg.msec_of_day  = [science_data.msec_of_day(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.msec_of_day];
                        science_data_irreg.usec_of_msec = [science_data.usec_of_msec(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.usec_of_msec];
                        science_data_irreg.scan_angle_degrees = [science_data.scan_angle_degrees(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.scan_angle_degrees];
                        science_data_irreg.error_status_flags = [science_data.error_status_flags(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.error_status_flags];
                        science_data_irreg.radiometric_counts = [science_data.radiometric_counts(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.radiometric_counts];
                        science_data_irreg.pacseq = [science_data.pacseq(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.pacseq];
                        science_data_irreg.seqnum = [science_data.seqnum(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) science_data_irreg.seqnum];
                    end
                    % Correct value for scan_counter based on the actual
                    % number of scans
                    science_data_orig.scan_counter  = length(science_data_orig.scan_angle_degrees);
                    science_data_irreg.scan_counter = length(science_data_irreg.scan_angle_degrees);
                    % Remove irregular science packets from science_data so
                    % it can be reshaped into 104xN and 22x104xN
                    science_data.day(c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.msec_of_day(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1))  = [];
                    science_data.usec_of_msec(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.scan_angle_degrees(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.error_status_flags(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.radiometric_counts(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.pacseq(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                    science_data.seqnum(:,c_ind(bad_ind(iBad))+1:c_ind(bad_ind(iBad)+1)) = [];
                end
            end
        end

        % reshape to 104xN and 22x104xN
        L = length(science_data.scan_angle_degrees);
        % Double Check L/104 is an integer
        if rem(L, 104) == 0,
            science_data.day = reshape(science_data.day, 104, L/104);
            science_data.msec_of_day  = reshape(science_data.msec_of_day, 104, L/104);
            science_data.usec_of_msec = reshape(science_data.usec_of_msec, 104, L/104);
            science_data.scan_angle_degrees = reshape(science_data.scan_angle_degrees, 104, L/104);
            science_data.error_status_flags = reshape(science_data.error_status_flags, 104, L/104);
            science_data.radiometric_counts = reshape(science_data.radiometric_counts, 22, 104, L/104);
            science_data.pacseq = reshape(science_data.pacseq, 104, L/104);
            science_data.seqnum = reshape(science_data.seqnum, 104, L/104);
            science_data.scan_counter = L/104;
        end
    else
        fprintf('Not pruning or reshaping science_data.\n')
    end

end