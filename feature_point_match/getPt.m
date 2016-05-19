clear;clc;close all;
%% Read Image
imgPath = 'src/img/pano_depth/';
imgFileEx = '.png';
I1 = im2double(imread(strcat(imgPath, '4', imgFileEx)));
I2 = im2double(imread(strcat(imgPath, '5', imgFileEx)));
D1 = im2double(imread(strcat(imgPath, '4d', imgFileEx)));
D2 = im2double(imread(strcat(imgPath, '5d', imgFileEx)));
[m,n,p] = size(I2);
[md,nd,pd] = size(D2);
%% Show
imshow(I1);
hold on;
%% Get Point
for i=1:5
    [clickX,clickY] = ginput(1);
    scatter( clickX, clickY, 100, 'lineWidth', 4 );
    display(clickX)
    drawnow;
end
%%