clear all;
close all;
%% Read Descriptors
pathname_descp = uigetdir('./', 'Select the folder with Descriptors');
dir_input_descp = dir(fullfile(pathname_descp,'*.mat'));
fileNames_descp = {dir_input_descp.name};

%% Read Features
pathname_feature = uigetdir('./', 'Select the folder with Features');
dir_input_feature = dir(fullfile(pathname_feature,'*.mat'));
fileNames_feature = {dir_input_feature.name};

%% Read Images
pathname_image = uigetdir('./', 'Select the folder with Images');
dir_input_image = dir(fullfile(pathname_image,'*.tiff'));
fileNames_image = {dir_input_image.name};
Image_folder = fullfile(pathname_image, 'Correspondences');
mkdir(Image_folder);

%% Compare Descriptors in each frame
numFrames = numel(fileNames_descp);
for i = 1:numFrames
    clear D1 D2 F1 F2 I1 I2;
    [path, name, ext] = fileparts(fileNames_image{i});
    descriptor_struct1 = load(fullfile(pathname_descp,fileNames_descp{i}),'-mat');
    features_struct1 = load(fullfile(pathname_feature,fileNames_feature{i}),'-mat');
    D1 = descriptor_struct1.D;
    F1 = features_struct1.F;
    descriptor_struct2 = load(fullfile(pathname_descp,fileNames_descp{i+1}),'-mat');
    features_struct2 = load(fullfile(pathname_feature,fileNames_feature{i+1}),'-mat');
    D2 = descriptor_struct2.D;
    F2 = features_struct2.F;
    [matches, scores] = vl_ubcmatch(D1, D2, 15);
     
    I1 = imread(fullfile(pathname_image, fileNames_image{i}));
    I1 = adapthisteq(I1);
    I1 = imresize(I1, 1/10);
%     I1  = single(I1);
    I1= I1 * 2;
    I1 = min(I1,255);
        figure(1),imshow(I1),title(sprintf('Frame # %d',i));
    hold on;
    draw_features1 = vl_plotframe(F1(:,matches(1,:)));
    set(draw_features1,'color','y','linewidth',2);
    
    I2 = imread(fullfile(pathname_image, fileNames_image{i+1}));
    I2 = adapthisteq(I2);
    I2 = imresize(I2, 1/10);
%     I2  = single(I2);
    I2= I2 * 2;
    I2 = min(I2,255);
    figure(2),imshow(I2),title(sprintf('Frame # %d',i+1));
    hold on;
    draw_features2 = vl_plotframe(F2(:,matches(2,:)));
    set(draw_features2,'color','r','linewidth',2);
    pause;
    file_name_image = fullfile(Image_folder, [name '.tiff']);
    saveas(gcf, file_name_image);
end