function [colorbarLimits] = genColorbar(x1,x2)

    mins = [min(x1),min(x2)];
    grandMin = min(mins);
    maxes = [max(x1),max(x2)];
    grandMax = max(maxes);

    colorbarLimits = [grandMin,grandMax];
    newExtreme = max(abs(colorbarLimits));
    colorbarLimits = [-newExtreme, newExtreme];

end