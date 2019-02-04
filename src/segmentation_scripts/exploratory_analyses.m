% Exploratory script to get a feel for simulated data
clear
close all
% set file paths
project = 'test1';
dataPath = ['../../dat/' project '/'];
% load data
load([dataPath 'spotInfo.mat']); % contains information on simulated spots
load([dataPath 'frameInfo.mat']); % contains general sim parameters
% load tiff stacks 
tiffFiles = dir([dataPath '/tiffFiles/*.tif']);
tiffCell = cell(1,numel(tiffFiles));
for i = 1:numel(tiffFiles)
    fileName = [dataPath '/tiffFiles/' tiffFiles(i).name];
    tiffInfo = imfinfo(fileName); % return tiff structure, one element per image
    tiffStack = imread(fileName, 1) ; % read in first image
    %concatenate each successive tiff to tiffStack
    for ii = 2 : size(tiffInfo, 1)
        temp_tiff = imread(fileName, ii);
        tiffStack = cat(3 , tiffStack, temp_tiff);
    end
    tiffCell{i} = tiffStack;
end

% look at max projection of one of the frames
max_fig = figure;
imagesc(max(tiffCell{3},[],3));
colorbar;
title('Max Projection')
