clc; clear; close all;
addpath('../lib/matpcl');
load('streetview.mat');
%% Convert int2double for Caculate
numPlanes = double(DepthHeader.numPlanes);
h = double(DepthHeader.panoHeight);
w = double(DepthHeader.panoWidth);
DepthMapIndices = double(DepthMapIndices);
%% Index Row-major 2 Col-major
DepthMapIndices = reshape(DepthMapIndices, w, h);
DepthMapIndices = DepthMapIndices';
DepthMapIndices = reshape(DepthMapIndices, 1, w * h);
%% Visual index map
depthMapVisual = reshape(DepthMapIndices, h, w);
    %% Gray Image
%     depthMapVisual_g = depthMapVisual / numPlanes;
%     figure();
%     imshow(depthMapVisual_g);
    %% Color Image
    randIndexColor = rand(3,numPlanes);
    depthMapVisual_r = zeros(h, w); depthMapVisual_g = zeros(h, w); depthMapVisual_b = zeros(h, w);
    for i=3:3
        depthMapVisual_r(depthMapVisual == i) =  randIndexColor(1, i+1);
        depthMapVisual_g(depthMapVisual == i) =  randIndexColor(2, i+1);
        depthMapVisual_b(depthMapVisual == i) =  randIndexColor(3, i+1);
    end
    depthMapVisual_color = cat(3, depthMapVisual_r, depthMapVisual_g, depthMapVisual_b);
    imshow(depthMapVisual_color);
%% Create DepthMap
    %% Emit Ray
    y = 0:h-1;
    theta = (h - y - 0.5) / h * pi; sin_theta = sin(theta); cos_theta = cos(theta);
    x = 0:w-1;
    phi = (w - x - 0.5) / w * 2 * pi + pi/2; sin_phi = sin(phi); cos_phi = cos(phi);
    v = zeros(h,w,3); 
    v(:,:,1) = sin_theta' * cos_phi; v(:,:,2) = sin_theta' * sin_phi; v(:,:,3) = cos_theta' * ones(1,w);
    %% Visual
%     for i=1:3
%         figure();imshow(v(:,:,i))
%     end
%     surf(v(:,:,1), v(:,:,2), v(:,:,3))
    v = reshape(v, h*w, 3);
    %% Calculate depth
    depthMap = zeros(h, w); 
    depthMap(DepthMapIndices == 0) = inf;
    for i=1:numPlanes - 1
        plane = DepthMapPlanes{i + 1};
        p_nomal = ones(w*h, 1)*plane.d;
        depth = abs(p_nomal ./ (v * [plane.nx; plane.ny; plane.nz]));
        depthMap(DepthMapIndices == i) = depth(DepthMapIndices == i);
    end
    %imshow(depthMap /50 );
    depthMap(isinf(depthMap)) = 0;
%% Create Point Cloud
    %% Emit Ray
%     y = 0:h-1;
%     theta = (h - y - 0.5) / h * pi; sin_theta = sin(theta); cos_theta = cos(theta);
%     x = 0:w-1;
%     phi = (w - x - 0.5) / w * 2 * pi + pi/2; sin_phi = sin(phi); cos_phi = cos(phi);
%     v = zeros(h,w,3); 
%     v(:,:,1) = sin_theta' * cos_phi; v(:,:,2) = sin_theta' * sin_phi; v(:,:,3) = cos_theta' * ones(1,w);
v(:,1) = -v(:,1) .* depthMap(:);
v(:,2) = -v(:,2) .* depthMap(:);
v(:,3) = -v(:,3) .* depthMap(:);
A = im2double(imread('pano.PNG'));
A_resize = imresize(A, [256 512]);
imshow(A_resize);
pano = reshape(A_resize, 256*512, 3);
my_pcd_write([v pano * 255], 'pcd', 'ply');

