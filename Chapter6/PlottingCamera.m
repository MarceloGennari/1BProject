function [] = PlottingCamera( T_cw )
%PLOTTINGCAMERA This function just plots the Camera Frame. It doesn't add
%up to anything to the code, it just makes me understand a little bit
%better how the objects and the camera are place in the world coordinates
%and makes me validate a little bit of the code I've written so far

%Extract the origin point of the camera in world coordinates
Origin = T_cw(1:3,4);

%Extract the unit directions of the camera frame of reference in world
%coordinates
CameraXDirection = T_cw(1:3,1);
CameraYDirection = T_cw(1:3,2);
CameraZDirection = T_cw(1:3,3);

% Here I define two points for the plotting: one is the origin and the
% other one is a 0.5 meter away point in the direction of the axis, so that
% we can see the axis in the world coordinate system
xaxisPoints = [Origin Origin+500*CameraXDirection];
yaxisPoints = [Origin Origin+500*CameraYDirection];
zaxisPoints = [Origin Origin+500*CameraZDirection];

% Plots the three lines correspondent to the axis of the camera
plot3(xaxisPoints(1,:),xaxisPoints(2,:),xaxisPoints(3,:),'g');
plot3(yaxisPoints(1,:),yaxisPoints(2,:),yaxisPoints(3,:),'y');
plot3(zaxisPoints(1,:),zaxisPoints(2,:),zaxisPoints(3,:),'c');

end
