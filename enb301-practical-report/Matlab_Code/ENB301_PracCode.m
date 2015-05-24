%% ENB301_PracCode.m
% Written by D Gilmour n8871566

clc
clear all
close all

%% B1 - Load experimental data and plot
% Plot in black
data = csvread('PartB_Test1.csv',2,0);
te_1 = data(1:end,1);
te_1 = te_1 + abs(te_1(1));
ye_1 = data(1:end,2);
%ye_1step = medfilt1(data(1:end,3),50);
ye_1step = data(1:end,3);

data = csvread('PartB_Test2.csv',2,0);
te_2 = data(1:end,1);
te_2 = te_2 + abs(te_2(1));
ye_2 = data(1:end,2);
ye_2step = data(1:end,3);

data = csvread('PartB_Test3.csv',2,0);
te_3 = data(1:end,1);
te_3 = te_3 + abs(te_3(1));
ye_3 = data(1:end,2);
ye_3step = data(1:end,3);

figure
plot(te_1,ye_1,'k',medfilt1(te_1,50),medfilt1(ye_1step,50),'b')
title('Experimental Data Plot [Set 1]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B1_dataset1'));
close

figure
plot(te_2,medfilt1(ye_2,50),'k',te_2,medfilt1(ye_2step,50),'b')
title('Experimental Data Plot [Set 2]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B1_dataset2'));
close

figure
plot(te_3,medfilt1(ye_3,50),'k',te_3,medfilt1(ye_3step,50),'b')
title('Experimental Data Plot [Set 3]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B1_dataset3'));
close

%% B3 
% B3 - Derive single figure of merit: Used both Mean Square figure of merit
% and Root Mean Square figure of Merit
% Mean square error calculation:
% error_ms = error_ms + (G_0(jj) - ye(jj))^2;

% Root mean square error calculation:
% error_rms = error_rms + rms(G_0(jj) - ye(jj));

%% B4
% Improve Estimates using plots and figure of merit. Could use filters
% to improve quality of estimate. Could use medfilt1() in actual vector calculations.
mf1 = 50;   % medfilt1 averaging weighting

% Plot experimental data ye against systems estimated tf y1
[te_1new,ye_1new] = timing_fix(te_1,ye_1);
[te_2new,ye_2new] = timing_fix(te_2,ye_2);
[te_3new, ye_3new] = timing_fix(te_3,ye_3);

figure
plot(te_1new,ye_1new,'k')
title('Experimental Data Plot [Set 1 Adjusted]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B2_dataset1'));
close

figure
plot(te_2new,ye_2new,'k')
title('Experimental Data Plot [Set 2 Adjusted]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B2_dataset2'));
close

figure
plot(te_3new,ye_3new,'k')
title('Experimental Data Plot [Set 2 Adjusted]')
xlabel('te (sec)')
ylabel('ye (voltage)')
print('-depsc',strcat('figures',filesep,'B2_dataset3'));
close

[te_1trim, ye_1trim] = trimForCalculation(te_1new,ye_1new,mf1);
[te_2trim, ye_2trim] = trimForCalculation(te_2new,ye_2new,mf1);
[te_3trim, ye_3trim] = trimForCalculation(te_3new,ye_3new,mf1);

km_num = 500;    % number of km values used
km_max = 500;   % max km value used
alpha_num = 500;    % number of alpha values used
alpha_max = 500;    % max alpha value used

% Preallocate size for speed
output_ms = zeros(3,km_num*alpha_num);
output_rms = zeros(3,km_num*alpha_num);
km_ms = zeros(1,3);
alpha_ms = zeros(1,3);
km_rms = zeros(1,3);
alpha_rms = zeros(1,3);
        
