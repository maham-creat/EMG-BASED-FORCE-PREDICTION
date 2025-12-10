%%
motions = { '2012.03.07_sub4_FlexExt_trial2','2012.03.07_sub4_ProSup_trial2' , '2012.03.07_sub4_FlexSup_ExtPro_trial2','2012.03.07_sub4_FlexPro_ExtSup_trial2'};
motions = { 'FlexExt_trial2','ProSup_trial2' , 'FlexSup_ExtPro_trial2','FlexPro_ExtSup_trial2'};
movements = cell(1, length(motions));
%prosup =3 4 extpro 5 6 flexpro 7 8 flexext 1 2
for motion_idx = 1:length(motions)
    % Load the data from the MAT file
    mat_file_name = [motions{motion_idx}, '.mat'];
    load(mat_file_name);
    data = totalData.data;
    label = totalData.label;
    data1 = data(29218:270000, :);
    sampling_frequency=10000;
    % Your existing code to segment data and create m1
    a = 2* ones(1, 13);
    segment_durations = a;
    num_segments = length(segment_durations);
    
    segments = cell(num_segments, 1);
    current_sample = 1;
    
    for i = 1:num_segments
        segment_duration = segment_durations(i);
        samples_per_segment = sampling_frequency * segment_duration;
        
        if current_sample + samples_per_segment - 1 <= length(data1)
            end_sample = current_sample + samples_per_segment - 1;
        else
            end_sample = length(data1);
        end
        
        segments{i} = data1(current_sample:end_sample, :);
        current_sample = end_sample + 1;
    end
    
    m1 = [segments{1, 1}; segments{3, 1}; segments{5, 1};
      segments{7, 1};segments{9, 1};segments{11, 1} ];
        m2=[segments{2, 1};segments{4, 1};segments{6, 1};
            segments{8, 1}; segments{10, 1};segments{12, 1}];
    mo={m1;m2};
    % Save the m1 values in the cell array
    movement{motion_idx} = mo;
end
movements={movement{1, 1}{1, 1};movement{1, 1}{2, 1};
    movement{1, 2}{1, 1};
    movement{1, 3}{1, 1};movement{1, 3}{2, 1};
    movement{1, 4}{1, 1};movement{1, 4}{2,1}}
save movements.mat movements
