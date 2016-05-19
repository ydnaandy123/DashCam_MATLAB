clc;clear;close all;
google_search = 'http://maps.google.com/cbk?output=json&cb_client=maps_sv&v=4&dm=1&pm=1&ph=1&hl=en&panoid=OdH7fZyrCUDrpEx4CvLLYA';
matlab_results = parse_json(urlread(google_search));
%disp(matlab_results{1}.Data.image_width)

tile_width = str2double(matlab_results{1}.Data.tile_width);
tile_height = str2double(matlab_results{1}.Data.tile_height);
index_map = zeros(tile_height, tile_width);

%imshow(index_map)

depth_raw = matlab_results{1}.model.depth_map;

while mod(length(depth_raw), 4) ~= 0
    strcat(depth_raw, '=');
end

depth_raw = strrep(depth_raw, '-', '+');
depth_raw = strrep(depth_raw, '_', '/');

compressedDepthMapData = base64decode(depth_raw);
decompressedDepthMap = zlibdecode(compressedDepthMapData);