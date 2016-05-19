%% environment settle
clc;clear;close all;
% run('../../src/vlfeat-0.9.20/toolbox/vl_setup')
% vl_version verbose
%% BOOK SELECT
%--books' corner
book3 = [24 65; 16 462; 624 454; 607 59];
book2 = [40 19; 39 469; 621 466; 596 16];
book1 = [24 42; 24 440; 617 430; 608 42];
%--select book
bookCorner = book3;
Ibook = imread('data/book3.jpg');
%% PART.1-1 & 1-2
%---file read
Iscene = imread('data/scene.jpg');
scene = single(rgb2gray(Iscene));
book = single(rgb2gray(Ibook));
[m,n,p] = size(scene);
[m1,n1,p1] = size(book);
%%---sift
%%--select margin && select dist threshold
margin = 5; thresh = 1.1; %dafualt m=3
[fscene, dscene] = vl_sift(scene,'magnif',margin) ;
[fbook1, dbook1] = vl_sift(book,'magnif',margin) ;
%--book's desriptor match to scene's desriptor
match_index = 1; dscene=dscene'; dbook1=dbook1';
N1 = size(dbook1,1); N2 = size(dscene,1);
%--decide filter
%--for every desriptor in book's
matches = [];
for i = 1:N1
    %--caluate each desriptor in book to all desriptor in scene different
    temp = repmat(dbook1(i,:),N2,1);
    dis = sum((temp - dscene).^2,2);
    %find nearest neightbor
    [values, index] = sort(dis);
    if(values(1)*thresh < values(2)) %--with filter or not
        matches(match_index,:) =[i index(1)];
        match_index = match_index + 1;
    end %--with filter or not
end
%%---visualize
figure;
%--draw the background(cluttered + single)
visualize(1:m,1:n,:) = Iscene;
visualize(1:m1,1+n:n1+n,:) = Ibook;
imshow(visualize);
hold on;
%--plot point
pbook = [fbook1(1,matches(:,1))', fbook1(2,matches(:,1))'];
pscene = [fscene(1,matches(:,2))', fscene(2,matches(:,2))'];
plot(pbook(:,1)+n, pbook(:,2),'g*');
plot(pscene(:,1), pscene(:,2),'r*');
%--plot line
N = length(matches);
for i=1:N
    line([pbook(i,1)+n, pscene(i,1)], [pbook(i,2), pscene(i,2)], 'Color',[0 0 1] );
end
%%---homography
% H = homography(pbook,pscene);
% pt1_transformed = H*[pbook ones(N,1)]';
% pt1_transformed_x = pt1_transformed(1,:)./pt1_transformed(3,:);
% pt1_transformed_y = pt1_transformed(2,:)./pt1_transformed(3,:);
% %--visualize
% figure;
% visualize = Iscene;
% imshow(visualize);
% hold on;
% plot(pt1_transformed_x, pt1_transformed_y,'w*');

%% PART.2-1
%--VLsift
% margin = 5; thresh = 1.3; %dafualt m=3
% [fscene, dscene] = vl_sift(scene,'magnif',margin) ;
% [fbook1, dbook1] = vl_sift(book,'magnif',margin) ;
% [matches,scores] = vl_ubcmatch(dbook1,dscene,thresh);
% pbook = [fbook1(1,matches(1,:))', fbook1(2,matches(1,:))'];
% pscene = [fscene(1,matches(2,:))', fscene(2,matches(2,:))'];
% matches = matches'; N = length(matches);
%--flag, find a homography tramsform or not
successFind = 0;
%--parameter
maxItera = 200;
seedSize = 6;
errorThreshold = 30;
inlierThreshold = floor(0.1*N);
%--initial
bestInlier = zeros(N,1); bestH = zeros(3,3);
display('RANSAC Iteration:');
%--iterately find H
for i=1:maxItera
    %--select seed, pt1(books) corrosponding to pt2(scene) 
    selPoint = randperm(N);
    pt1 = pbook(selPoint(1:seedSize),:);  pt2 = pscene(selPoint(1:seedSize),:);
    %--use seed to calculate H
    H = homography(pt1,pt2);
    %--check the point outside the seed(pto) is a inlier or not by using H
    pto1 = pbook(seedSize+1:N,:); pto2 = pscene(seedSize+1:N,:);
    pto1_trans_h = H*[pto1 ones(N-seedSize,1)]';
    pto1_trans = [pto1_trans_h(1,:)./pto1_trans_h(3,:); pto1_trans_h(2,:)./pto1_trans_h(3,:)]';
    error = sqrt(sum((pto2-pto1_trans).^2, 2));
    %--if(error<threshold) ==> a inlier
    inlier = (error<errorThreshold);  outlier = ~inlier;
    numInlier = sum(inlier); numOutlier = sum(outlier);
    %--if enough inliers
    if(numInlier+seedSize>inlierThreshold)
        display('Find good enoght fitting!!.');
        successFind = 1;
        %--use all this inlier to re-caculate the re-fitted H
        ptt1 = [pt1; pto1(inlier,:)]; ptt2 = [pt2; pto2(inlier,:)]; 
        H = homography(ptt1, ptt2);
        %--use re-fitted H to caculate inliers again
        pt1_trans_h = H*[pbook ones(N,1)]';
        pt1_trans = [pt1_trans_h(1,:)./pt1_trans_h(3,:); pt1_trans_h(2,:)./pt1_trans_h(3,:)]';
        error = sqrt(sum((pscene-pt1_trans).^2, 2));
        inlier = (error<errorThreshold);  outlier = ~inlier;
        numInlier = sum(inlier); numOutlier = sum(outlier);   
        %--choose having most inlier as best H
        if(sum(inlier)>sum(bestInlier))
            bestInlier = inlier;
            bestH = H;
        end
    end
