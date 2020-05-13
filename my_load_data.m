function ShotContainer = my_load_data(shot, signalList_ptd, signalList_mds, tmin, tmax, ShotContainer, ishot)

% my_load_data.m - Load shot data from DIII-D database
%
% Syntax:  output = function_name(input1, imput2, input3, input4, input5, 
%                                 input6, input7)
%
% Inputs:
%    shot - Shot number
%    signalList_ptd - Lis of signals from PTD
%    signalList_mds - Lis of signals from MDS
%    tmin - Extract data starting from time tmin
%    tmax - Extract data until tmax
%    ShotContainer - Structure of arrays containig shot data
%    ishot - shot counter
%    
%
% Outputs:
%    ShotContainer - Structure of arrays containig new shot data
%
% Example: 
%    ShotContainer = my_load_data(shot, signalList_ptd, signalList_mds, 
%                                 tmin, tmax, ShotContainer, ishot)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ntm_21_database.m, getdata.m, getlp_raw.m and getptd.m from
%           DIII-D database
%
% Author: Yichen Fu
% Princeton Plasma Physics Laboratory
% email: xxx@pppl.gov
%
% Created on Mar-2018
%
%
% Last revision: 27-Apr-2020 by Leonel M. Palacios
%
% A different data container was implemented. The original function used a 
% Map to store shot data. This type of structure was difficult to manage. 
% A structure of arrrays was implemented to improve shot data management. 
% Some variables were renamed to provide more insight into the nature of
% the variable.


%------------- BEGIN OF CODE --------------


%% Get data from function getptd.m 
sigIndex = 1;
structIndex = 1;

while sigIndex <= length(signalList_ptd)
    
    sigName = lower(signalList_ptd(sigIndex));
    [data, tvec] = getptd(shot, char(sigName), tmin, tmax);
    
    % Obtain the absolute values for signals ip and iptipp
    % || stantds for OR logical operator
    if strcmp(sigName, 'ip') || strcmp(sigName, 'iptipp') 
        data = abs(data);
    end
    
    ShotContainer(ishot).data(structIndex,:) = {sigName, tvec, data};
    
    sigIndex = sigIndex + 1;
    structIndex = structIndex + 1;
end


%% Get data from function getmds.m
structIndex = length(signalList_ptd) + 1;
sigIndex = 1;

while sigIndex <= length(signalList_mds)
    
    sigName = lower(signalList_mds(sigIndex));
    
    if (strcmp(char(sigName), 'tinj') || strcmp(char(sigName), "pinj"))
        [data, tvec] = getmds(shot, char(sigName), tmin, tmax, 'NB');
    elseif strcmp(char(sigName), "pech")
        [data, tvec] = getmds(shot, char(sigName), tmin, tmax, 'transport');
    elseif strcmp(char(sigName), 'aminor')
        [data, tvec] = getmds(shot, char(sigName), tmin, tmax, 'EFIT01');
    elseif strcmp(char(sigName), 'n1rms')
        [data, tvec] = getmds(shot, char(sigName), tmin, tmax, 'mhd');
    else
        [data, tvec] = getmds(shot, char(sigName), tmin, tmax, 'EFITRT1');
    end
    
    ShotContainer(ishot).data(structIndex,:) = {sigName, tvec, data};
    
    sigIndex = sigIndex + 1;
    structIndex = structIndex + 1;
    
end

end
%------------- END OF CODE --------------