for iteration = 1 : 3
    
    % Set te and ye based on iteration
    if (iteration == 1)        
        te = te_1trim;
        ye = ye_1trim;
    elseif (iteration == 2)
        te = te_2trim;
        ye = ye_2trim;
    else
        te = te_3trim;
        ye = ye_3trim;
    end      
    
    % Set cycle variables
    error_ms = 0;
    error_rms = 0;
    ii = 1;
    count = 0;
    
    for km = linspace(0,km_max,km_num)   % Cycle km values
       for alpha = linspace(0,alpha_max,alpha_num)  % Cycle alpha values
           G = tf(km, [1 alpha 0]);
           G_0 = step(G,te);

           % Calculate error
           for jj = 1 : length(te)
              % Calculate mean square error
              error_ms = error_ms + (G_0(jj) - ye(jj))^2;
              
              % Calculate root mean square error
              error_rms = error_rms + rms(G_0(jj) - ye(jj));
           end
           
           % Store km, alpha and the error taken to calculate
           output_ms(:,ii) = [km;alpha;error_ms];
           output_rms(:,ii) = [km;alpha;error_rms];
           
           % Reset cycle variables
           ii = ii + 1;
           error_ms = 0;
           error_rms = 0;
       end
       
       % Output km iterations
       %count = count + 1;       
       %fprintf('%d %s %d\n',count,'/',km_num);
    end

    % Calculate km and alpha values for mean square error calculation
    [~,index] = min(output_ms(3,:));
    km_ms(iteration) = output_ms(1,index); % Output variable
    alpha_ms(iteration) = output_ms(2,index);  % Output variable

    % Calculate km and alpha values for root mean square error calculation
    [~,index] = min(output_rms(3,:));
    km_rms(iteration) = output_rms(1,index); % Output variable
    alpha_rms(iteration) = output_rms(2,index);  % Output variable    
end
km_mean = (mean(km_ms) + mean(km_rms)) / 2;
alpha_mean = (mean(alpha_ms) + mean(alpha_rms)) / 2;

% Write km and alpha values to file
fileID = fopen('y1.txt','w');
fprintf(fileID,'%s\n\n','Results from calculating km and alpha');
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','km_ms:',km_ms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','km_rms:',km_rms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','alpha_ms:',alpha_ms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','alpha_rms',alpha_rms);
fprintf(fileID,'%s %6.4f\n','km_mean:',km_mean);
fprintf(fileID,'%s %6.4f\n','alpha_mean',alpha_mean);
fclose(fileID);

% Display km and alpha values
fprintf('%s\n','km_ms:')
disp(km_ms);
fprintf('%s\n','alpha_ms:')
disp(alpha_ms);
fprintf('%s\n','km_rms:')
disp(km_rms);
fprintf('%s\n','alpha_rms:')
disp(alpha_rms);
fprintf('%s\n', 'km:')
disp(km_mean);
fprintf('%s\n', 'alpha:')
disp(alpha_mean);

% Plot y1 against ye
% Data Set 1
G = tf(km_ms(1), [1 alpha_ms(1) 0]); 
y1_ms = step(G,te_1new);
figure
plot(te_1new,medfilt1(ye_1new,1),'k',te_1new,medfilt1(y1_ms,1),'b')
title('Experimental vs estimated TF [Set 1 Adjusted, mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset1_ms'));
close

G = tf(km_rms(1), [1 alpha_rms(1) 0]); 
y1_rms = step(G,te_1new);
figure
plot(te_1new,ye_1new,'k',te_1new,y1_rms,'b')
title('Experimental vs estimated TF [Set 1 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset1_rms'));
close

% Data Set 2
G = tf(km_ms(2), [1 alpha_ms(2) 0]);
y1_ms = step(G,te_2new);
figure
plot(te_2new,ye_2new,'k',te_2new,y1_ms,'b')
title('Experimental vs estimated TF [Set 2 Adjusted, mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset2_ms'));
close

G = tf(km_rms(2), [1 alpha_rms(2) 0]); 
y1_rms = step(G,te_2new);
figure
plot(te_2new,ye_2new,'k',te_2new, y1_rms,'b')
title('Experimental vs estimated TF [Set 2 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset2_rms'));
close

% Data Set 3
G = tf(km_ms(3), [1 alpha_ms(3) 0]); 
y1_ms = step(G,te_3new);
figure
plot(te_3new,ye_3new,'k',te_3new,y1_ms,'b')
title('Experimental vs estimated TF [Set 3 Adjusted, mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset3_ms'));
close

G = tf(km_rms(3), [1 alpha_rms(3) 0]); 
y1_rms = step(G,te_3new);
figure
plot(te_3new,ye_3new,'k',te_3new,y1_rms,'b')
title('Experimental vs estimated TF [Set 3 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y1_dataset3_rms'));
close

