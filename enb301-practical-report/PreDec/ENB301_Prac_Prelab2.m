%% ENB301_Prac_Prelab2.m
% Toy Servo System Response
% Use is to model a servo motor output to find alpha and km variables
% Written by D Gilmour n8871566

clc
clear all
close all
%% A3 - Simulate motor shaft angle for values of km and alpha
alpha = 1;
km = 1;
t = linspace(0,10,100);

% Build transfer function
G = tf(km, [1 alpha 0]);    % Set G(s) = km / (s + a)  
G_0 = step(G,t);    % Set G_0(s) = km / (s * (s + a))

% Plot motor set response
figure
plot(t,G_0,'r')
title('Simulated Step Response')
xlabel('t (sec)')
ylabel('Amplitude')
print('-depsc','A3')
close

%% A4 - Plot motor unit step response data against simulated response
load ENB301TestData_2015.mat
alpha = 1;
km=1;
G = tf(km,[1 alpha 0]); 
G_0 = step(G,t);

figure
hold on
plot(t,y1,'b')
plot(t,G_0,'r')
title('Simulated Step Response and Test Data')
xlabel('t (sec)')
ylabel('Amplitude')
legend('y1(t): Simulated Step Response','Test Data')
hold off
print('-depsc','A4')
close

%% A5 - What is the steady state and steady state response predominantly determined by?


%% A6 - Estimate km and alpha variables
load ENB301TestData_2015
output = zeros(3,100*100);
error = 0;
ii = 1;
for km = linspace(0,4,100)
   for alpha = linspace(0,4,100)
       G = tf(km, [1 alpha 0]);
       G_0 = step(G,t);
       
       % Calculate mean square error
       for jj = 1 : length(t)
          error = error + (G_0(jj) - y1(jj))^2;
       end
       
       output(:,ii) = [km;alpha;error];
       ii = ii + 1;
       error = 0;
   end
end

[~,index] = min(output(3,:));
km = output(1,index); % Output variable
alpha = output(2,index);  % Output variable

% Build transfer function
G = tf(km, [1 alpha 0]);    % Set optimal G(s) = km / (s + a)   
G_0 = step(G,t);    % Set optimal G_0(s) = km / (s * (s + a))

% Plot step function G_0(s)
figure
hold on
plot(t,G_0,'-b');
plot(t,y1,'-r');
title('Estimated Step Response of Test Data')
xlabel('t (sec)')
ylabel('Amplitude')
legend('Estimated Step Response', 'Test Data');
hold off;
print('-depsc','A6')
close

% Output km and alpha
disp(km)    %2.3838
disp(alpha) %1.8990

%% A7 - Add noise to G_0
%load ENB301TestData_2015
% Generate noise
% Standard: sigma = 5, Decreased: signma = 0.2, Increased: sigma = 20
sigma = 5; %noise standard deviation
noise = sigma*randn(size(G_0)); %noise vector

% Create noisy signal
yn = y1 + noise;

output = zeros(3,100*100);
error = 0;
ii = 1;
for km = linspace(0,4,100)
   for alpha = linspace(0,4,100)
       G = tf(km, [1 alpha 0]);
       G_0 = step(G,t);
       
       % Calculate mean square error
       for jj = 1 : length(t)
          error = error + (G_0(jj) - yn(jj))^2;
       end
       
       output(:,ii) = [km;alpha;error];
       ii = ii + 1;
       error = 0;
   end
end

[~,index] = min(output(3,:));
km = output(1,index); % Output variable
alpha = output(2,index);  % Output variable

% Build transfer function
G_noisy = tf(km, [1 alpha 0]);    % Set optimal G(s) = km / (s + a)   
G_0_noisy = step(G_noisy,t);    % Set optimal G_0(s) = km / (s * (s + a))

% Output km and alpha
disp(km)    %2.4242
disp(alpha) %1.9394

% Plot noisy signal vs noisy test data
figure(2)
hold on
plot(t,G_0_noisy, '-r');
plot(t,G_0,'-b');
title('Estimated Step Response of Noisy Test Data')
xlabel('t (sec)')
ylabel('Amplitude')
legend('Noisy Step Response', 'Original Step Response');
hold off
print('-depsc','A7')
close
