


allDataCell = [proTMData; proNTMData];
n = numel(allDataCell);
ii = randperm(n);
allData = allDataCell(ii);

x_val = allData(1:1250);
x_test = allData(1251:2501);
x_train = allData(2502:end);

allLabelsCell = [TMLabels; NTMLabels];
allLabels = allLabelsCell(ii);

y_val = allLabels(1:1250);
y_test = allLabels(1251:2501);
y_train = allLabels(2502:end);

numFeatures = 24;
numHiddenUnits = 200;
numClasses = 1;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',10, ...
    'GradientThreshold',2, ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(x_train,y_train,layers,options);

