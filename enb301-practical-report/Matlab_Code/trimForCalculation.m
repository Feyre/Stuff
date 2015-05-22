%UNTITLED Summary of this function goes here
%   Return a portion of the motor response gradient
% Written by D Gilmour n8871566
function [ te_new,ye_new ] = trimForCalculation(te,ye, mf1)
   indice = round(length(te) / 4);
   
   % Output vectors between 1/4 and 3/4 of inputed vectors
   te_new = te(indice:indice*2);
   ye_new = ye(indice:indice*2);
   
   % Smooth vectors using filtering
   medfilt1(te_new,mf1);
   medfilt1(ye_new,mf1);
   
end