% SIMULATION TASK 1 CHAPTER 5.3

clear all
close all

%% STEPS:
% Construct Camera Model
    %Achieved by function CameraModel
% Construct an object in its own frame
    %Achieved by function BuildCube    
% Position the object in space
    %Achieved by function PositionObject
% Position the camera so that it is likely that the object can be seen
    %Achieved by function PositionCamera
% Look at what we have
    %Achieve by function LetMeTakeASelfie

%% Construct Camera Model
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%% BUILD OBJECT IN ITS OWN REFERENCE FRAME
    %Here I create a 1 x 1 x 1 cube with vertices
    %(0,0,0),(1,0,0),(1,1,0),(0,1,0),(0,0,1),(0,1,1),(1,0,1),(1,1,1);
Cube = BuildCube;

%% Position the Object in Space
T_ow = PositionObject;

Cube = [Cube; ones(1,length(Cube(1,:)))];


%% Position Camera in Space
T_cw = PositionCamera(T_ow);

%% Taking a selfie
LetMeTakeASelfie(Cube,T_ow,KMatrix,CameraHeight,CameraWidth,T_cw);

%% PLOTS
%Here I will plot the situation in the world coordinate frame and in the
%object coordinate frame just to give us an idea of what is going on

% Plotting the cube in its own reference frame
figure
plot3(Cube(1,:), Cube(2,:), Cube(3,:));
title('Object Reference');

% Here I translate the cube to the world reference frame
CubeInWorldReference = T_ow*Cube;

% Here I get the x, y and z vector of points of the cube in the world
% coordinate frame
xw = CubeInWorldReference(1,:);
yw = CubeInWorldReference(2,:);
zw = CubeInWorldReference(3,:);

figure; % Create new figure that will represent world coordinate fram
hold on % Make plots of cube and camera in the same figure
plot3(xw, yw, zw); %Plots Cube in world reference frame
PlottingCamera(T_cw); %Plots camera in world reference frame
title('World Reference');
axis equal %This just makes sure that the cube will look like a cube in our plot