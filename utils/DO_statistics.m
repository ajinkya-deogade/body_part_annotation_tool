%% Input Files
close all;
clear all;
clc;
tic;
[filename_txt, pathname_txt] = uigetfile('*.txt','Select the file with co-ordinates of Point of Interest')
%% Initialize Variables
coordinate = dlmread(strcat(pathname_txt,filename_txt),'\t');
DONotFound = 0;
j =1;
l = length(coordinate);
k = l/3
do = ones(1,k);
%% Mark the annotation on each frame
for i = 1:3:length(coordinate(:,1))
    if coordinate(i,1) <= 0 | coordinate(i+1,1) <= 0 | coordinate(i+2,1) <= 0
        DONotFound = DONotFound + 1;
        do(j) = 0;
    end
    j = j+1;
end
percentageDO_found = (j - DONotFound)*100/j
fourDO = fft(do);
plot(do);
% close all;
% clear all;