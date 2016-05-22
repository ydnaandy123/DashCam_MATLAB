function my_pcd_write( points, fname, format )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    fp = fopen([fname, '.', format], 'w');
    [m, n, p] = size(points);
    if strcmp(format, 'xyz')
    elseif strcmp(format, 'ply')
        fprintf(fp, 'ply\nformat ascii 1.0\ncomment nothing\nelement vertex %d\nproperty float x\nproperty float y\nproperty float z\nproperty float red\nproperty float green\nproperty float blue\nend_header\n', m);
    end
    
    fprintf(fp, '%f %f %f %f %f %f\n', points');    
    
    fclose(fp);
end

