clear;clc;close all;
%% environment settle
% run('lib/vlfeat-0.9.20/toolbox/vl_setup')
% vl_version verbose
%% Read Image
imgPath = 'src/img/pano_depth/';
imgFileEx = '.png';
I1 = im2double(imread(strcat(imgPath, '4', imgFileEx)));
I2 = im2double(imread(strcat(imgPath, '5', imgFileEx)));
D1 = im2double(imread(strcat(imgPath, '4d', imgFileEx)));
D2 = im2double(imread(strcat(imgPath, '5d', imgFileEx)));
[m,n,p] = size(I2);
[md,nd,pd] = size(D2);
%% Manually Select Points
% Point selected from RGB MANUALLY
p1 = [146 181; 363 226; 508 238;];  % Nx2 points [w h] selected from RGBimg1 
p2 = [66 193; 283 238; 683 251;];  % Nx2 points [w h] selected from RGBimg2
% Transform RGB axis to Depth axis
pd1 = round([nd*(p1(:,1)/n), p1(:,2)*md/m]);
pd2 = round([nd*(p2(:,1)/n), p2(:,2)*md/m]);

% pd1 = [nd*(1-p1(:,1)/n), p1(:,2)*md/m];
% pd2 = [nd*(1-p2(:,1)/n), p2(:,2)*md/m];


%% Manually Get Depth 
% Depth recorded directly from point cloud MANUALLY
% Can't recover it from depth pano due to the information loss
d1 = [9.2810640335083; 18.108922958374023; 11.759673118591309;];
d2 = [16.902694702148438; 9.953967094421387; 7.9868340492248535;];
d1 = d1*ones(1,p);
d2 = d2*ones(1,p);
%% Pano [w h] + depth TRANSFORM to 3dWorld [X Y Z]
% Two way to get 3dWorld aixs [X Y Z]
% 1. Directly recorded from point cloud
% tp1 = [29.33283852566307 -24.72428340173156 -9.69026093972584;
%       -13.038405768291675 5.049593606683845 -5.400684500949997;
%       -9.838551450456789 5.028348756320817 7.111297638640075;
%       -12.057916210838957 -65.22339786279981 48.13789987961814;
%       60.68893375510212 -47.05699239165295 49.80612077081788];
% tp2 = [37.892414234614705 -22.76664484538064 -9.4915556559384; 
%       -3.392805580053233 5.075567453187084 -5.35782550044239;
%       -0.6499018769913529 5.061353777679485 7.54691981641901;
%       -1.1471251415324246 -61.43509106169593 46.728697702155216;
%       71.27984529921493 -46.60051222626635 50.20093101787486];
% 2. or Transformed by formula
lng = 360*pd1(:,1)/nd; lat = 180*pd1(:,2)/md-90; r = cos(lat * pi / 180);
tp1 = [r.*cos(lng * pi / 180.0), sin(lat * pi / 180.0), r .* sin(lng * pi / 180.0)].*d1*2;
lng = 360*pd2(:,1)/nd; lat = 180*pd2(:,2)/md-90; r = cos(lat * pi / 180);
tp2 = [r.*cos(lng * pi / 180.0), sin(lat * pi / 180.0), r .* sin(lng * pi / 180.0)].*d2*2;
%% RANSAC fitting to find Rt
save('3dp', 'tp1', 'tp2');
error3D_threshold = 0.005;
error3D_threshold2 = error3D_threshold^2;
load('3dp.mat');
[RtRANSAC, inliers] = ransacfitRt([tp2'; tp1'], error3D_threshold, 0);
display(RtRANSAC);
transLate = RtRANSAC(:,4);
display(transLate');
Htp1 = [tp1, ones(length(tp2), 1)];
diff = tp2' - RtRANSAC*Htp1';
display(diff);
%% Visualize
% RGB pano
figure;
visualize = zeros(m+m,n,3);
visualize(1:m,1:n,:) = I1; visualize(1+m:m+m,1:n,:) = I2;
imshow(visualize);
hold on;
plot(p1(:,1), p1(:,2),'g*');
plot(p2(:,1), p2(:,2)+m,'r*');
% matches = matches'; N = length(matches);
for i=1:length(p1)
    line([p1(i,1), p2(i,1)], [p1(i,2), p2(i,2)+m], 'Color',[0 0 1] );
end
hold off;
% Depth pano
figure;
visualize = zeros(md+md,nd,3);
visualize(1:md,1:nd,:) = D1;
visualize(1+md:md+md,1:nd,:) = D2;
% Flip the depth so that we won't see the mirror world
imshow(visualize);
hold on;
plot(pd1(:,1), pd1(:,2),'g*');
plot(pd2(:,1), pd2(:,2)+md,'r*');
% matches = matches'; N = length(matches);
for i=1:length(pd1)
    line([pd1(i,1), pd2(i,1)], [pd1(i,2), pd2(i,2)+md], 'Color',[0 0 1] );
end
hold off;