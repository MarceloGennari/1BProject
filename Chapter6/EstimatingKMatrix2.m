%The number of calibration images to use
nImages = 6;

%Build Camera
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%Build Grid
GridSize = 1000;
GridSpacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, GridSpacing);

% Position Grid
T_ow = PositionObject();

%move grid and grid corners to world referencef frame
GridW = T_ow*Grid;
GridCornersW = T_ow*GridCorners;

%Define Scaling to use
if CameraHeight > CameraWidth
    CameraScale = 2.0/CameraHeight;
else
    CameraScale = 2.0/CameraWidth;
end
GridScale = 2.0 / GridSize;

HomogData = cell(nImages,3);

for CalImage = 1:nImages
    Estimating =1 ;
    while Estimating == 1
        
        Estimating = 0;
                
        %% 4. Position Camera
        %Create Transformation matrix from camera reference to world reference
        T_cw = FillImage(T_ow,KMatrix,CameraHeight,CameraWidth,GridCorners,GridSize);

        %Takes a picture
        GridPointsPhoto = LetMeTakeASelfie(Grid,T_ow,KMatrix,T_cw);
        [GridPointsInPhoto EquivalentGrid]= TrimPicture(GridPointsPhoto,Grid,CameraWidth,CameraHeight);
        EquivGrid = [EquivalentGrid(1,:);EquivalentGrid(2,:);EquivalentGrid(4,:)];
        %% 6. Build some noise in the (u,v) and (x,y) coordinates
        %Build some noise
        [NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,0.5);
        
        %% 7. Add some outliers
        %This code adds some outliers in the (u,v) coordinates.
        FinalPointsInImage = ImplOutlier(NoisyPointsInImage,0.05,CameraWidth,CameraHeight);
        
        %Now Scale the grid and the camera to [-1 1] to improve the
        %conditioning of the Homography estimation
        FinalPointsInImage(1:2,:) = FinalPointsInImage(1:2,:)*CameraScale-1.0;
        EquivGrid = EquivGrid*GridScale;
        
        % Performs the RANSAC Estimation
        [Homog Consensus BestConsensus] = RansacEstimation4(FinalPointsInImage, EquivGrid, 2*CameraScale, 200);
        
        
        if Homog(3,3)>0
            Correspond = Homog*EquivGrid;
            
            %This worked
            HomogData{CalImage,1} = Homog;
            HomogData{CalImage,2} = Correspond;
            HomogData{CalImage,3} = EquivGrid;
        else
            %The estimation failed
            Estimating = 1;
        end
    end
end

%Building matrix A
A = [];
for i = 1:nImages
   A = [A;getPsi(HomogData{i,1})]; 
end

%Building Regressor using singular vector decomposition
[U,D,V] = svd(A,'econ');
d = diag(D);
[m,I] = min(d);
PhiVec = V(:,I);

%The matrix needs to be positive definite, so PhiVec(1) needs to be positive

if PhiVec(1) < 0
   PhiVec = -PhiVec; 
end

%Constructing Phi
Phi = [PhiVec(1) PhiVec(2) PhiVec(3)
        PhiVec(2) PhiVec(4) PhiVec(5)
        PhiVec(3) PhiVec(5) PhiVec(6)];
    
%Check Positive Definite
e = eig(Phi);
for j=1:3
   if e(j) <=0
      error('The Cholesky product is not positive definite'); 
   end
end

%% 5. Estimating KMatrix using Cholesky
InvK = chol(Phi);
K = InvK\eye(3);

% The scaling Grid has no impact on the scaling of K
% Normalize K
K = K/K(3,3);
        
realK = K;

% Add one to the translation part of the image
realK(1,3) = realK(1,3) + 1;
realK(2,3) = realK(2,3) + 1;

%Rescale back to pixels
realK(1:2,1:3) = realK(1:2,1:3)/CameraScale;

realK

%OptKMatrix = OptimizeKMatrix2(K,HomogData);