save('partb_Variables.mat')
%{
km_length = 500; alpha_length = 500
km_max = 500; alpha_max = 500
km_ms:
  289.5792  496.9940  495.9920

alpha_ms:
  118.2365  201.4028  198.3968

km_rms:
  265.5311  500.0000  483.9679

alpha_rms:
  108.2164  202.4048  193.3868
%}



%% B5
%clear
%load('partb_MatlabOutput')
%alpha_mean = 170.3407;

% Use second order model and alpha to calculate km and beta.
% Experimental time and voltage vectors

km_num = 500;    % number of km values used
km_max = 500;   % max km value used
beta_num = 50;    % number of alpha values used
beta_max = 1;    % max alpha value used

% Preallocate size for speed
output_ms = zeros(3,km_num*beta_num);
output_rms = zeros(3,km_num*beta_num);
km2_ms = zeros(1,3);
beta_ms = zeros(1,3);
km2_rms = zeros(1,3);
beta_rms = zeros(1,3);
    
for iteration = 1:3
    if(iteration == 1)
        te = te_1trim;
        ye = ye_1trim;
    elseif(iteration==2)
        te = te_2trim;
        ye = ye_2trim;
    else
        te = te_3trim;
        ye = ye_3trim;
    end
    
    % Set cycle variables
    error_ms = 0;
    error_rms = 0;
    ii = 1;
    count = 0;
    
    for km = linspace(0,km_max,km_num)   % Cycle km values
       for beta = linspace(0,beta_max,beta_num)  % Cycle alpha values
           G = tf(km, [1 (alpha_mean+beta) (alpha_mean*beta)]);
           G_0 = step(G,te);

           % Calculate error
           for jj = 1 : length(te)
              % Calculate mean square error
              error_ms = error_ms + (G_0(jj) - ye(jj))^2;

              % Calculate root mean square error
              error_rms = error_rms + rms(G_0(jj) - ye(jj));
           end

           % Store km, alpha and the error taken to calculate
           output_ms(:,ii) = [km;beta;error_ms];
           output_rms(:,ii) = [km;beta;error_rms];

           % Reset cycle variables
           ii = ii + 1;
           error_ms = 0;
           error_rms = 0;
       end

        % Output km iterations
       %count = count + 1;       
       %fprintf('%d %s %d\n',count,'/',km_num);
    end

    % Calculate km and alpha values for mean square error calculation
    [~,index] = min(output_ms(3,:));
    km2_ms(iteration) = output_ms(1,index); % Output variable
    beta_ms(iteration) = output_ms(2,index);  % Output variable

    % Calculate km and alpha values for root mean square error calculation
    [~,index] = min(output_rms(3,:));
    km2_rms(iteration) = output_rms(1,index); % Output variable
    beta_rms(iteration) = output_rms(2,index);  % Output variable 
end

km_mean2 = (mean(km_ms) + mean(km2_rms)) / 2;
beta_mean = (mean(beta_ms) + mean(beta_rms)) / 2;
    
% Display km and beta values
fprintf('%s\n','km_ms:')
disp(km2_ms);
fprintf('%s\n','beta_ms:')
disp(beta_ms);
fprintf('%s\n','km_rms:')
disp(km2_rms);
fprintf('%s\n','beta_rms:')
disp(beta_rms);
fprintf('%s\n', 'km:')
disp(km_mean2);
fprintf('%s\n', 'beta:')
disp(beta_mean);

% Write km and beta values to file
fileID = fopen('y2.txt','w');
fprintf(fileID,'%s\n\n','Results from calculating km and beta with set alpha value.');
fprintf(fileID,'%s %6.4f\n','Precalculated alpha:',alpha_mean);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','km_ms:',km2_ms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','km_rms:',km2_rms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','beta_ms:',beta_ms);
fprintf(fileID,'%s %6.4f %6.4f %6.4f\n','beta_rms',beta_rms);
fprintf(fileID,'%s %6.4f\n','km_mean:',km_mean2);
fprintf(fileID,'%s %6.4f\n','beta_mean',beta_mean);
fclose(fileID);

