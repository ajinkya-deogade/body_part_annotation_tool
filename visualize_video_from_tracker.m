%% Input Files
close all;
clear all;
clc;
tic;

% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q2_2015\20150501_MPEG4_NoOdor\Clips';
% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q1_2017';
% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q2_2015\20150501_MPEG4_EthylButyrate';
% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q1_2018';
initFolder = '/Volumes/HD2/MHDO_Tracking/data/';

[filename_mp4, pathname_mp4, ext_mp4] = uigetfile('*.avi','Select the video file to extract frames.',initFolder);
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
% expression = '\\MHDO_Tracking'; %% Windows
expression = '\MHDO_Tracking'; %% Mac

% filename = '/Volumes/HD2/MHDO_Tracking/data/Janelia_Q1_2018/20180417_BG57_Midpoint_200micron_30fps/AVI/Rawdata_20180417_064814/Rawdata_20180417_064814.avi'; 


%% Initialize Variables
ext_tiff = '.tiff';
filename_tiff = fullfile(pathname_tiff,[name ext_tiff]);
tic
vid_reader = VideoReader(strcat(pathname_mp4, filename_mp4));
toc
% lastFrame = read(vid_reader, inf);
% total_number_of_frames = vid_reader.NumberOfFrames
% parse_number_of_frames = total_number_of_frames

parse_number_of_frames = 40000;

frameName = 'NotAvailable';
videoName = fullfile(pathname_mp4, filename_mp4);
splitVideoName = regexp(videoName, expression, 'split');
videoName = splitVideoName{2};
videoName = strrep(videoName,'\','/');

splitFrameFolder = regexp(frameFolder,expression,'split')
frameFolder = splitFrameFolder{2};
frameFolder = strrep(frameFolder,'\','/')

value = struct('x_coordinate',[],'y_coordinate',[]);
nameOptions = {'MouthHook'; 'LeftMHhook'; 'RightMHhook'; 'LeftDorsalOrgan'; 'RightDorsalOrgan'; 'CenterBolwigOrgan'; 'LeftBolwigOrgan'; 'RightBolwigOrgan'};
frameValue = struct('Name', nameOptions, 'Value', value);
frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);
allInfo = struct('VideoFile', videoName, 'DateAndTime', dat, 'ExtractedFramesPath', frameFolder, 'NumberOfFrames', parse_number_of_frames, 'Annotations', []);
coordinate = [];
frame_start = 1;

%%  Loop to (1) extract & save frames, (2) mark co-ordinates of the point of interest (POI) and (3) save them in a file
prompt_2 = 'Start Annotation at nth frame : ';
startFrame = input(prompt_2);

fStart = startFrame; fInt = 1; fEnd = 2000; thresh = 200;
txtfile = trackLarvaeFeature(strcat(pathname_mp4, filename_mp4), fStart, fInt, fEnd, thresh);
metaData = dlmread(txtfile);

headPosition = metaData(:, 2:3); 

f = figure('Units','normalized','Position',[0 0 1 1]);
axes2 = subplot(1,2,1);
set(axes2, 'Position', [0.08 0.08 0.9 0.9]);

j = startFrame; i = startFrame;

coordinate = [];
while j <= parse_number_of_frames & i <= parse_number_of_frames
    vid_reader.CurrentTime = i/vid_reader.FrameRate;
    vid_frame_original = rgb2gray(readFrame(vid_reader));
    f_image = imshow(vid_frame_original);
    hold on
    p_mh = plot(headPosition(j, 1), headPosition(j, 2),'Marker','o','MarkerSize',6,'MarkerFaceColor',[1,0,0]);
    hold off
    i = i + iter;
    j = j + 1;
end
pause(0.01);
delete(f_image);

%% Release all the object handles and save data
FileJSON_writer = fopen(strcat(pathname_tiff,'\', name,'_',dateName,'_Coordinates.json'),'w');
Data_write = savejson('', allInfo);
fprintf(FileJSON_writer, Data_write);
fclose(FileJSON_writer)
close all;
% clear all;
toc;