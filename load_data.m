function signalContainer = load_data(shot, signalList_ptd, signalList_mds, tmin, tmax)
%LOAD_DATA download data in signal list for a given shot
%
% Author: Yichen Fu, created by Mar 16th, 2018
% Purpose: Put all the procedures of loading data into one function,
%          including both mds data and ptd data.

signalContainer = containers.Map;

    % ========== Get data from function getptd ==========
    isig = 1;

    while isig <= length(signalList_ptd)
        sig = lower(signalList_ptd(isig));
        [data, tvec] = getptd(shot, char(sig), tmin, tmax);

        % use abs(ip)
        if strcmp(sig, 'ip') || strcmp(sig, 'iptipp')
            data = abs(data);
        end
        
        signalContainer(char(sig+'_time')) = tvec;
        signalContainer(char(sig+'_data')) = data;

        isig = isig + 1;
    end

    % ========== Get data from function madvalue ==========
    isig = 1; 

    while isig <= length(signalList_mds)
        sig = signalList_mds(isig);

        node = char(lower(signalList_mds(isig)));
        
        if (strcmp(node, 'tinj') || strcmp(node, "pinj"))
            [data, tvec] = getmds(shot, node, tmin, tmax, 'NB');
        elseif strcmp(node, "pech")
            [data, tvec] = getmds(shot, node, tmin, tmax, 'transport');
        elseif strcmp(node, 'aminor')
            [data, tvec] = getmds(shot, node, tmin, tmax, 'EFIT01');
        elseif strcmp(node, 'n1rms')
            [data, tvec] = getmds(shot, node, tmin, tmax, 'mhd');
        else
            [data, tvec] = getmds(shot, node, tmin, tmax, 'EFITRT1');
        end

        signalContainer(char(sig+'_time')) = tvec(1:end);
        signalContainer(char(sig+'_data')) = data(1:end);

        isig = isig + 1;
    end

end

