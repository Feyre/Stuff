%% ENB301_Prac_Prelab2.m
% Toy Servo System Response
% This code is for A3, A4, A6 and A7
% Use is to model a servo motor output to find alpha and km variables
% Written by D Gilmour n8871566

clc
clear all
close all

%load scope_0

%% A3 - Simulate motor shaft angle for values of km and alpha

%% A4 - Plot Ideal y1 and model y0

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

[~,ind] = min(output(3,:));
km = output(1,ind); % Output variable
alpha = output(2,ind);  % Output variable

% Build transfer function
G = tf(km, [1 alpha 0]);    % Set optimal G(s) = km / (s + a)   
G_0 = step(G,t);    % Set optimal G_0(s) = km / (s * (s + a))

% Plot step function G_0(s)
figure(1)
hold on
plot(t,G_0,'-b');
plot(t,y1,'-r');
legend('Transfer Function', 'Test Data');
hold off;

% Output km and alpha
km
alpha

%% A7 - Add noise to G_0
% Generate noise
sigma = 0.2; %noise standard deviation of noise
noise = sigma*randn(size(G_0)); %noise vector

% Create noisy signal
G_0_noise = G_0 + noise;

% Plot noisy signal vs test data
figure(2)
hold on
plot(t,G_0_noise, '-b');
plot(t,y1,'-r');
legend('Noisy Transfer Function', 'Test Data');
hold off

%% B1 - Load collected data

%% B2 - Plot experimental data and y1

%% B3 - Figure of merit

%% B4 - 

%% B5 - 

%% C4 - Calculate expected time response

%% C5 - Calculate theretical gain required for 5% overshoot. Determine requried resistors.
