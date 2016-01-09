function H = homography( p1, p2 )

%%---homography
%--wrap p1 to p2
%--H*p1 = p2
%--p1=[X Y 1];; p2=[x y 1]';
%--[X Y 1 0 0 0 -xX -xY -x] = 0
%--[0 0 0 X Y 1 -yX -yY -y] = 0
rowNum = length(p2);
%--change[x y] to [x y]'
xi_array = reshape(p2', rowNum*2, 1);
X = zeros(rowNum*2, 1); Y = zeros(rowNum*2, 1);
%--create[X Y]
%--create[X Y]
for i=1:2:rowNum*2
    X(i:i+1) = p1((i+1)/2, 1);
    Y(i:i+1) = p1((i+1)/2, 2);
end
%--create[-xX -xY -x]
%--create[-yX -yY -y]
xyX = -xi_array.*X; xyY = -xi_array.*Y;
%--create [X Y 1 0 0 0]
A = zeros(rowNum*2, 3);     
for i=1:rowNum
    A(i*2-1, 1:2) = p1(i, :); 
    A(i*2-1,3) = 1;
end
%--create [X Y 1 0 0 0]
%--create [0 0 0 X Y 1]
B = A(1:rowNum*2-1, :);
B = [0 0 0; B];
A = [A B];
%--combine
%--[X Y 1 0 0 0 -xX -xY -x]
%--[0 0 0 X Y 1 -yX -yY -y]
A = [A xyX xyY -xi_array];

% SQ_A  = A' * A;
% [V, D]= eig(SQ_A);
% P = reshape(V(:,1), 3, 3);
% H = P';

% seconde way
[S2 V2 D2] = svd(A);
P2 = reshape(D2(:,9), 3, 3);
P2 = P2';
H = P2;

end

