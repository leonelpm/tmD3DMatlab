

function output = nonTMShots(full_shot_list,tm_shot_list)

% nonTMShots.m - Extracts non-tearig mode shot numbers from a list
% of generic shots.
%
% Syntax:  output = function_name(input1, imput2)
%
% Inputs:
%    input1 - Full list of shots covering the years 2016-2020 obtained 
%             from OMFIT
%    input2 - List of TM shots obtained from the function 
%             ntm_21_database.m elaborated by Qiming Hu
%
% Outputs:
%    output - Array containing non-tearig mode shot numbers
%
% Example: 
%    output = nonTMShots(full_shot_list,tm_shot_list)
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

% From the full list of generic shots, eliminate those with TM and
% rearrange the array.
for j = 1:length(tm_shot_list)
    
    k = find(full_shot_list == tm_shot_list(j,1));
    full_shot_list(k,:) = [];
    
end

% Write the non-TM shot list to output variable
output = full_shot_list;

%------------- END OF CODE --------------