% Plot response
% G = tf(km_mean2, [1 (alpha+beta_mean) (alpha*beta_mean)]);
% y2 = step(G,te_1new);
% figure
% plot(te_1new,ye_1new,'k',te_1new,y2,'b')
% title('Experimental vs estimated TF [Set 1 Adjusted]')
% xlabel('te (sec)')
% ylabel('y (voltage)')
% legend('ye','y1')
% print('-depsc',strcat('figures',filesep,'y2_dataset1'));
% close

% Plot y2 against ye
% Data Set 1
G = tf(km2_ms(1), [1 (alpha_mean+beta_ms(1)) (alpha_mean*beta_ms(1))]);
y2_ms = step(G,te_1new);
figure
plot(te_1new,medfilt1(ye_1new,1),'k',te_1new,medfilt1(y2_ms,1),'b')
title('Experimental vs estimated TF [Set 1 Adjusted, mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset1_ms'));
close

G = tf(km2_ms(1), [1 (alpha_mean+beta_ms(1)) (alpha_mean*beta_ms(1))]);
y2_rms = step(G,te_1new);
figure
plot(te_1new,ye_1new,'k',te_1new,y2_rms,'b')
title('Experimental vs estimated TF [Set 1 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset1_rms'));
close

% Data Set 2
G = tf(km2_ms(2), [1 (alpha_mean+beta_ms(2)) (alpha_mean*beta_ms(2))]);
y2_ms = step(G,te_2new);
figure
plot(te_2new,medfilt1(ye_2new,1),'k',te_2new,medfilt1(y2_ms,1),'b')
title('Experimental vs estimated TF [Set 3 Adjusted, mean square error]')
xlabel('te (sec)') 
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset2_ms'));
close

G = tf(km2_ms(2), [1 (alpha_mean+beta_ms(2)) (alpha_mean*beta_ms(2))]);
y2_rms = step(G,te_2new);
figure
plot(te_2new,ye_2new,'k',te_2new,y2_rms,'b')
title('Experimental vs estimated TF [Set 3 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset2_rms'));
close

% Data Set 3
G = tf(km2_ms(3), [1 (alpha_mean+beta_ms(3)) (alpha_mean*beta_ms(3))]);
y2_ms = step(G,te_3new);
figure
plot(te_3new,medfilt1(ye_3new,1),'k',te_3new,medfilt1(y2_ms,1),'b')
title('Experimental vs estimated TF [Set 3 Adjusted, mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset3_ms'));
close

G = tf(km2_ms(3), [1 (alpha_mean+beta_ms(3)) (alpha_mean*beta_ms(3))]);
y2_rms = step(G,te_3new);
figure
plot(te_3new,ye_3new,'k',te_3new,y2_rms,'b')
title('Experimental vs estimated TF [Set 3 Adjusted, root mean square error]')
xlabel('te (sec)')
ylabel('y (voltage)')
legend('ye','y1')
print('-depsc',strcat('figures',filesep,'y2_dataset3_rms'));
close


%% C4
%Calculate expected time response
Rf = 33 * 10^3;
R1 = 10 * 10^3;
alpha = 38.61;
Km = 326;
K = Rf / R1;
G_c = tf(K * Km, [1 alpha K * Km]);
Y_c = tf(K * Km, [1 alpha K * Km 0]);

[num, den] = tfdata(Y_c,'v');
%r = gain, p = pole, k = direct term ie r / (s + p) + k
[r, p, k] = residue(num,den);

x = tf(r(1),[1 p(1)]);
y = tf(r(2),[1 p(2)]);
z = tf(r(3),[1 p(3)]);
partialFrac = [x y z];

%% C5 - Calculate theretical gain required for 5% overshoot. Determine requried resistors.

%% C6
% Import experimental data into matla. Compare closed loop response with
% prediced model Y_c. What does this suggest about model derived in part B?
data = csvread('PartB_Test1.csv',2,0);  % Read in test 1
te_1 = data(1:end,1);   % Store te variable
te_1 = te_1 + abs(te_1(1)); % Move te variable to start at zero
ye_1 = data(1:end,2);   % Store ye variable
ye_1step = data(1:end,3);   % Store ye step input variable



%% D
%[mag,phase] = bode( G, imag(jw) )
%http://stackoverflow.com/questions/22837372/how-to-replace-the-laplace-variable-in-a-transfer-function-with-a-number-value
