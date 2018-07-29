%% Input Files
close all;
clear all;
clc;
tic;

% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q2_2015\20150501_MPEG4_NoOdor\Clips';
initFolder = 'G:\MHDO_Tracking\data\Janelia_Q1_2017';
% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q2_2015\20150501_MPEG4_EthylButyrate';
[filename_mp4, pathname_mp4, ext_mp4] = uigetfile('*.mp4','Select the video file to extract frames.',initFolder);
[path, name, ext_mp4] = fileparts(filename_mp4);
experimentName = 'Annotations_And_Frames';
experimentFolder = fullfile(pathname_mp4, experimentName);
if exist(experimentFolder) ~= 7
    mkdir(experimentFolder);
end

formatOut = 'yyyy/mm/dd HH:MM:SS';
dat = datestr(clock,formatOut);
dateName =  strrep(strrep(strrep(dat,'/',''),':',''),' ','_');
frameFolder = fullfile(experimentFolder, strcat(name, '_Frames_', dateName));
mkdir(frameFolder);
pathname_tiff = frameFolder;
prompt= 'Annotate every nth term, enter n: ';
iter = input(prompt);
expression = '\\MHDO_Tracking';

%% Read MetaData File
pathname_metadata = dir(strcat(pathname_mp4, 'Metadata_*.txt'));
pathname_metadata = fullfile(pathname_mp4, pathname_metadata.name);
metadata = dlmread(pathname_metadata, ',', 1, 0);
headPosition = metadata(:, 9:10);

%% Initialize Variables
ext_tiff = '.tiff';
filename_tiff = fullfile(pathname_tiff,[name ext_tiff]);
vid_reader = VideoReader(strcat(pathname_mp4, filename_mp4));
lastFrame = read(vid_reader, inf);
total_number_of_frames = vid_reader.NumberOfFrames
parse_number_of_frames = total_number_of_frames
j = 1;

frameName = 'NotAvailable';
videoName = fullfile(pathname_mp4, filename_mp4);
splitVideoName = regexp(videoName,expression,'split');
videoName = splitVideoName{2};
videoName = strrep(videoName,'\','/');

splitFrameFolder = regexp(frameFolder,expression,'split')
frameFolder = splitFrameFolder{2};
frameFolder = strrep(frameFolder,'\','/')

value = struct('x_coordinate',[],'y_coordinate',[]);
nameOptions = {'MouthHook'; 'LeftMHhook'; 'RightMHhook'; 'LeftDorsalOrgan'; 'RightDorsalOrgan'};
frameValue = struct('Name', nameOptions, 'Value', value);
frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);
allInfo = struct('VideoFile', videoName, 'DateAndTime', dat, 'ExtractedFramesPath', frameFolder, 'NumberOfFrames', parse_number_of_frames, 'Annotations', []);
coordinate = [];
frame_start = 1;

%%  Loop to (1) extract & save frames, (2) mark co-ordinates of the point of interest (POI) and (3) save them in a file
screen_size = get(0, 'ScreenSize');
f = figure('Units','normalized','Position',[0 0 1 1]);
axes2 = subplot(1,2,1);
set(axes2, 'Position', [0.08 0.08 0.9 0.9]);
% 
i = 1;
coordinate = [];

while j <= parse_number_of_frames & i <= parse_number_of_frames
    
    vid_frame_original = rgb2gray(read(vid_reader,i));
    frameName = fullfile(pathname_tiff, [strcat(num2str(j,'%06d'), '_', name, '_', num2str(i,'%06d')) ext_tiff]);
    imwrite(vid_frame_original, frameName);
    i = i + iter;
    j = j + 1;
    
end