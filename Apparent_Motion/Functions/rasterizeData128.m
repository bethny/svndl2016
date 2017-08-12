function [RGBMat] = rasterizeData128(rawDataBTN_all2)
% Takes EEG data and converts it into RGB values for raster plots
    
    for i = 1:size(rawDataBTN_all2,3)
        indivMat(i) = {squeeze(rawDataBTN_all2(:,:,i))'};
    end

    for s = 1:size(rawDataBTN_all2,3)
        for i = 1:size(rawDataBTN_all2,2)
            for j = 1:size(rawDataBTN_all2,1)
                if indivMat{s}(i,j) < -0.3e4 % negatives, red
                    RGBMat(i,j,1,s) = 236/255;
                    RGBMat(i,j,2,s) = 74/255;
                    RGBMat(i,j,3,s) = 74/255;
                elseif indivMat{s}(i,j) > -0.3e4 && indivMat{s}(i,j) < 0.3e4 % zeros, orange
                    RGBMat(i,j,1,s) = 249/255;
                    RGBMat(i,j,2,s) = 216/255;
                    RGBMat(i,j,3,s) = 127/255;
                else
                    RGBMat(i,j,1,s) = 123/255;
                    RGBMat(i,j,2,s) = 212/255;
                    RGBMat(i,j,3,s) = 220/255; % positives, blue
                end
            end
        end
    end

end