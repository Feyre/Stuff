function [ te_new,ye_new ] = timing_fix(te,ye)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Written by D Gilmour n8871566

clear te_cpy g te_new
te_cpy=te;
g=0;
ye_cpy=ye;
for i=1:(length(te_cpy)-1)
    if ((round(abs((te_cpy(i)-te_cpy(i+1))),3))==0.001)
        te_new(i+g)=te_cpy(i);
        ye_new(i+g)=ye_cpy(i);
    else
        i;
        te_new(i+g)=te_cpy(i);
        ye_new(i+g)=ye_cpy(i);
        te_new(i+g+1)=te_cpy(i)+0.001;
        ye_new(i+g+1)=(ye_cpy(i)+ye_cpy(i+1))/2;
        g=g+1;
    end
end

te_new(i+g+1)=te_cpy(end);
ye_new(i+g+1)=ye_cpy(end);
te_new=transpose(te_new);
ye_new=transpose(ye_new);

% Remove initial zero gradient before resonse
f = ye_new > ye_new(1) * 1.05;
indice = find(f,1,'first');
ye_new = ye_new(indice:end);
te_new = te_new(indice:end);

% Shift time to start at zero
te_new = te_new - te_new(1);

% Shift amplitude to start at zero
ye_new = ye_new - ye_new(1);

% Look for max
indice = find(ye_new == max(ye_new));
indice = round(indice * 0.85);
ye_new = ye_new(1:indice);
te_new = te_new(1:indice);


% Find when step input occurs. Look for point 5% larger than start
% Calculate average in that time for the motor response
% Chop off this time in motor response

end

