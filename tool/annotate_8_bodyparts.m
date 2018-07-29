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
prompt= 'Annotate every nth frame, enter n: ';
iter = input(prompt);
expression = '\\MHDO_Tracking';

%% Read MetaData File
pathname_metadata = dir(strcat(pathname_mp4, 'Metadata_*.txt'));
for fID = 1:length(pathname_metadata)
    if isempty(strfind(pathname_metadata(fID).name, 'synced'))
        IDSelc = fID;
    end
end
pathname_metadata = fullfile(pathname_mp4, pathname_metadata(IDSelc).name);
metadata = dlmread(pathname_metadata, ',', 1, 0);
frameNumber_metadata = metadata(:, 1);

%% Get Contour Data
contourFile = dir(fullfile(pathname_mp4, 'Contour_*.bin'));
for fID = 1:length(contourFile)
    if isempty(strfind(contourFile(fID).name, 'smoothed'))
        contourFileSel = fID;
    end
end

contourFile = fullfile(pathname_mp4, contourFile(contourFileSel).name);
display('Reading Contour Data......')
nFrames = 1;
sampling_interval = 101;
[contourX, contourY, splineX, splineY, framN] = constSpline(contourFile, nFrames, sampling_interval, 0);
numFrames_contour = length(framN);
frameNumber_contour = framN(:, 1);

%% Get the new Metadata
metaDataStartFrame = find(frameNumber_metadata == frameNumber_contour(1));
metadataNew = metadata(metaDataStartFrame:end, :);
headPosition = metadata(metaDataStartFrame:end, 9:10);
frameNumber_metadata = metadataNew(:, 1);

assert(frameNumber_metadata(1) == frameNumber_contour(1), 'The video and metadata are out of sync')
newMetaDataFileName = strcat(pathname_metadata(1:end-4), '_synced.txt');
dlmwrite(newMetaDataFileName, metadataNew, ',');

%% Initialize Variables
ext_tiff = '.tiff';
filename_tiff = fullfile(pathname_tiff,[name ext_tiff]);
vid_reader = VideoReader(strcat(pathname_mp4, filename_mp4));
lastFrame = read(vid_reader, inf);
total_number_of_frames = vid_reader.NumberOfFrames
parse_number_of_frames = total_number_of_frames

frameName = 'NotAvailable';
videoName = fullfile(pathname_mp4, filename_mp4);
splitVideoName = regexp(videoName,expression,'split');
videoName = splitVideoName{2};
videoName = strrep(videoName,'\','/');

splitFrameFolder = regexp(frameFolder,expression,'split')
frameFolder = splitFrameFolder{2};
frameFolder = strrep(frameFolder,'\','/')

value = struct('x_coordinate',[],'y_coordinate',[]);
nameOptions = {'CenterBolwigOrgan'; 'LeftBolwigOrgan'; 'RightBolwigOrgan'};
frameValue = struct('Name', nameOptions, 'Value', value);
frameInfo = struct('FrameID',0,'FrameIndexVideo',0,'FrameFile',frameName,'FrameValueCoordinates', frameValue);
allInfo = struct('VideoFile', videoName, 'DateAndTime', dat, 'ExtractedFramesPath', frameFolder, 'NumberOfFrames', parse_number_of_frames, 'Annotations', []);
coordinate = [];
frame_start = 1;

%%  Loop to (1) extract & save frames, (2) mark co-ordinates of the point of interest (POI) and (3) save them in a file
prompt_2 = 'Start Annotation at nth frame : ';
startFrame = input(prompt_2);

screen_size = get(0, 'ScreenSize');
f = figure('Units','normalized','Position',[0 0 1 1]);
axes2 = subplot(1,2,1);
set(axes2, 'Position', [0.08 0.08 0.9 0.9]);

j = startFrame; i = startFrame;
coordinate = [];
try
    while j <= parse_number_of_frames & i <= parse_number_of_frames
        
        vid_frame_original = rgb2gray(read(vid_reader,i));
        crop_x = max(1, headPosition(j, 1)-256);
        crop_y = max(1, headPosition(j, 2)-256);
        if crop_x+512 > 2040
            cropIndex_x = crop_x:2040;
        else
            cropIndex_x = crop_x:crop_x+512;
        end
        if crop_y+512 > 2040
            cropIndex_y = crop_y:2040;
        else
            cropIndex_y = crop_y:crop_y+512;
        end
        vid_frame = vid_frame_original(cropIndex_y, cropIndex_x);
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
        
        % Annotate Center Bolwig's Organ - press m
        [X_coordinate_MH, Y_coordinate_MH, Button_MH] = ginput(2);
        p_mh = plot(X_coordinate_MH, Y_coordinate_MH,'Marker','o','MarkerSize',6,'MarkerFaceColor',[1,0,0]);
        if any(Button_MH == 109)
            frameValue(1,1).Value.x_coordinate = crop_x + X_coordinate_MH(1,1);
            frameValue(1,1).Value.y_coordinate = crop_y + Y_coordinate_MH(1,1);
        elseif any(Button_MH == 98)
            frameValue(1,1).Value.x_coordinate = -1;
            frameValue(1,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Left Bolwig's Organ
        [X_coordinate_lmh, Y_coordinate_lmh, Button_lmh] = ginput(2);
        p_lmh = plot(X_coordinate_lmh, Y_coordinate_lmh,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,1,0]);
        if any(Button_lmh == 109)
            frameValue(2,1).Value.x_coordinate = crop_x + X_coordinate_lmh(1,1);
            frameValue(2,1).Value.y_coordinate = crop_y + Y_coordinate_lmh(1,1);
        elseif any(Button_lmh == 98)
            frameValue(2,1).Value.x_coordinate = -1;
            frameValue(2,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Annotate Right Bolwig's Organ
        [X_coordinate_rmh, Y_coordinate_rmh, Button_rmh] = ginput(2);
        p_rmh = plot(X_coordinate_rmh, Y_coordinate_rmh,'Marker','o','MarkerSize',5,'MarkerFaceColor',[0,1,0]);
        
        if any(Button_rmh == 109)
            frameValue(3,1).Value.x_coordinate = crop_x + X_coordinate_rmh(1,1);
            frameValue(3,1).Value.y_coordinate = crop_y + Y_coordinate_rmh(1,1);
        elseif any(Button_rmh == 98)
            frameValue(3,1).Value.x_coordinate = -1;
            frameValue(3,1).Value.y_coordinate = -1;
        else
            i = i;
            j = j;
            continue;
        end
        
        % Confirmation Key Press
        [X_coordinate, Y_coordinate, Button_final] = ginput(1);
        if any(Button_final == 110)
            i = i;
            j = j;
            continue;
        end
        
        frameName = fullfile(pathname_tiff,[strcat(num2str(j,'%06d'),'_',name,'_', num2str(i,'%06d')) ext_tiff]);
        imwrite(vid_frame_original, frameName);
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