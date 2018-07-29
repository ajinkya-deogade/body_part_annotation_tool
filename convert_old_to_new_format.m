%% Input Files
close all
clear all
clc
tic

initFolder = 'F:\MHDO_Tracking\data\Janelia_Q1_2018\';
[filename_fpga, pathname_fpga, ext_fpga] = uigetfile('*.fpga','Select the video file to extract frames.', initFolder);
fpga_annotations = dlmread(fullfile(pathname_fpga, filename_fpga));
filename_fpga = filename_fpga(1:end-5);

formatOut = 'yyyy/mm/dd HH:MM:SS';
dat = datestr(clock,formatOut);
dateName =  strrep(strrep(strrep(dat,'/',''),':',''),' ','_');
frameFolder = pathname_fpga;

expression = '\\MHDO_Tracking';
% expression = '';
parse_number_of_frames = size(fpga_annotations, 1);

frameName = 'NotAvailable';
videoName = fullfile(pathname_fpga, filename_fpga);
value = struct('x_coordinate',[],'y_coordinate',[]);
nameOptions = {'MouthHook'; 'LeftDorsalOrgan'; 'RightDorsalOrgan'};
frameValue = struct('Name', nameOptions, 'Value', value);
frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);

splitVideoName = regexp(videoName, expression, 'split');
videoName = splitVideoName{2};
videoName = strrep(videoName,'\','/');

splitFrameFolder = regexp(frameFolder, expression, 'split');
frameFolder = splitFrameFolder{2};
frameFolder = strrep(frameFolder,'\','/');

allInfo = struct('VideoFile', videoName, 'DateAndTime', dat, 'ExtractedFramesPath', frameFolder, 'NumberOfFrames', parse_number_of_frames, 'Annotations', []);
coordinate = [];
frame_start = 1;
j = 1;
while j <= parse_number_of_frames

    frameValue(1,1).Value.x_coordinate = fpga_annotations(j,1);
    frameValue(1,1).Value.y_coordinate = fpga_annotations(j,2);
    
    frameValue(2,1).Value.x_coordinate = fpga_annotations(j,1);
    frameValue(2,1).Value.y_coordinate = fpga_annotations(j,2);
    
    frameValue(3,1).Value.x_coordinate = fpga_annotations(j,1);
    frameValue(3,1).Value.y_coordinate = fpga_annotations(j,2);

    frameName = fullfile(pathname_fpga, [strcat(num2str(j,'%06d'),'_',filename_fpga,'_', num2str(j,'%06d')) '.tiff']);
    frameInfo.FrameID = num2str(j,'%06d');
    frameInfo.FrameIndexVideo = num2str(j,'%06d');
    frameInfo.FrameValueCoordinates = frameValue;
    splitFrameName = regexp(frameName, expression, 'split');
    frameName = splitFrameName{2};
    frameName = strrep(frameName,'\','/');
    frameInfo.FrameFile = frameName;
    allInfo.Annotations = horzcat(allInfo.Annotations, frameInfo);
    j = j + 1;
end

FileJSON_writer = fopen(strcat(pathname_fpga, '\', filename_fpga, '_', dateName, '_Coordinates.json'), 'w');
Data_write = savejson('', allInfo);
fprintf(FileJSON_writer, Data_write);
fclose(FileJSON_writer);
close all;
toc;