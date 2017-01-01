%% STEPS TAKEN IN THIS SCRIPT
%1. Build Camera
%2. Build Grid
%3. Position Grid randomly
%4. Position Camera randomly so that the grid fills the Image
%5. Building Phi and getting Homography without noise (NOT WORKING< REDO)
%6. Build some noise in the (u,v) coordinates
%last. plot everything for analysis / validation

%% 1. Camera
%This is based on code written for Chpater 5
%Build Camera based on Iphone 7
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%% 2. Build Grid
%Build grid and Grid corners in their reference frame
GridSize = 1000;
Spacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, Spacing);

%% 3. Position Grid
%THis is also based on code written for Chapter 5
%Create transformation matrix from grid reference to world reference
T_ow = PositionObject();

%move grid and grid corners to world referencef frame
GridW = T_ow*Grid;
GridCornersW = T_ow*GridCorners;

%% 4. Position Camera
%Create Transformation matrix from camera reference to world reference
T_cw = FillImage(T_ow,KMatrix,CameraHeight,CameraWidth,GridCornersW,GridSize);

%Takes a picture
GridPointsPhoto = LetMeTakeASelfie(GridW,T_ow,KMatrix,CameraHeight,CameraWidth,T_cw);
[GridPointsInPhoto EquivalentGrid]= TrimPicture(GridPointsPhoto,Grid,CameraWidth,CameraHeight);

%% 5. Building Phi Matrices and getting Homography without noise
[A P] = AMatrix(8,GridPointsInPhoto,EquivalentGrid);

H = A\P;

Homog = [H(1,1) H(2,1) H(3,1)
         H(4,1) H(5,1) H(6,1)
         H(7,1) H(8,1) 1];

EquivGrid = [EquivalentGrid(1,:);EquivalentGrid(2,:);EquivalentGrid(4,:)];

%% 6. Build some noise in the (u,v) and (x,y) coordinates


%Build some noise
[NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,0.01);

%Calculate first attempt Homog Noisy Measurement using least square
%solution
[A P] = AMatrix(40,NoisyPointsInImage,NoisyEquivGrid);

H = (A'*A)\A'*P;

HomogNoisy = [H(1,1) H(2,1) H(3,1)
         H(4,1) H(5,1) H(6,1)
         H(7,1) H(8,1) 1];
     
MatrixDiff = HomogNoisy-Homog;

NewPoints = HomogNoisy*EquivGrid;

s = size(NewPoints);
for j = 1:s(2)
   NewPoints(1:2,j)  = NewPoints(1:2,j)/NewPoints(3,j);
end
modError = det(MatrixDiff^2);

%% LAST. Plot everything in world coordinates and in camera view
%Here we plot the Picture and make sure the axis goes from 0 to CamerHeigth
%from the top to bottom using the axis ij command.
plot(GridPointsInPhoto(1,:), GridPointsInPhoto(2,:),'r.');
hold on
axis ij
title('Picture taken by the camera');

%plot in world reference frame
figure
plot3(GridW(1,:),GridW(2,:),GridW(3,:),'r.');
hold on
plot3(GridCornersW(1,:),GridCornersW(2,:),GridCornersW(3,:),'b.','markers',15);
PlottingCamera(T_cw);