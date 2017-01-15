%This function estimates a KMatrix based on the iphone7

%% STEPS

% 1. Model a Camera and the KMatrix
% 2. Construct a grid and position it somewhere in space
% 3. For each image:
%   3.1. Place the camera somewhere in space and take a picture
%   3.2. Generate a noisy image of the picture
%   3.3. Add outliers to the noisy image
%   3.4. Estimate homography using RANSAC Algorithm
%   3.5. Store the estimated homography somwhere
% 4. Build Regressor
% 5. Invert using Cholesky Factorization and get estimated KMatrix

noise = 3;
outlier = 0;
maxErr = 2;
nLoops = 200;
NumberImages = 6;
nImages = NumberImages;
E0 = [];

%% 1. Camera
%This is based on code written for Chpater 5
%Build Camera based on Iphone 7
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

if CameraHeight > CameraWidth
    CameraScale = 2.0/CameraHeight;
else
    CameraScale = 2.0/CameraWidth;
end

%% 2. Build Grid
%Build grid and Grid corners in their reference frame
GridSize = 1000;
Spacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, Spacing);

GridScale = 2.0/GridSize;


%Position Grid
%THis is also based on code written for Chapter 5
%Create transformation matrix from grid reference to world reference
T_ow = PositionObject();

%% 3. Images and Homography
HomogData = cell(NumberImages,3);



for k = 1:20
    E0(k) = 0;
    searching = 1;
    while searching == 1
        searching = 0;
        TotalPoints = 0;
        for i = 1:NumberImages
           %3.1.  Place Camera
           %Create Transformation matrix from camera reference to world reference
           T_cw = FillImage(T_ow,KMatrix,CameraHeight,CameraWidth,GridCorners,GridSize);

           %Takes a picture
           GridPointsPhoto = LetMeTakeASelfie(Grid,T_ow,KMatrix,T_cw);
           [GridPointsInPhoto EquivalentGrid]= TrimPicture(GridPointsPhoto,Grid,CameraWidth,CameraHeight);
           EquivGrid = [EquivalentGrid(1,:); EquivalentGrid(2,:); EquivalentGrid(4,:)];

           %3.2. Build some noise
           [NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(GridPointsInPhoto, EquivalentGrid,noise);

           %3.3. Add some outliers
           FinalPointsInImage = ImplOutlier(NoisyPointsInImage,outlier,CameraWidth,CameraHeight);

           %3.4. Estimate Homography using RANSAC
           [Homog BestConsensus] = RansacEstimation3(FinalPointsInImage, EquivGrid, maxErr, nLoops);

           Consensus = Homog*EquivGrid;
           s = size(Consensus);
           for j = 1:s(2)
              Consensus(:,j)  = Consensus(:,j)/Consensus(3,j);
           end
           
           TotalPoints = TotalPoints + s(2);
           HomogData{i,1} = Homog;
           HomogData{i,2} = Consensus;
           HomogData{i,3} = EquivGrid;
           HomogData{i,4} = GridPointsInPhoto;
        end
        
        %% 4. Building Regressor

        %Building matrix A
        A = [];
        for i = 1:NumberImages
           A = [A;getPsi(HomogData{i,1})]; 
        end

        %Building Regressor using singular vector decomposition
        [U,D,V] = svd(A,'econ');
        d = diag(D);
        [m,I] = min(d);
        PhiVec = V(:,I);

        Phi = [PhiVec(1) PhiVec(2) PhiVec(3)
                PhiVec(2) PhiVec(4) PhiVec(5)
                PhiVec(3) PhiVec(5) PhiVec(6)];

        %% 5. Estimating KMatrix using Cholesky
        e = eig(Phi);
        for i = 1:3
            if (e(i))<=0
                searching = 1;
            end
        end
        
        if searching == 0
            InvK = chol(Phi);
            K = InvK\eye(3);

            K = K/K(3,3);
        end
    end
    %% Testing KMatrix
    Data = HomogData;
    Persp = getAxisAngle(K, HomogData);

    for j = 1:nImages

        Axis = Persp{j,1};
        t = Persp{j,2};
        PointsInImage = Data{j,2};
        EquivGrid = Data{j,3};

        %Calculate the error vector e for each image
        e = ComputeErrorVector(K, Axis,t, PointsInImage,EquivGrid);

        % Tranform from 2xnMeasurements to vector 2*nMeasurementsx1
        e = e(:);
        % e'*e is the sum of the square of the errors and E0 is the initial
        % error
        E0(k) = E0(k) + 0.5*(e'*e);
    end
    E0(k) = E0(k)/TotalPoints;
end




