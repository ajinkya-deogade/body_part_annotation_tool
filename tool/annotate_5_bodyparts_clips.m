%% Input Files
close all;
clear all;
clc;
tic;
% initFolder = 'F:\MHDO_Tracking\data\Janelia_Q2_2015\20150501_MPEG4_NoOdor\Clips';
initFolder = 'G:\MHDO_Tracking\data\Janelia_Q1_2017\20170224_forValidation\Rawdata_20170224_155514';
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
frameFolder = fullfile(experimentFolder, strcat(name, '_Frames_', dateName))
mkdir(frameFolder);
pathname_tiff = frameFolder;
prompt= 'Annotate every nth term, enter n: ';
iter = input(prompt);
expression = '\\MHDO_Tracking';

%% Initialize Variables
ext_tiff='.tiff';
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
nameOptions = {'MouthHook';'LeftMHhook';'RightMHhook';'LeftDorsalOrgan';'RightDorsalOrgan'};
frameValue = struct('Name', nameOptions, 'Value', value);
frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);
allInfo = struct('VideoFile',videoName,'DateAndTime',dat,'ExtractedFramesPath',frameFolder,'NumberOfFrames',parse_number_of_frames,'Annotations',[]);
coordinate = [];
frame_start = 1;

%%  Loop to (1) extract & save frames, (2) mark co-ordinates of the point of interest (POI) and (3) save them in a file
screen_size = get(0, 'ScreenSize');
f = figure('Units','normalized','Position',[0 0 1 1]);
axes2 = subplot(1,2,1);
set(axes2, 'Position', [0.08 0.08 0.9 0.9]);

i = 1;
coordinate = [];
try
    while j <= parse_number_of_frames & i <= parse_number_of_frames
        
        vid_frame = rgb2gray(read(vid_reader,i));
        f_image = imshow(vid_frame);
        title(sprintf('Frame # %d',j));
        
        Button_MH = 110;
        Button_rmh = 110;
        Button_lmh = 110;
        Button_ldo = 110;
        Button_rdo = 110;
        
        is_MHhook = 1;
        is_DO = 1;
        hold on
        
        % Annotate Mouth-hook - press m
        [X_coordinate_MH, Y_coordinate_MH, Button_MH] = ginput(2);
        p_mh = plot(X_coordinate_MH, Y_coordinate_MH,'Marker','o','MarkerSize',6,'MarkerFaceColor',[1,0,0]);
        if any(Button_MH == 109)
            frameValue(1,1).Value.x_coordinate = X_coordinate_MH(1,1);
            frameValue(1,1).Value.y_coordinate = Y_coordinate_MH(1,1);
        elseif any(Button_MH == 98)
            frameValue(1,1).Value.x_coordinate = -1;
            frameValue(1,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Left Mouth hook
        [X_coordinate_lmh, Y_coordinate_lmh, Button_lmh] = ginput(2);
        p_lmh = plot(X_coordinate_lmh, Y_coordinate_lmh,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,1,0]);
        if any(Button_lmh == 109)
            frameValue(2,1).Value.x_coordinate = X_coordinate_lmh(1,1);
            frameValue(2,1).Value.y_coordinate = Y_coordinate_lmh(1,1);
        elseif any(Button_lmh == 98)
            frameValue(2,1).Value.x_coordinate = -1;
            frameValue(2,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Right Mouth-hook
        [X_coordinate_rmh, Y_coordinate_rmh, Button_rmh] = ginput(2);
        p_rmh = plot(X_coordinate_rmh, Y_coordinate_rmh,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,1,0]);
        
        if any(Button_rmh == 109)
            frameValue(3,1).Value.x_coordinate = X_coordinate_rmh(1,1);
            frameValue(3,1).Value.y_coordinate = Y_coordinate_rmh(1,1);
        elseif any(Button_rmh == 98)
            frameValue(3,1).Value.x_coordinate = -1;
            frameValue(3,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Left Dorsal Organ
        [X_coordinate_ldo, Y_coordinate_ldo, Button_ldo] = ginput(2);
        p_ldo = plot(X_coordinate_ldo, Y_coordinate_ldo,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,0,1]);
        
        if any(Button_ldo == 109)
            frameValue(4,1).Value.x_coordinate = X_coordinate_ldo(1,1);
            frameValue(4,1).Value.y_coordinate = Y_coordinate_ldo(1,1);
        elseif any(Button_ldo == 98)
            frameValue(4,1).Value.x_coordinate = -1;
            frameValue(4,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Right Dorsal Organ
        [X_coordinate_rdo, Y_coordinate_rdo, Button_rdo] = ginput(2);
        p_rdo = plot(X_coordinate_rdo, Y_coordinate_rdo,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,0,1]);
        
        if any(Button_rdo == 109)
            frameValue(5,1).Value.x_coordinate = X_coordinate_rdo(1,1);
            frameValue(5,1).Value.y_coordinate = Y_coordinate_rdo(1,1);
        elseif any(Button_rdo == 98)
            frameValue(5,1).Value.x_coordinate = -1;
            frameValue(5,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        [X_coordinate, Y_coordinate, Button_final] = ginput(1);
        if any(Button_final == 110)
            i = i;
            j = j;
            continue;
        end
        
        frameName = fullfile(pathname_tiff,[strcat(num2str(j,'%06d'),'_',name,'_', num2str(i,'%06d')) ext_tiff]);
        imwrite(vid_frame, frameName);
        frameInfo.FrameID = num2str(j,'%06d');
        frameInfo.FrameIndexVideo = num2str(i,'%06d');
        frameInfo.FrameValueCoordinates = frameValue;
        splitFrameName = regexp(frameName, expression,'split');
        frameName = splitFrameName{2};
        frameName = strrep(frameName,'\','/');
        frameInfo.FrameFile = frameName;
        allInfo.Annotations = horzcat(allInfo.Annotations, frameInfo);
        i = i + iter;
        j = j + 1;
        hold off
    end
catch
    FileJSON_writer = fopen(strcat(pathname_tiff,'\', name,'_',dateName,'_Coordinates.json'),'w');
    Data_write = savejson('', allInfo);
    fprintf(FileJSON_writer, Data_write);
    fclose(FileJSON_writer)
    close all;
    % clear all;
    toc;
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