function output = shadedEB(dSet,SEM,color,x1,x2)

% Takes the x and y data values and fills the space between with a
% translucent color.

% in:   dSet:   Double array containing all timepoints for all relevant
%               channels.
%       SEM:    Calculated SEM for dataset.
%       color:  1x3 double array. Desired color for fill in [R,G,B] format.
%       x1:     Optional. Array of x-values of dataset 1. If not input, function will create a vector of length N for dataset 1.
%       x2:     Optional. Array of x-values of dataset 1. If not input, function will create a vector of length N for dataset 2.

% out:  A plot with the shaded area.          
    
    y1 = dSet + SEM;
    y2 = dSet - SEM;
    
    if size(y1,1) > size(y1,2)
        y1 = y1';
    end

    if size(y2,1) > size(y2,2)
        y2 = y2';
    end
    
    if y1(1) < y2(1)
        ya = y2;
        yb = y1;
    else
        ya = y1;
        yb = y2;
    end
    
    if nargin < 4
        x1 = [1:length(ya)];
        x2 = [1:length(yb)];
    end

    x = [x1 fliplr(x2)];

    y = [ya fliplr(yb)];
    h = fill(x,y,color);
    set(h, 'FaceAlpha', 0.75, 'EdgeAlpha', 0);

end