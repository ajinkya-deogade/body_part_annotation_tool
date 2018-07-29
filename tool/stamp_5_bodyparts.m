% function StampAnnotations() 
%% Input Files
close all;
clear all;
clc;
tic;
root = 'F:\MHDO_Tracking\';
% pathname_data = uigetdir('./', 'Select the folder with MHDO data');
expression1 = '\\MHDO_Tracking';
expression2 = '\\data';
[filename_json, pathname_json] = uigetfile('*.json','Select the file with co-ordinates of Point of Interest');
ReadInfo = loadjson(fullfile(pathname_json, filename_json));
WriteInfo = ReadInfo;

% splitFileName = regexp(pathname_json, expression2,'split');
% pathname_data = splitFileName{1};

formatOut = 'yyyy/mm/dd HH:MM:SS';
dat = datestr(clock,formatOut);
dateName =  strrep(strrep(strrep(dat,'/',''),':',''),' ','_');
WriteInfo.DateAndTime = dateName;
frameFolder = strcat(root,strrep(ReadInfo.ExtractedFramesPath,'/','\'));
annotationFolder = fullfile(frameFolder, strcat('AnnotatedFrames_',dateName));
mkdir(annotationFolder);
numFrames = ReadInfo.NumberOfFrames;

%% Initialize Variables
% Create an array of filenames that make up the image sequence

% dir_input = dir(fullfile(frameFolder,'*.tiff'));
% fileNames = {dir_input.name};

% I = imread(fullfile(pathname_tiff, fileNames{1}));
% frameName = 'Error';
% value = struct('x_coordinate',[],'y_coordinate',[]);
% nameOptions = {'MouthHook';'LeftDorsalOrgan';'RightDorsalOrgan'};
% frameValue = struct('Name', nameOptions, 'Value', value);
% frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);
% WriteInfo = struct('VideoFile',ReadInfo.VideoFile,'DateAndTime',dat,'AnnotatedFramesPath',frameFolder,'NumberOfFrames',numFrames);
% coordinate = [];

%% Mark the annotation on each frame
% Create image sequence array and view results
% [path_folder, name_folder, ext_folder] = fileparts(filename_json);
% annot = 'Annotated';
% marked_folder = fullfile(pathname_data, annot);
% mkdir(marked_folder);
% cd(marked_folder);
%% Real loop
screen_size = get(0, 'ScreenSize');
f = figure('Units','normalized','Position',[0 0 1 1]);
axes2 = subplot(1,2,1);
set(axes2, 'Position', [0.08 0.08 0.9 0.9]);

j =1;
while j <= numFrames
    imageFile = ReadInfo.Annotations{1,j}.FrameFile;
    if ispc
        imageFile = fullfile(root, strrep(imageFile, '/', filesep));
    end
    I = imread(imageFile);
    MH_x = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,1}.Value.x_coordinate;
    MH_y = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,1}.Value.y_coordinate;
    lmh_x = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,2}.Value.x_coordinate;
    lmh_y = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,2}.Value.y_coordinate;
    rmh_x = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,3}.Value.x_coordinate;
    rmh_y = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,3}.Value.y_coordinate;
    doL_x = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,4}.Value.x_coordinate;
    doL_y = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,4}.Value.y_coordinate;
    doR_x = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,5}.Value.x_coordinate;
    doR_y = ReadInfo.Annotations{1,j}.FrameValueCoordinates{1,5}.Value.y_coordinate;
    I = insertShape(I,'FilledCircle',[MH_x MH_y 5],'Color','red');
    I = insertShape(I,'FilledCircle',[lmh_x lmh_y 5],'Color','green');
    I = insertShape(I,'FilledCircle',[rmh_x rmh_y 5],'Color','yellow');
    I = insertShape(I,'FilledCircle',[doL_x doL_y 5],'Color','blue');
    I = insertShape(I,'FilledCircle',[doR_x doR_y 5],'Color','cyan');
    f = imshow(I);
    title(sprintf('Frame # %d',j));
    [path, name, ext] = fileparts(imageFile);
    frameName = fullfile(annotationFolder,[strcat(name,'_mark') '.tiff']);
    imwrite(I, frameName);
%     splitFrameName = regexp(frameName,expression1,'split');
%     frameName = splitFrameName{2};
    WriteInfo.Annotations{1, j}.FrameFile = frameName;
    pause(1);
    j = j+1;
    delete(f);
end
FileJSON_writer = fopen(strcat(annotationFolder,'\', name,'_',dateName,'_Annotated.json'),'w');
Data_write = savejson('',WriteInfo);
fprintf(FileJSON_writer, Data_write);
fclose(FileJSON_writer);
close all;
% end
% clear all;