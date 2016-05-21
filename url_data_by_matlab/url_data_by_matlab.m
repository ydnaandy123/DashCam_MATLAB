clc;clear;close all;
addpath('../lib');
google_search = 'http://maps.google.com/cbk?output=json&cb_client=maps_sv&v=4&dm=1&pm=1&ph=1&hl=en&panoid=OdH7fZyrCUDrpEx4CvLLYA';
matlab_results = parse_json(urlread(google_search));
% %disp(matlab_results{1}.Data.image_width)
% tile_width = str2double(matlab_results{1}.Data.tile_width);
% tile_height = str2double(matlab_results{1}.Data.tile_height);
% index_map = zeros(tile_height, tile_width);
depth_raw = matlab_results{1}.model.depth_map;

%% Append '=' in order to make the length of the array a multiple of 4
while mod(length(depth_raw), 4) ~= 0
    strcat(depth_raw, '=');
end
%% Replace '-' by '+' and '_' by '/'
depth_raw = strrep(depth_raw, '-', '+');
depth_raw = strrep(depth_raw, '_', '/');
%% Decode and decompress data
compressedDepthMapData = base64decode(depth_raw);
decompressedDepthMap = zlibdecode(compressedDepthMapData);