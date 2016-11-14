function [Cube] = BuildCube()
%BuildCube Build a 1m x 1m x 1m cube

%  To make it easier to plot, I drew the cube as it is someone drawing it
%  without taking the pen out of the "board". a represents the vector from
%  0 to 1, b represents the vector from 1 to 0, c and d are constant
%  vectors of 0 and 1 respectively

% To plot the cube in three D we can simply do:
% plot3(Cube(1,:),Cube(2,:),Cube(3,:))
a = linspace(0,1);
b = linspace(1,0);
c = ones(1,100)*0;
d = ones(1,100)*1;

x = [a d d d b c a d b c c c c c a d];
y = [c a d b c a d d d d d b c c c c];
z = [c c a d d d d b c a b c a b c a];

Cube = [x;y;z];

%plot3(Cube(1,:),Cube(2,:),Cube(3,:));
%axis([-0.5 1.5 -0.5 1.5 -0.5 1.5]);
%xlabel('x');
%ylabel('y');
%zlabel('z');
end

