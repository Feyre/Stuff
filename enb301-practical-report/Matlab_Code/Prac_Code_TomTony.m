%-               ENB301 Practical (ServoMotor)            -%
%-                   Thomas Wagner N8840121               -%
%-                   Antony Foster N8647780               -%
%-                        11 May 2015                     -%

close all;
clear all;
clc;
i=1;
load('ENB301TestData_2015.mat');
y=y1;
closed='scope_10.csv';
open='10.csv';
%--------------------A3------------------------------------%
%Constans
Km=1.33;                        %Moter constaint 
a=1;                            %Alpha
Vm=1;                           %Voltage 

Num=[Km];                    
Dem=[1, a, 0];              

G0=tf(Num,Dem);
y1=step(G0*Vm,t);

%--------A4. Plotting Ideal(y1)and model (y0)--------------%
figure(i);i=i+1;
plot(t,y,t,y1);
title('Modle data Vs Test Data');
ylabel('Amplitude');
xlabel('Time_{sec}');

%-------------A6. PA6. Estimate Km and a-------------------%

func = @(x0)Variable_finder(x0,'ENB301TestData_2015.mat');
calc_y0 = fminsearch(func,[Km,a]);
disp(calc_y0(1))
disp(calc_y1(2))
y2_num =  [calc_y0(1)];
y2_den = [1 calc_y0(2) 0];
G_1 = tf(y2_num,y2_den);
y2= step(G_1*Vm,t);
 
figure(i);i=i+1;
plot(t,y1,t,y2);
title('Estimate response Vs Test Data');
ylabel('Amplitude');
xlabel('Time_{sec}');

% %-------------A7. Adding noise to y2----------------------%
%       figure(i);i=i+1;
% % for sigma=0:0.1:1
% %     noise = sigma*randn(size(y2)); %noise vector
% %     yn=y2+noise;
% %     pause
% %     
% %     plot(t,yn,t,y2);
% %     titlechange=sprintf('Noise level = %0.1f',sigma);
% %     title(titlechange);
% %     ylabel('Amplitude');
% %     xlabel('Time_{sec}');
% % end
%     sigma = 0.2;
%     noise = sigma*randn(size(y2)); %noise vector
%     yn=y2+noise;
%     plot(t,yn,t,y2);
%     titlechange=sprintf('Noise level = %0.1f',sigma);
%     title(titlechange);
%     ylabel('Amplitude');
%     xlabel('Time_{sec}');
% 
% 
% %------------B1. Loading data----------------------------%
% [te,ye] = Data_cutting(closed,2,1);
% [te,ye] = timing_fix(te,ye);
% figure(i);i=i+1;
% plot(te,ye,'k');
% title('Test data plotted');
% ylabel('Amplitude');
% xlabel('Time_{sec}');
% 
% %------------B2 Plotting y2 and Experimental data---------%
% 
% Vm=1;
% y3=step(G_1*Vm,te);
% figure(i);i=i+1;
% plot(te,y3,te,ye);
% title('Test data Vs Calculated Km and Alpha ');
% ylabel('Amplitude');
% xlabel('Time_{sec}');
% 
% %-------------B3 Figure of merit-------------------------%
% y_rms =@(x0)Variable_finder2(x0,'results.csv',te,ye);
% 
% %-------------B4 Recalculated values---------------------%
% 
% params = fminsearch(y_rms,[Km, a]);
% y3_num =  [params(1)];
% y3_den = [1 params(2) 0];
% G_3 = tf(y3_num,y3_den)
% y3= step(G_3*Vm,te);
%  
% figure(i);i=i+1;
% plot(te,y3,te,ye);
% title('Test data Vs ReCalculated Km and Alpha');
% ylabel('Amplitude');
% xlabel('Time_{sec}');
% %%
% %-------------C4. Expected time response------------------%
% vi=0.5;
% Km=y3_num;
% Rf=33E3;
% R1=10E3;
% a=y3_den(2);
% 
% yc_num=[Km*(Rf/R1)];
% yc_dem=[1,a,Km*(Rf/R1)];
% Gc=tf(yc_num,yc_dem)
% 
% figure(i);i=i+1;
% [u,t] = gensig('square',1/0.1,15,0.1);
% u=u/2;
% yc_b=lsim(Gc,u,t);
% 
% 
% perfor_finder(yc_num,yc_dem);
% %---------C5. Resistor values for 5% over shoot-=---------%
% %%
% po=0.05;                                % percenage overshoot
% z=sqrt((log(po)^2)/(pi^2+(log(po)^2))); % finding zeta
% wnn=a/2/z;
% rat=wnn^2/Km
% % res_av=[1,1.2,1.5,1.8,2.2,2.7,3.3,3.9,4.7,5.6,6.8,8.2];
% % res_table=transpose(res_av).^-1*res_av;
% 
% Rf=rat*R1;
% 
% yc_num=[Km*Rf/R1];
% yc_dem=[1,a,Km*Rf/R1];
% Gc_ov=tf(yc_num,yc_dem)
% figure(i);i=i+1;
% [u,t] = gensig('square',10,15,0.1);
% u=u/2;
% lsim(Gc_ov,u,t);
% title('Theoretical 5% Overshoot ');
% perfor_finder(yc_num,yc_dem);
% % figure(i);i=i+1;
% % plot(t,u,t,yc_b,'--',t,yc_ov,'-- k','LineWidth',1.1);
% 
% %%
% %---------------C6. Importing Data---------------------%
% 
% [tc,ycp,wave] = Data_cutting (open,7,2);
% figure(i);i=i+1;
% plot(tc,ycp,tc,wave);
% title('Calculated and test responce to a Square wave input');
% ylabel('Amplitude');
% xlabel('Time_{sec}');
% 
% %-----------------C7. Compare Data---------------------%
% 
% 
% 
