% CNN main fucntion

% Cifar10 Data Set download
url = 'https://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz';
downloadFolder = tempdir;
filename = fullfile(downloadFolder,'cifar-10-matlab.tar.gz');

dataFolder = fullfile(downloadFolder,'cifar-10-batches-mat');
if ~exist(dataFolder,'dir')
    fprintf("Downloading CIFAR-10 dataset (175 MB)... ");
    websave(filename,url);
    untar(filename,downloadFolder);
    fprintf("Done.\n")
end

% Cifar10 training and testing sets 
[X_Train,Y_Train,X_Test,Y_Test] = loadCIFARData(downloadFolder);

% Normalize Input
X_Train = single(X_Train)/255;
X_Test = single(X_Test)/255;

% Hyper parameters
learningRate = 0.001;                             % Learning rate for weights + biases updates 
numEpochs = 10;                                   % Number of iterations through data set
hidden_units = 128;                               % Number of neurons in hidden layers
output_features = 10;                             % 10 classes for CIFAR-10
num_layers = 3;                                   % 3 hidden layers

% Initialize weights and biases
weights = cell(1, num_layers);
biases = cell(1, num_layers);

% Layer 1
weights{1} = randn(input_features, hidden_units) * 0.01;
biases{1} = zeros(1, hidden_units);

% Layer 2
weights{2} = randn(hidden_units, hidden_units) * 0.01;
biases{2} = zeros(1, hidden_units);

% Layer 3
weights{3} = randn(hidden_units, output_features) * 0.01;
biases{3} = zeros(1, output_features);

%%%% Feature Extracting Pipeline %%%%
Conv_1 = MATLAB_Conv2d(X_Train);
Out_1 = ReLu(Conv_1);
Pooling_out_1 = Average_Pooling(Out_1);

Conv_2 = MATLAB_Conv2d(Pooling_out_1);
Out_2 = ReLu(Conv_2);
Pooling_out_2 = Average_Pooling(Out_2);

Conv_3 = MATLAB_Conv2d(Pooling_out_2);
Out_3 = ReLu(Conv_3);
Pooling_out_3 = Average_Pooling(Out_3);
%%%%% Feature Learing Complete %%%%%

%%%%%%% Foward/Back Propagation %%%%%%%
for epoch = 1:numEpochs
    fprintf('Epoch %d\n', epoch);

    % Flatten and classify
    flatten_array = Flattening(Pooling_out_3);
    input_features = size(flatten_array,2);

    % Classification output
    class_output = Hidden_Layers(flatten_array,weights,bias);
    loss = Cross_entropy_loss(Y_Train, class_output);
    fprintf('Loss: %.4f\n', loss);

    % Compute gradients of weights
    grad_output = class_output - onehotencode(Y_Train, 2);
    
    % Initialize gradients
    grad_weights = cell(1, num_layers);
    grad_biases = cell(1, num_layers);

    % Layer 3 gradient
    grad_weights{3} = (flatten_array' * grad_output) / size(flatten_array, 1);
    grad_biases{3} = mean(grad_output, 1);
    
    % Layer 2 gradient
    grad_weights{2} = (flatten_array' * grad_output) / size(flatten_array, 1);
    grad_biases{2} = mean(grad_output, 1);

    % Layer 1 gradient
    grad_weights{1} = (flatten_array' * grad_output) / size(flatten_array, 1);
    grad_biases{1} = mean(grad_output, 1);
    
    
    % Update weights and biases
    for n = 1:num_layers
        weights{n} = weights{n} - learningRate * grad_weights{n};
        biases{n} = biases{n} - learningRate * grad_biases{n};
    end
    
    % Calculate accuracy
    [~, predicted_labels] = max(class_probabilities, [], 2);
    accuracy = mean(predicted_labels == (Y_Train + 1));  
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);
end