function [answer] = checkResp2(c,curResp)
    
    if c == 1 || c == 2 || c == 3 
        if curResp == 5
            answer = true;
        else
            answer = false;
        end
    elseif c == 4 || c == 5 || c == 6
        if curResp == 4
            answer = true;
        else
            answer = false;
        end
    elseif c == 7 || c == 8 || c == 9
        if curResp == 1
            answer = true;
        else
            answer = false;
        end
    elseif c == 10 || c == 11 || c == 12
        if curResp == 2
            answer = true;
        else
            answer = false;
        end
    end
end