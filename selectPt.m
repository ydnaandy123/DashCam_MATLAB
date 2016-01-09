clear;clc;
%% Manually Select Points
p2 = [42 118; 363 253; 498 260; 591 86; 741 136];
p3 = [30 134; 282 297; 612 286; 620 86; 750 143];

d2 = [19.78387451171875; 7.4944281578063965; 6.569854259490967; 40.977867126464844; 45.766136169433594];
d3 = [23.887454986572266; 4.061367034912109; 4.555098056793213; 38.5977897644043; 49.428123474121094];

I2 = im2double(imread('img/2.png'));
I3 = im2double(imread('img/3.png'));

for i=1:length(p2)
    RGB2(i,1:3) = I2(p2(i,2),p2(i,1),:);
    RGB3(i,1:3) = I3(p3(i,2),p3(i,1),:);
end
[m,n,p] = size(I2);
%%---visualize
visualize(1:m,1:n,:) = I2;
visualize(1+m:m+m,1:n,:) = I3;
imshow(visualize);
hold on;
plot(p2(:,1), p2(:,2),'g*');
plot(p3(:,1), p3(:,2)+m,'r*');
% matches = matches'; N = length(matches);
for i=1:length(p2)
    line([p2(i,1), p3(i,1)], [p2(i,2), p3(i,2)+m], 'Color',[0 0 1] );
end
%% RANSAC
% x2 = [RGB2 d2 p2]';
% x3 = [RGB3 d3 p3]';
% save('X2X3','x2','x3');

%ransacfitRt(x1,x2,30);