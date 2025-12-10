cv = cvpartition(size(data, 1), 'HoldOut', 0.2);
trainIdx = cv.training;
data_train = data(trainIdx, :);
data_test = data(~trainIdx, :);
xtrain =data_train(:,1:end-1);%xtrain =data_train(:,7:12);
ytrain = categorical(data_train(:,end));
xtest = data_test(:, 1:end-1);%xtrain =data_train(:,7:12 );
ytest =categorical(data_test(:, end)) ;
%Transpose xtrain and xtest
xtrain = xtrain';
xtest = xtest';
ytrain = ytrain';ytest = ytest'
    numFeatures = size(xtrain, 1)
numFeatures = size(xtrain, 1);
numResponses = 1;
numclasses=2
% Define the TCN architecture
numFilters = 64;
filterSize = 3;
dropoutFactor = 0.005;

layer = sequenceInputLayer(numFeatures, 'Normalization', 'rescale-symmetric', 'Name', 'input');
lgraph = layerGraph(layer);
outputName = layer.Name;
for i = 1:2
dilationFactor = 2^(i-1);
layers = [
convolution1dLayer(filterSize, numFilters, 'DilationFactor', dilationFactor, 'Padding', 'causal', 'Name', ['conv1_', num2str(i)])
layerNormalizationLayer
dropoutLayer(dropoutFactor) % Use dropoutLayer for regression
convolution1dLayer(filterSize, numFilters, 'DilationFactor', dilationFactor, 'Padding', 'causal')
layerNormalizationLayer
reluLayer
dropoutLayer(dropoutFactor) % Use dropoutLayer for regression
additionLayer(2, 'Name', ['add_', num2str(i)])];
lgraph = addLayers(lgraph, layers);
lgraph = connectLayers(lgraph, outputName, ['conv1_', num2str(i)]);
if i == 1
layer = convolution1dLayer(1, numFilters, 'Name', 'convSkip');
lgraph = addLayers(lgraph, layer);
lgraph = connectLayers(lgraph, outputName, 'convSkip');
lgraph = connectLayers(lgraph, 'convSkip', ['add_', num2str(i), '/in2']);
else
lgraph = connectLayers(lgraph, outputName, ['add_', num2str(i), '/in2']);
end
outputName = ['add_', num2str(i)];
end
layers = [
fullyConnectedLayer(numclasses, 'Name', 'fc')
classificationLayer]; % Use regressionLayer for regression
lgraph = addLayers(lgraph, layers);
lgraph = connectLayers(lgraph, outputName, 'fc');
options = trainingOptions('adam', ...
'MaxEpochs', 700, ...
'GradientThreshold', 1, ...
'InitialLearnRate', 0.005, ...
'LearnRateSchedule', 'piecewise', ...
'LearnRateDropPeriod', 125, ...
'LearnRateDropFactor', 0.2, ...
'Verbose', 0, ...
'Plots', 'none', ...
'MiniBatchSize', 32)
% Create and train the TCN model
tic
[net, info] = trainNetwork(xtrain, ytrain, lgraph, options);
% Make predictions
Y = predict(net, xtest);
Y=categorical(Y)
accuracy = 100*sum(Y == ytest) / numel(ytest);