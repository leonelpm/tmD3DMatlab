

% loadD3DShotData.m - Load shot data from DIII-D database
%
% This function is used to load shot data from DIII-D database. First for
% tearing mode shots and then for non-tearing mode shots. Output is saved
% as a structure of arrays.
%
%
% Other m-files required: ntm_21_database.m, getdata.m, getlp_raw.m, 
%                         getptd.m, getShots2016.m, getShots2017.m,
%                         getShots2018.m, getShots2019.m, my_load_data.m
%
% Subfunctions required: none
% MAT-files required: none
% TXT-files required: tm_2016.txt, tm_2017.txt, tm_2018.txt,tm_2019.txt, 
%
%
% Author: Leonel M. Palacios
% Princeton Plasma Physics Laboratory
% email: lmpalaci@pppl.gov
%
% Created on May-2020


%------------- BEGIN OF CODE --------------

% Clear workspace and command window
clear
clc

% This path must be added just once
% addpath(genpath('/fusion/projects/codes/toksys/builds/current'))

% These commands connect to DIII-D databases. They take about 30 seconds 
% to load
toksys_startup; 
d3d_startup


%% Get all the shots from 2016 to 2020

% All shots by year
allShots2016 = getShots2016;
allShots2017 = getShots2017;
allShots2018 = getShots2018;
allShots2019 = getShots2019;

% Get TM shots by year (shot number, TM time)
tm2016 = tmShots('tm_2016.txt');
tm2017 = tmShots('tm_2017.txt');
tm2018 = tmShots('tm_2018.txt');
tm2019 = tmShots('tm_2019.txt');

% Get all TM shots
allTMShots = [tm2016; tm2017; tm2018; tm2019];

% Get non-TM shots by year (shot number, flat-top start time, flat-top end
% time)
ntm2016 = nonTMShots(allShots2016,tm2016);
ntm2017 = nonTMShots(allShots2017,tm2017);
ntm2018 = nonTMShots(allShots2018,tm2018);
ntm2019 = nonTMShots(allShots2019,tm2019);

% Get all TM shots
allNonTMShots = [ntm2016; ntm2017; ntm2018; ntm2019];

% Signals obtained from the function getptd.m
signalList_ptd = ["ip", "iptdirect", "iptipp", "ONSMHDAF", "ONSMHDFF", ...
                  "EFSWMHD", "EFSBETAN", "EFSBETAT", "EFSBETAP", ...
                  "EFSLI", "EFSLI3", "EFSQ0", "EFSQMIN", "EFSVOLUME", ...
                  "PCVLOOP", "PCVLOOPB", "DSSDENEST"];

% Signals obtained from the function getmds.m
signalList_mds = ["q95", "kappa", "r0", "chisq", "pinj", "pech", "n1rms"];

%% Load data for TM shots
% Data from the last 2 seconds before tearing mode appear is
% obtained for machine learning training.

% Set the index of shots
ishot = 1;

% Set the lenght of the data sample
shot_length = 2.0;

% Pre-allocate an array of structures to save the shot data
rawTMData = struct([]);

% Start loading de data
while ishot <= length(allTMShots)
    
    % Select the i-th shot
    shot = allTMShots(ishot,1);
    
    % Initialize the structure of arrays with the shot number
    rawTMData(ishot).number = shot;
    
    % Auxiliar time is set to 50ms before tearing mode appear
    tAux = allTMShots(ishot,2) - 0.05;
    
    % Initial auxiliar time. Data is obtained from this time and onwards. 
    tmin = max(tAux - shot_length, 0);
    
    % Obtain shot data
    rawTMData = my_load_data(shot, signalList_ptd, signalList_mds, tmin, 10, rawTMData, ishot);
    
    % Print status
    fprintf('Item #%i, tearing mode shot number: %i\n',ishot, shot)
    
    % Advance for-loop index
    ishot = ishot + 1;  
end

% Save the structure of arrays
% save('rawTMData.mat','rawTMData', '-v7.3')


%% Load data for non-TM shots
% Data from the last 2 seconds before flat-top stage ends is
% obtained for machine learning training.

% Set the indexes of shots and structure of arrays
ishot = 1;
index = 1;

% Set the lenght of duration of the shot. The duration of the shot was
% established in the TM section
% shot_length = 2.0;

% Pre-allocate the structure of arrays for shot data
rawNTMData = struct([]);

% Start loading de data
while ishot <= length(allNonTMShots)
    
    % Duration of the flat_top stage in seconds
    flat_duration = allNonTMShots(ishot,3)/1000.0;
    
    % Auxiliar time is set to 50ms before flat-top phase end time
    timeFlatTopEnd = flat_duration - 0.05;
    
    % Initial auxiliar time. Data is obtained from this time and onwards. 
    tmin = timeFlatTopEnd - shot_length;
    
    % Load the shot
    if (timeFlatTopEnd > tmin) && (tmin > 0.0)
        
        % Select the i-th shot number and flat-top stage duration
        shotNumber = allNonTMShots(ishot,1);
        
        % Assign shot number to shot container
        rawNTMData(index).number = shotNumber;
        
        % Obtain shot data
        rawNTMData = my_load_data(shotNumber, signalList_ptd, signalList_mds, tmin, timeFlatTopEnd, rawNTMData, index);
        
        % Print status
        fprintf('Item #%i, non-tearing mode shot number: %i\n',index, shotNumber)
        
        % Advance structure index
        index = index + 1;
        
    end
    
    % Advance for-loop index
    ishot = ishot + 1;
    
end

% Save the structure of arrays
% save('rawNTMData.mat','rawNTMData', '-v7.3')

%------------- END OF CODE --------------

