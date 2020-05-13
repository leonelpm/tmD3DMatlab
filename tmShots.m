
function output = tmShots(tm_shot_list)

%tmShots.m - Extracts shot number and the time at which tearing mode (TM) appears 
% TM shots stored in text files. These text files were obtain from the
% function ntm_21_database.m elaborated by Qiming Hu.
%
% Syntax:  output = function_name(input)
%
% Inputs:
%    input - Text file name and extention
%
% Outputs:
%    output - Array containing shot number and time at which TM appears
%
% Example: 
%    tm_shot_list = 'shots2016.txt'
%    output = tmShots(tm_shot_list)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ntm_21_database.m, getdata.m, getlp_raw.m and getptd.m from
%           DIII-D database
%
% Author: Leonel Palacios
% Princeton Plasma Physics Laboratory
% email: lmpalaci@pppl.gov
%
% Apr 2020; Last revision: 17-Apr-2020

%------------- BEGIN OF CODE --------------

% Open the text file
fid = fopen(tm_shot_list,'rt');

% Read data, removes headers and store in S
S = textscan(fid,'%.0f %12f %12f %12f %12f %12f %12f %12f %12f %12f %12f %12f %12f','HeaderLines',1);
S(end) = [];
fclose(fid);

% Convert from cell to mat file
data  = cell2mat(S);

% Extract shot number and time at which TM appears
output = data(:,1:2);

%------------- END OF CODE --------------
