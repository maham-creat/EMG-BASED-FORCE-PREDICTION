
metricValues = [];
 dataset_num =6
      load(['s' num2str(dataset_num )])
      
      for i=1
       Semg1=semg{i};    
      force2=force12{i};
n=3
force1=force2(:,n);
 data = [Semg1 force1];
% Loop through each model

    mse = [];
    r2 = [];
    mae1 = [];
    rmse = [];
     

        % Define the number of folds for cross-validation
        numFolds = 5;

        % Initialize matrices to store metrics values for each fold
        mse_values =[];
        r2_values = [];
        mae_values = [];
        rmse_values = [];

        % Create a k-fold cross-validation partition
        cv = cvpartition(size(data, 1), 'KFold',5);

        for j = 1:5
            % Get indices for the training and test sets
            trainInds = training(cv, j);
            testInds = test(cv, j);

            % Split the data into training and test sets
            trainingData = data(trainInds, :);
            testData = data(testInds, :);
xtrain =trainingData(:,1:end-1);%xtrain =data_train(:,7:12);
ytrain = trainingData(:,end);
xtest = testData(:, 1:end-1);%xtrain =data_train(:,7:12 );
ytest =testData(:, end);

            % Train the regression model based on the current model_num
           
                % Model 2: Gaussian Process Regression (GPR) with matern52 kernel
 mdl = fitrgp(xtest ,ytest,'BasisFunction', 'constant', ...
'KernelFunction', 'matern52', 'Standardize', true);
Y= predict(mdl, xtrain);
   e = (ytrain - Y);
    rmse = mean(sqrt(mean((Y - ytrain ).^2)));
    mae1 = mae(e);
    Rsq1 = 1 - sum((ytrain  - Y).^2) / sum((ytrain  - mean(ytrain )).^2);
    mse = mean(mean((ytrain  - Y).^2));
        end
mse_values=[mse_values mae1 ]
   r2_values=[r2_values Rsq1]
  rmse_values =[  rmse_values rmse]
  mae_values=[mae_values mae1]
        average_mse = mean(mse_values);
        average_r2 = mean(r2_values);
        average_rmse = mean(rmse_values);
        average_mae = mean(mae_values);
       
        metr = [average_mae average_mse average_rmse average_r2];

      metricValues = [metricValues;metr]

end
  end

save gpr ytest Y
