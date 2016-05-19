clear;clc;
load('cd1'); 
load('cd2'); 

Rt = align2RGBD(Iout1(1:10,1:10,:), Iout2(1:10,1:10,:));