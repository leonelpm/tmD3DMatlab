

%% Load raw data
% Load non-tearing mode data (it takes ~1 minute)
% rawNTMData is ~4.69 GB
% load('rawNTMData.mat');


%% Non-tearing mode raw data
% Substitute empty cells for zeros

% Create a dummy structure of arrays
dummyNTM = rawNTMData;

for j = 1:length(dummyNTM)
    for k = 1:length(dummyNTM(j).data)
        if isempty(dummyNTM(j).data{k,2})
            dummyNTM(j).data{k,2} = dummyNTM(j).data{3,2};
            dummyNTM(j).data{k,3} = zeros(length(dummyNTM(j).data{3,2}),1);
        end
    end
end

m = 0;
for j = 1:length(dummyNTM)
    for k = 1:length(dummyNTM(j).data)
        if (isfloat(dummyNTM(j).data{k,2})) && (isfloat(dummyNTM(j).data{k,3}))
        else
            m = m + 1;
            store(m) = j;
        end
    end
end

dummyNTM(store) = [];

n = 0;
for j = 1:length(dummyNTM)
    for k = 1:length(dummyNTM(j).data)
        if length(dummyNTM(j).data{k,2}) < 2 || length(dummyNTM(j).data{k,3}) < 2
            n = n + 1;
            store2(n) = j;
        end
    end
end


% Interpolation
tStep = 0.0005;
% proNTMData{3,1} = [];
proNTMData{length(dummyNTM),1} = [];

for j = 1:length(dummyNTM)
    
    % Print status
    fprintf('Non-tearing mode item #%i\n',j)
    
    t0 = dummyNTM(j).data{1,2}(1);
    tf = dummyNTM(j).data{1,2}(end);
    times = t0:tStep:tf;
    
    for k = 1:length(dummyNTM(j).data)
        
        proNTMData{j}(k,:) = interp1(dummyNTM(j).data{k,2},dummyNTM(j).data{k,3},times,'spline');
        
    end
    
    if isnan(proNTMData{j})
        warning('proNTMData #%i contains NaNs\n',j)
    end
    
end

% save('proNTMData.mat','proNTMData')

