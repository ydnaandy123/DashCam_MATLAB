clc;clear;close all;
% google_search = 'http://maps.google.com/cbk?output=json&cb_client=maps_sv&v=4&dm=1&pm=1&ph=1&hl=en&panoid=OdH7fZyrCUDrpEx4CvLLYA';
% matlab_results = (urlread(google_search));


fileID = fopen('jsonData/header.json', 'r');
json_file = fscanf(fileID,'%s');
header = parse_json(json_file);

fileID = fopen('jsonData/indices.json', 'r');
json_file = fscanf(fileID,'%s');
indices = parse_json(json_file);

% fileID = fopen('jsonData/plane.json', 'r');
% json_file = fscanf(fileID,'%s');
% plane = parse_json(json_file);
%disp(matlab_results{1}.Data.image_width)


