
% dataProcessing.m - Prepare raw data for machine learning trainig
%
% This function is used to prepare the raw data obtained from DIII-D to use
% it to train machine learning algorithms (e.g. neural networks). It
% removes empty data, non-floating entries and interpolates to have
% constant time step. 
%
% Other m-files required: none
%
% Subfunctions required: none
% MAT-files required: rawTMData.mat and rawNTMData.mat
% TXT-files required: none 
%
%
% Author: Leonel M. Palacios
% Princeton Plasma Physics Laboratory
% email: lmpalaci@pppl.gov
%
% Created on May-2020


%------------- BEGIN OF CODE --------------

%% Load raw data
% Load tearing mode data (it takes ~1 minute)
% rawTMData is ~3.21 GB
% load('rawTMData.mat');

% Load non-tearing mode data (it takes ~1 minute)
% rawNTMData is ~4.69 GB
% load('rawNTMData.mat');

%% Tearing mode raw data

% 1. Substitute empty cells for zeros
% Create a dummy structure of arrays
dummyTM = rawTMData;

for j = 1:length(dummyTM)
    
    for k = 1:length(dummyTM(j).data)
        if isempty(dummyTM(j).data{k,2})
            dummyTM(j).data{k,2} = dummyTM(j).data{3,2};
            dummyTM(j).data{k,3} = zeros(length(dummyTM(j).data{3,2}),1);
        end   
    end
    
end

% 2. Interpolate at constant time step and create labels
% Time step
tStep = 0.005;

% Prediction window
predictionWindow = 0.25;

% Width of the sigmoid
sigmoidWidth = 0.02;

% Preallocate a cell to save interpolated data
proTMData{length(dummyTM),1} = [];

% Preallocate a cell to save labels
TMLabels{length(dummyTM),1} = [];

for j = 1:length(dummyTM)
    
    % Print status
    fprintf('Tearing mode item #%i\n',j)
    
    t0 = dummyTM(j).data{1,2}(1);
    tf = dummyTM(j).data{1,2}(end);
    times = linspace(t0,tf,2000);
    
    for n = 1:length(times)
        deltaT = times(n) - dummyTM(j).tmTime;
        TMLabels{j}(1,n) = 1.0 / (1.0 + exp((-deltaT-predictionWindow)/(sigmoidWidth)));
    end
    
    for k = 1:length(dummyTM(j).data)
        proTMData{j}(k,:) = interp1(dummyTM(j).data{k,2},dummyTM(j).data{k,3},times,'spline');
    end
    
    if isnan(proTMData{j})
        warning('proTMData #%i contains NaNs\n',j)
    end
    
end


% Save interpolated data
save('proTMData.mat','proTMData','TMLabels','-v7.3')


%% Non-tearing mode raw data

% 1. Substitute empty cells for zeros
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

% 2. Remove shots with non-floating data
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

% 3. Remove shots with scalar entries
n = 0;
for j = 1:length(dummyNTM)
    for k = 1:length(dummyNTM(j).data)
        if length(dummyNTM(j).data{k,2}) < 2 || length(dummyNTM(j).data{k,3}) < 2
            n = n + 1;
            store2(n) = j;
        end
    end
end

dummyNTM(store2) = [];

% 4. Interpolate at constant time step 
% Select the time step. Ideally it should be the same as TM data
% tStep = 0.005;

% Preallocate a cell to save interpolated data
proNTMData{length(dummyNTM),1} = [];

for j = 1:length(dummyNTM)
    
    % Print status
    fprintf('Non-tearing mode item #%i\n',j)
    
    t0 = dummyNTM(j).data{1,2}(1);
    tf = dummyNTM(j).data{1,2}(end);
    times = linspace(t0,tf,2000);
    
    for k = 1:length(dummyNTM(j).data)
        proNTMData{j}(k,:) = interp1(dummyNTM(j).data{k,2},dummyNTM(j).data{k,3},times,'spline');
    end
    
    if isnan(proNTMData{j})
        warning('proNTMData #%i contains NaNs\n',j)
    end
    
end


% 5. Create NTM labels
% Preallocate a cell to save labels
NTMLabels{length(proNTMData),1} = [];

for j = 1:length(proNTMData)
    
    NTMLabels{j} = zeros(1,length(proNTMData{j}));
    
end

% Save interpolated data
save('proNTMData.mat','proNTMData','NTMLabels','-v7.3')

%% Assemble data into a single structure

% Merge TM and non-TM into a single cell and permute randomly
% allDataCell = [proTMData; proNTMData];
% n = numel(allDataCell);
% ii = randperm(n);
% % [~,previous_order] = sort(ii);
% allData = allDataCell(ii);
% 
% % Move data to structure amenable for Python (e.g. csv)
% data4Training = [];
% 
% for j = 1:length(allData)
%     
%     fprintf('Merge shot item #%i\n',j)
%     data4Training = vertcat(data4Training, allData{j}'); 
%     
% end
% 
% writematrix(data4Training,'data4Training.csv') 
% 
% 
% % Merge TM and non-TM labels into a single cell and permute randomly
% allLabelsCell = [TMLabels; NTMLabels];
% allLabels = allLabelsCell(ii);
% 
% % Move labels to structure amenable for Python (e.g. csv)
% labels4Training = [];
% 
% for j = 1:length(allLabels)
%     
%     fprintf('Merge label item #%i\n',j)
%     labels4Training = vertcat(labels4Training, allLabels{j}'); 
%     
% end
% 
% writematrix(labels4Training,'labels4Training.csv')


%% Assemble data into a 3D matrix

% Merge TM and non-TM into a single cell and permute randomly
allDataCell = [proTMData; proNTMData];
n = numel(allDataCell);
ii = randperm(n);
% [~,previous_order] = sort(ii);
allData = allDataCell(ii);

% Move data to structure amenable for Python (e.g. csv)
data3D = zeros(length(allData),2000,24);

for j = 1:length(allData)
    
    fprintf('Merge shot item #%i\n',j)
    data3D(j,:,:) = allData{j}'; 
    
end



% Merge TM and non-TM labels into a single cell and permute randomly
allLabelsCell = [TMLabels; NTMLabels];
allLabels = allLabelsCell(ii);

% Move labels to structure amenable for Python (e.g. csv)
labels3D = zeros(length(allData),2000,1);

for j = 1:length(allLabels)
    
    fprintf('Merge label item #%i\n',j)
    labels3D(j,:) = allLabels{j}'; 
    
end

% Save 3D data
save('Data3D.mat','data3D','-v7.3')
save('Labels3D.mat','labels3D','-v7.3')


%------------- END OF CODE --------------
