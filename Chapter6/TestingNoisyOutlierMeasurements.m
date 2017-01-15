%% STEPS TAKEN IN THIS SCRIPT
%1. Build Camera
%2. Build Grid
%3. Position Grid randomly
%4. Position Camera randomly so that the grid fills the Image
%5. Building Phi and getting Homography without noise (NOT WORKING< REDO)
%6. Build some noise in the (u,v) coordinates
%7. Add some outliers
%8. Find Best Estimation Homography using RANSAC approach
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
T_cw = FillImage(T_ow,KMatrix,CameraHeight,CameraWidth,GridCorners,GridSize);

%Takes a picture
GridPointsPhoto = LetMeTakeASelfie(Grid,T_ow,KMatrix,T_cw);
[GridPointsInPhoto EquivalentGrid]= TrimPicture(GridPointsPhoto,Grid,CameraWidth,CameraHeight);

%% 5. Building Phi Matrices and getting Homography without noise
[A P] = AMatrix(length(GridPointsInPhoto(1,:)),GridPointsInPhoto,EquivalentGrid);
H = A\P;
HomographyCorrect = ConstructHomography(H);
EquivGrid = [EquivalentGrid(1,:);EquivalentGrid(2,:);EquivalentGrid(4,:)];

%% 6. Build some noise in the (u,v) and (x,y) coordinates
%Build some noise
[NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,0.5);

%Calculate first attempt Homog Noisy Measurement using least square
HomogNoisy = GetHomographyLSM(NoisyPointsInImage,NoisyEquivGrid);
NewPoints = HomogNoisy*EquivGrid;

s = size(NewPoints);
for j = 1:s(2)
   NewPoints(1:2,j)  = NewPoints(1:2,j)/NewPoints(3,j);
end
NoisyEquivGrid = [NoisyEquivGrid; ones(1,length(NoisyEquivGrid(1,:)))];

%% 7. Add some outliers
%This code adds some outliers in the (u,v) coordinates.
FinalPointsInImage = ImplOutlier(NoisyPointsInImage,0.05,CameraWidth,CameraHeight);

for k = 1:50
    for i = 1:50
        %% 8. Find Best Estimation Homography using RANSAC approach
        [Homog Consensus BestConsensus] = RansacEstimation3(FinalPointsInImage, EquivGrid, 2, k);

        FinalPoints = Homog*EquivGrid;
        s = size(FinalPoints);
        for j = 1:s(2)
           FinalPoints(1:2,j)  = FinalPoints(1:2,j)/FinalPoints(3,j);
        end

        e = FinalPoints(1:2,:) - FinalPointsInImage(1:2,:);
        e =e(:);
        TotalE(1,i) = e'*e;
        TotalE(2,i) = BestConsensus;
    end
    Statistics(1,k) = mean(TotalE(1,:));
    Statistics(2,k) = mean(TotalE(2,:));
    Statistics(3,k) = k;
end
TotalE(1,:) = log(TotalE(1,:));

TotalE