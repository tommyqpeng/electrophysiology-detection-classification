%% Tommy Peng's auto-covariance function
% Since auto-covariance only requires one input matrix, there is only one
% input (must be 1 by x matrix).
% The outputMatrix is the matrix of auto-covariance values.
% The lagMatrix is a tool to plot the outputMatrix with
% (plot(lagMatrix,outputMatrix)).

function [lagMatrix, outputMatrix] = autocov_TP(inputMatrix)
    %% From definition of values found in 2.36
    xbar = mean2(inputMatrix);
    n0 = length(inputMatrix)+1;
    
    %% Starting loop variables
    partialsum = 0;
    outputMatrix = zeros(1,2*length(inputMatrix));
    counter = 0;
    
    %% Creates a nested loop to perform auto-covariance calc
    for lag = -length(inputMatrix):1:length(inputMatrix)
        for index = 1:1:length(inputMatrix)
            if (index + lag > 0 && index + lag < length(inputMatrix))
            partialsum = partialsum + ((inputMatrix(index+lag)-xbar)*(inputMatrix(index)-xbar));
            end
        end
        counter = counter + 1;
        outputMatrix(counter) = partialsum;
        partialsum = 0;
    end
    
    outputMatrix = (1/n0)*outputMatrix;
    lagMatrix = -length(inputMatrix)-1:length(inputMatrix)-1;
    
end