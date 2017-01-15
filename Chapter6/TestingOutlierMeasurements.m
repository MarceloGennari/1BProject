
numberOfLoops = 200;
percentageOfOutliers = 0.2;
Results = [];

%% 1. Camera
%This is based on code written for Chpater 5
%Build Camera based on Iphone 7
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%% 2. Build Grid
%Build grid and Grid corners in their reference frame
GridSize = 1000;
Spacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, Spacing);

     %% Calculating ideal percentage
     o = length(Grid(1,:))*percentageOfOutliers;
     i = length(Grid(1,:))-o;
     den = (o+i)*(o+i-1)*(o+i-2)*(o+i-3);
     num = o*((o-1)*(o-2)*(o-3)+4*(o-1)*(o-2)*i+6*(o-1)*i*(i-1)+4*i*(i-1)*(i-2));
     idealPerc = num/den;
     
     y = percentageOfOutliers;
     idealPerc2 = y^4+4*y^3*(1-y)+6*y^2*(1-y)^2+4*y*(1-y)^3;
     
for k = 1:20;
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

    %% 7. Add some outliers
    %This code adds some outliers in the (u,v) coordinates.
    [FinalPointsInImage nOutliers]= ImplOutlier(GridPointsInPhoto,percentageOfOutliers,CameraWidth,CameraHeight);

    %% 8. Find Best Estimation Homography using RANSAC approach
    [Homog Consensus BestConsensus] = RansacEstimation3(FinalPointsInImage(1:2,:), EquivGrid, 0.1, numberOfLoops);
     
     %%Percentage of loops that got at least one outlier
     out = 0;
     for i = 1:length(Consensus)
         if Consensus(i) < length(FinalPointsInImage(1,:))-nOutliers
             if Consensus(i) ~= 0
                out = out+1;
             else
                if rand(1,1)<percentageOfOutliers
                    out=out+1;
                end
             end
         end
     end
     perc = out/numberOfLoops;     
     
     Results(k,:) = [percentageOfOutliers perc idealPerc idealPerc2];
end;

Result = mean(Results)