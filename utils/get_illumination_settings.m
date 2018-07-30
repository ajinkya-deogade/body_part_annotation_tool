%% Input Files
close all;
clear all;
clc;
tic;

initFolder = 'G:\MHDO_Tracking\data\Janelia_Q1_2017';
[filename_mp4, pathname_mp4, ext_mp4] = uigetfile('*.mp4','Select the video file to extract frames.',initFolder);
[path, name, ext_mp4] = fileparts(filename_mp4);

%% Getr the Average Pixel Gray Values
vid_reader = VideoReader(strcat(pathname_mp4, filename_mp4));
start_loc = [1700, 1700; 100, 100; 100, 1700; 1700, 100];
boxSize = 16;
tic
vid_frame_original = rgb2gray(read(vid_reader, 750));
toc
for i = 1:size(start_loc, 1)
    crop_x = max(1, start_loc(i, 1)-(boxSize/2));
    crop_y = max(1, start_loc(i, 2)-(boxSize/2));
    vid_frame = vid_frame_original(crop_y:crop_y+boxSize, crop_x:crop_x+boxSize);
    averageGreyScale(i, 1) = mean(vid_frame(:));
end