clc; clear; close all;
addpath('../lib');
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
%depthMapVisual = reshape(DepthMapIndices, h, w);
    %% Gray Image
%     depthMapVisual = depthMapVisual / numPlanes;
%     figure();
%     imshow(depthMapVisual);
    %% Color Image
%     randIndexColor = rand(3,numPlanes);
%     depthMapVisual_r = zeros(h, w); depthMapVisual_g = zeros(h, w); depthMapVisual_b = zeros(h, w);
%     for i=0:numPlanes-1
%         depthMapVisual_r(depthMapVisual == i) =  randIndexColor(1, i+1);
%         depthMapVisual_g(depthMapVisual == i) =  randIndexColor(2, i+1);
%         depthMapVisual_b(depthMapVisual == i) =  randIndexColor(3, i+1);
%     end
%     depthMapVisual_color = cat(3, depthMapVisual_r, depthMapVisual_g, depthMapVisual_b);
%     imshow(depthMapVisual_color);
%% Create DepthMap
y = 0:h-1;
theta = (h - y - 0.5) / h * pi; sin_theta = sin(theta); cos_theta = cos(theta);
x = 0:w-1;
phi = (w - x - 0.5) / w * 2 * pi + pi/2; sin_phi = sin(phi); cos_phi = cos(phi);

v = zeros(h,w,3); 
v(:,:,1) = sin_theta' * cos_phi; v(:,:,2) = sin_theta' * sin_phi; v(:,:,3) = cos_theta' * ones(1,w);
v = reshape(v, h*w, 3);
depthMap = zeros(h, w); 
depthMap(DepthMapIndices == 0) = inf;
for i=1:numPlanes - 1
    plane = DepthMapPlanes{i + 1};
    d_vec = ones(w*h, 1)*plane.d;
    dot_vec = v * [plane.nx; plane.ny; plane.nz];
    t = abs(d_vec ./ dot_vec);
    depthMap(DepthMapIndices == i) = t(DepthMapIndices == i);
end
figure();        
imshow(depthMap /50 );
%% Create Point Cloud
numFaces = 100;
[x,y,z] = sphere(numFaces);
scatter3(x(:), y(:), z(:));
% num_points = w*h;
% positions_x = zeros(1, num_points);
% positions_y = zeros(1, num_points);
% positions_z = zeros(1, num_points);
% n = 0;
% for y=0:h
%     lat = -(y / h) * 180.0 + 90.0;
%     r = cos(lat * pi / 180.0);
%     for x=0:w
%         depth = depthMap(y * h + x +1);	
%         lng = (x / w) * 360.0 - 180.0;
%         pos = zeros(1:3);
%         pos(2) = sin(lat * pi / 180.0);
%         pos(1) = (r * sin(lng * pi / 180.0));
%         pos(3) = -(r * cos(lng * pi / 180.0)); % IMPORTANT!!!!
%         % Multiple by Depth
%         pos = pos*depth;
%         % Store Position and Color of Each Point
%         if isinf(pos(1))
%             positions_x(n + 1) = 0;
%         else
%             positions_x(n + 1) = pos(1);            
%         end
%         if isinf(pos(2))
%             positions_y(n + 1) = 0;
%         else
%             positions_y(n + 1) = pos(2);            
%         end
%         if isinf(pos(3))
%             positions_z(n + 1) = 0;
%         else
%             positions_z(n + 1) = pos(3);            
%         end        
% 
% %         var color_canvas_x = parseInt((x / this.depthMap.width) * img_canvas_context.canvas.width);
% %         var color_canvas_y = parseInt((y / this.depthMap.height) * img_canvas_context.canvas.height);
% %         var color_index = color_canvas_y * img_canvas_context.canvas.width * 4 + color_canvas_x * 4;							
% %         colors[3 * n + 0] = (color_data[color_index + 0]) / 255.0;
% %         colors[3 * n + 1] = (color_data[color_index + 1]) / 255.0;
% %         colors[3 * n + 2] = (color_data[color_index + 2]) / 255.0;											
%          n = n+1;
%     end
% end