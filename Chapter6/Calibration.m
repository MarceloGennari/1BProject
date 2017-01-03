%% STEPS TAKEN IN THIS SCRIPT
%1. Build Camera
%2. Build Grid
%3. Position Grid randomly
%4. Position Camera randomly so that the grid fills the Image
%5. Building Phi and getting Homography without noise (NOT WORKING< REDO)
%6. Build some noise in the (u,v) coordinates
%7. Add some outliers
%8. Find Best Estimation Homography using RANSAC approach (NOT WORKING
%PROPERLY) REVIEW
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
HomographyCorrect = ConstructHomography(H);
EquivGrid = [EquivalentGrid(1,:);EquivalentGrid(2,:);EquivalentGrid(4,:)];

%% 6. Build some noise in the (u,v) and (x,y) coordinates
%Build some noise
[NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,5);

%Calculate first attempt Homog Noisy Measurement using least square
%solution. I am using all of the points to make sure we get a good estimate

HomogNoisy = GetHomographyLSM(NoisyPointsInImage,NoisyEquivGrid);
NewPoints = HomogNoisy*EquivGrid;

s = size(NewPoints);
for j = 1:s(2)
   NewPoints(1:2,j)  = NewPoints(1:2,j)/NewPoints(3,j);
end
NoisyEquivGrid = [NoisyEquivGrid; ones(1,length(NoisyEquivGrid(1,:)))];

%% 7. Add some outliers
FinalPointsInImage = ImplOutlier(NoisyPointsInImage,0.05,CameraWidth,CameraHeight);

%% 8. Find Best Estimation Homography using RANSAC approach
[Homog BestConsensus] = RansacEstimation(FinalPointsInImage, EquivGrid, 20, 2000);

FinalPoints = Homog*EquivGrid;
s = size(FinalPoints);
for j = 1:s(2)
   FinalPoints(1:2,j)  = FinalPoints(1:2,j)/FinalPoints(3,j);
end

%% LAST. Plot everything in world coordinates and in camera view
%Here we plot the Picture and make sure the axis goes from 0 to CamerHeigth
%from the top to bottom using the axis ij command.
plot(GridPointsInPhoto(1,:), GridPointsInPhoto(2,:),'r.');
hold on
axis ij
title('Picture taken by the camera');
axis([0 CameraWidth 0 CameraHeight])

%plot in world reference frame
figure
plot3(GridW(1,:),GridW(2,:),GridW(3,:),'r.');
hold on
plot3(GridCornersW(1,:),GridCornersW(2,:),GridCornersW(3,:),'b.','markers',1);
PlottingCamera(T_cw);