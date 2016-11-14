% SIMULATION TASK 1 CHAPTER 5.3

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


%% BUILD OBJECT IN ITS OWN REFERENCE FRAME
    %Here I create a 1 x 1 x 1 cube with vertices
    %(0,0,0),(1,0,0),(1,1,0),(0,1,0),(0,0,1),(0,1,1),(1,0,1),(1,1,1);
Cube = BuildCube;

%% Position the Object in Space
T_ow = PositionObject;
Cube = [Cube; ones(1,length(Cube(1,:)))];

CubeInWorldReference = T_ow*Cube;

xw = CubeInWorldReference(1,:);
yw = CubeInWorldReference(2,:);
zw = CubeInWorldReference(3,:);

figure;
plot3(xw, yw, zw);
axis equal

%% Position Camera in Space


