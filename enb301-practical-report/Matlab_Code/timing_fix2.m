function [ te_new,ye_new ] = timing_fix2(te,ye)
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