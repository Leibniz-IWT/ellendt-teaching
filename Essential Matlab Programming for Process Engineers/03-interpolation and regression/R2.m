function Rsq = R2(y,yfit)
% R2 - calculates R^2 value of fit
SStot = sum((y-mean(y)).^2);                 
SSres = sum((y-yfit).^2);            
Rsq = 1-SSres/SStot;    
end

