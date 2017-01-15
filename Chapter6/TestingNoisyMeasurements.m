%% STEPS TAKEN IN THIS SCRIPT
%1. Build Camera
%2. Build Grid

% FOR EACH LOOP

%3. Position Grid randomly
%4. Position Camera randomly so that the grid fills the Image
%6. Build some noise in the (u,v) coordinates
%7. Add some outliers
%8. Find Best Estimation Homography using RANSAC approach
%last. plot everything for analysis / validation

clear all

%% 1. Camera
%This is based on code written for Chpater 5
%Build Camera based on Iphone 7
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%% 2. Build Grid
%Build grid and Grid corners in their reference frame
GridSize = 1000;
Spacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, Spacing);

%% SETTING LEVEL TO BE TESTED
level = 0.1;

%Finding Ideal Mean and Variance for Half-Normal Distribution
idealMean = level*sqrt(2/pi);
idealVar = level^2*(1-(2/pi));

for it = 1:100
    %% 3. Position Grid
    %THis is also based on code written for Chapter 5
    %Create transformation matrix from grid reference to world reference
    T_ow = PositionObject();

    %move grid and grid corners to world referencef frame
    GridW = T_ow*Grid;
    GridCornersW = T_ow*GridCorners;

    %% 4. Position Camera
    %Create Transformation matrix from camera reference to world reference
    T_cw = FillImage(T_ow,KMatrix,CameraHeight,CameraWidth,GridCorners,GridSize);

    %Takes a picture
    GridPointsPhoto = LetMeTakeASelfie(Grid,T_ow,KMatrix,T_cw);
    [GridPointsInPhoto EquivalentGrid]= TrimPicture(GridPointsPhoto,Grid,CameraWidth,CameraHeight);
    EquivGrid = [EquivalentGrid(1,:);EquivalentGrid(2,:);EquivalentGrid(4,:)];

    %% 6. Build some noise in the (u,v) and (x,y) coordinates
    %Build some noise
    [NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,level);

    %Calculate first attempt Homog Noisy Measurement using least square
    HomogNoisy = GetHomographyLSM(NoisyPointsInImage,NoisyEquivGrid);
    NewPoints = HomogNoisy*EquivGrid;

    s = size(NewPoints);
    for j = 1:s(2)
       NewPoints(1:2,j)  = NewPoints(1:2,j)/NewPoints(3,j);
    end
    
    %% ERROR MATRIX
    Error1 = NewPoints(1:2,:) - NoisyPointsInImage(1:2,:);
    Error2 = NewPoints(1:2,:) - GridPointsInPhoto(1:2,:);
    
    for k = 1:length(Error1(1,:))
       E1(k) = norm(Error1(:,k));
       E2(k) = norm(Error2(:,k));
    end
    
    MeanError1(it) = mean(E1);
    MeanError2(it) = mean(E2);
    VarianceError1(it) = var(E1);
    VarianceError2(it) = var(E2);
end

meanError1 = mean(MeanError1);
varError1 = mean(VarianceError1);
meanError2 = mean(MeanError2);
varError2 = mean(VarianceError2);

Results = [meanError1 varError1 meanError2 varError2]