end
H = bestH;
inlier = bestInlier;
outlier = ~inlier;
%%---visualize
figure;
if(successFind)
    %--cavan
    visualize(1:m,1:n,:) = Iscene;
    visualize(1:m1,1+n:n1+n,:) = Ibook;
    imshow(visualize);
    hold on;
    %--inliers
    pbook1Inlier = pbook(inlier,:);
    psceneInlier = pscene(inlier,:);
    plot(pbook1Inlier(:,1)+n, pbook1Inlier(:,2),'b*');
    plot(psceneInlier(:,1), psceneInlier(:,2),'b*');
    for i=1:length(pbook1Inlier)
        line([pbook1Inlier(i,1)+n, psceneInlier(i,1)], [pbook1Inlier(i,2), psceneInlier(i,2)], 'Color',[0 0 1] );
    end
    %--outliers
    pbook1Outlier = pbook(outlier,:);
    psceneOutlier = pscene(outlier,:);
    plot(pbook1Outlier(:,1)+n, pbook1Outlier(:,2),'g*');
    plot(psceneOutlier(:,1), psceneOutlier(:,2),'g*');
    for i=1:length(pbook1Outlier)
        line([pbook1Outlier(i,1)+n, psceneOutlier(i,1)], [pbook1Outlier(i,2), psceneOutlier(i,2)], 'Color',[0 1 0] );
    end
    %--draw book 4 edge
    line([bookCorner(1,1)+n, bookCorner(2,1)+n], [bookCorner(1,2), bookCorner(2,2)], 'Color','y', 'LineWidth',5);
    line([bookCorner(2,1)+n, bookCorner(3,1)+n], [bookCorner(2,2), bookCorner(3,2)], 'Color','b', 'LineWidth',5);
    line([bookCorner(3,1)+n, bookCorner(4,1)+n], [bookCorner(3,2), bookCorner(4,2)], 'Color','g', 'LineWidth',5);
    line([bookCorner(4,1)+n, bookCorner(1,1)+n], [bookCorner(4,2), bookCorner(1,2)], 'Color','r', 'LineWidth',5);
    %--after homography transform
    bookCornerH = H*[bookCorner ones(4,1)]';
    bookCorner = [bookCornerH(1,:)./bookCornerH(3,:); bookCornerH(2,:)./bookCornerH(3,:)]';
    line([bookCorner(1,1), bookCorner(2,1)], [bookCorner(1,2), bookCorner(2,2)], 'Color','y', 'LineWidth',5);
    line([bookCorner(2,1), bookCorner(3,1)], [bookCorner(2,2), bookCorner(3,2)], 'Color','b', 'LineWidth',5);
    line([bookCorner(3,1), bookCorner(4,1)], [bookCorner(3,2), bookCorner(4,2)], 'Color','g', 'LineWidth',5);
    line([bookCorner(4,1), bookCorner(1,1)], [bookCorner(4,2), bookCorner(1,2)], 'Color','r', 'LineWidth',5);
else
    disp('No RANSAC fit was found.');
end
%% PART.2-2
%%---visualize
figure;
if(successFind)
    %--cavan    
    imshow(Iscene);
    hold on;
    %--inliers
    pbook1Inlier = pbook(inlier,:);
    psceneInlier = pscene(inlier,:);
    plot(psceneInlier(:,1), psceneInlier(:,2),'bo');
    %--after homography transform
    pbook1InlierH = H*[pbook1Inlier ones(length(pbook1Inlier),1)]';
    pbook1Inlier = [pbook1InlierH(1,:)./pbook1InlierH(3,:); pbook1InlierH(2,:)./pbook1InlierH(3,:)]';    
    plot(pbook1Inlier(:,1), pbook1Inlier(:,2),'go');
    %--center point
    plot(psceneInlier(:,1), psceneInlier(:,2),'r.');
    plot(pbook1Inlier(:,1), pbook1Inlier(:,2),'r.');
    %--deviation vector line
    for i=1:length(pbook1Inlier)
        line([pbook1Inlier(i,1), psceneInlier(i,1)], [pbook1Inlier(i,2), psceneInlier(i,2)], 'Color',[1 0 0] );
    end
else
    disp('No RANSAC fit was found.');
end
