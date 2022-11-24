# M3-TG-project-testing

# Data:
Converted_data_test1.txt contains 4 different activity periods.
Indexes are determined after resampling to 100Hz:
Walking begin: index 0 

Walking end:  index 11462

Jogging begin: index 17918

Jogging end:   index 26764

Running begin: index 37288

Running end:   index 49204

Sprinting begin: index 66622

Sprinting end:   index 73593


# Files:
Preprocessing.m: Preprocesses the data, as described in the report

par_det_optimal.m: Estimate optimal parameters A and D on walking segment, test on jogging segment. 

par_det_simulink.m: Estimate optimal parameters for SSmodel.slx on walking segment, test on jogging segment. 

par_det_sample_points.m:

SSmodel.slx: first-order LTI Simulink model

bestresults.mat: Contains the results of par_det_optimal.m in a Matlab Structure

preprocessed_data.mat: Contains the preprocessed version of Converted_data_test1.txt