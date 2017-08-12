function [coeffs, stats, curve, threshold] = FitPsycheCurveLogit(xAxis, yData, fit, targets, weights)
    % Bethany Hung 2016
    % adapted from http://matlaboratory.blogspot.co.uk/2015/04/introduction-to-psychometric-curves-and.html
    % FitPsycheCurveLogit(xAxis, yData, weights, targets, fit)
    
    % set defaults        
    if nargin<4
        targets = 0.5;
    else
    end
    
    if nargin<5
        if any(yData > 1) == 1 % inputs are percents from 0 - 100
            weights = ones(1,length(xAxis)).*100;
        else
            weights = ones(1,length(xAxis)); 
        end
    else
    end
    
    % Transpose if necessary
    if size(xAxis,1)<size(xAxis,2)
        xAxis=xAxis';
    end
    if size(yData,1)<size(yData,2)
        yData=yData';
    end
    if size(weights,1)<size(weights,2)
        weights=weights';
    end

    % Perform fit

    [coeffs, ~, stats] = ...
        glmfit(xAxis, [yData, weights], 'binomial', 'link', fit);

    % Create a new xAxis with higher resolution
    fineX = linspace(min(xAxis),max(xAxis),numel(xAxis)*50);
    % Generate curve from fit
    curve = glmval(coeffs, fineX, fit);

    
    if max(weights)<=1
        % Assume yData was proportional
        curve = [fineX', curve];
    else
        % Assume yData was % or actual number of trials
        curve = [fineX', curve*100];
    end

    % Calculate
    threshold = (log(targets./(1-targets))-coeffs(1))/coeffs(2);
end