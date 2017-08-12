function [fitresultAx, fitresultDir] = AFCpsychometric(shifts,avgCorrectAxis,avgCorrectDir)

    ft_25 = fittype( '0.25+(1-0.25-l)./(1+exp(-(x-alpha)/beta))', 'independent', 'x', 'dependent', 'y' );
    opts_25 = fitoptions( ft_25 );    
    opts_25.Display = 'Off';    
    opts_25.Lower = [-Inf -Inf -Inf];
    opts_25.Upper = [Inf Inf Inf];
    opts_25.StartPoint = [0 0.5 0.5];    

    ft_50 = fittype( '0.50+(1-0.50-l)./(1+exp(-(x-alpha)/beta))', 'independent', 'x', 'dependent', 'y' );
    opts_50 = fitoptions( ft_50 );    
    opts_50.Display = 'Off';    
    opts_50.Lower = [-Inf -Inf -Inf];
    opts_50.Upper = [Inf Inf Inf];
    opts_50.StartPoint = [0 0.5 0.5]; 

    xData = shifts';
    yDataAx = flip(avgCorrectAxis');
    yDataDir = flip(avgCorrectDir');
    [fitresultAx, ~] = fit( xData, yDataAx, ft_50, opts_50 );
    [fitresultDir, ~] = fit( xData, yDataDir, ft_25, opts_25 );

end

