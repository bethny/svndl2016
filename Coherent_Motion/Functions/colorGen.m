function [colors] = colorGen(num)
%   Description:    Generates a list of custom colors, currently capped at
%                   9. Please add more colors as fit.
%   Syntax:         [colors] = colorGen(num)
%   In:
%       num:    List of colors you want to generate. 
%   Out:
%       colors: List of colors, in RGB values. 

red = [229/255,66/255,66/255];
turq = [35/255,169/255,181/255];
gold = [255/255,216/255,80/255];
orange = [255 136 56]/255;
purple = [186/255,122/255,246/255];
green = [52 191 85]/255;
pink = [255,56,145]/255;
grey = [150,150,150]/255;
black = [0,0,0];

colorList = {red,orange,gold,green,turq,purple,pink,grey,black};
colors = colorList(1:num);

end