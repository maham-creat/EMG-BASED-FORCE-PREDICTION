metricValues =[]; 

for i =1:8
 Semg1=iemg{i};
 n=size(Semg1,2)
 force1=force{i};
n=size(Semg1 ,2)
% data = [emg2 force2];
 data = [Semg1 force1];
cv = cvpartition(size(data, 1), 'HoldOut', 0.5);
trainIdx = cv.training;
data_train = data(trainIdx, :);
data_test = data(~trainIdx, :);
%semg
xtrain =data_train(:,1:n);%xtrain =data_train(:,7:12);
ytrain = data_train(:,n+1:end);
xtest = data_test(:, 1:n);%xtrain =data_train(:,7:12 );
ytest = data_test(:, n+1:end);
%iemg
%Transpose xtrain and xtest
xtrain = xtrain';
xtest = xtest';
% Transpose ytrain to match input shape
ytrain = ytrain';ytest = ytest'
numFeatures = size(xtrain, 1);
numResponses = size(ytrain, 1);
% Define the TCN architecture
numFilters = 64;
filterSize = 3;
dropoutFactor = 0.005;
layer = sequenceInputLayer(numFeatures, 'Normalization', 'rescale-symmetric', 'Name', 'input');
lgraph = layerGraph(layer);
outputName = layer.Name;
for i = 1
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
 tempLayers = [
    lstmLayer(100, 'OutputMode', 'sequence', 'Name', 'lstm')
    fullyConnectedLayer(numResponses,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
lgraph = connectLayers(lgraph, outputName, 'lstm');

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
toc
e=(ytest-Y);
rmse = mean(sqrt(mean((Y-ytest).^2)))
mae1=mae(e)
Rsq1 = 1 - sum((ytest - Y).^2)/sum((ytest - mean(ytest)).^2)
mse = mean(mean((ytest -Y).^2))
% Calculate Root Mean Squared Error (RMSE)
metr=[ mae1  mse rmse Rsq1]
metricValues=[metricValues;metr]
save tcnlstmetric metricValues
%  figure
% for j =1:6
% subplot(2,3,j)
 plot(ytest(:, 1), 'r')
        hold on
        plot(Y(:, 1), 'k');
        legend("actual force", 'predicted force')


% end
end
