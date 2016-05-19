clear;clc;
Ic = im2double(imread('img/1.png'));
Id = im2double(imread('img/1d.png'));
[m,n,p] = size(Id);
Ic = imresize(Ic, [m,n]);
Iout1 = zeros(m,n,6);
Iout1(:,:,1) = Ic(:,:,1);
Iout1(:,:,2) = Ic(:,:,2);
Iout1(:,:,3) = Ic(:,:,3);
Iout1(:,:,4) = Id(:,:,1);
Iout1(:,:,5) = ones(m,1)*(1:n);
Iout1(:,:,6) = (1:m)'*ones(1,n);
imshow(Iout1(:,:,1:3));
save('')