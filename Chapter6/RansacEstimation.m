function [ Homog BestConsensus ] = RansacEstimation(PointsInImage, EquivGrid, MaxError, n)
%RANSACESTIMATION This function implements the RANSAC algorithm to reject
%outliers in the image.

% TODO
% NOTICE THAT WE HAVEN'T USED MAX ERROR AND I JUST USED ONE 4POINTS
% CONSENSUS TO ESTIMATE THE HOMOGRAPHY. THIS IS NOT THE FULL RANSAC METHOD
% YET. WE NEED TO ADDRESS THAT
%

%% STEPS IN THIS FUNCTION

% 1. randomly choose 4 points in the image
% 2. calculate homography based on those points
% 3. calculate position of all other points based on this homography
% 4. compare points generated by homography with image
% 5. calculate number of points within MaxError difference
% 6. run 1-5 n times
% 7. at the end, select the 4 points that gave the biggest number of points within MaxError difference

%Gets total number of [u,v] points and consequently [x,y] points
numberOfPoints = length(PointsInImage(1,:));

%This Matrix will keep track of the random points chosen
%It will be a 4xn Matrix, this way we can identify the points in the
%iteration that gave the lowest consensus.
RandomPoints =[];
for j = 1:n
 
    %Generate 4 random numbers
    r = randperm(numberOfPoints);
    r = vec2mat(r,4);
    
    %Concatanate these random points to the Matrix that keeps track of all
    %the random Points Generated
    RandomPoints = [RandomPoints r(:,1)];
    
    %Gets the (u,v) coordinate of the four random points
    FourPoints = [PointsInImage(:,RandomPoints(1,j))];
    for i=2:4
       FourPoints = [FourPoints PointsInImage(:,RandomPoints(i,j))];
    end
    
    %Gets the (x,y) coordinates of the corresponding four random points
    FourEquivPoints = [EquivGrid(:,RandomPoints(1,j))];
    for i=2:4
        FourEquivPoints = [FourEquivPoints EquivGrid(:,RandomPoints(i,j))];
    end
    
    
    Homography = GetHomographyLSM(FourPoints, FourEquivPoints);

    Estimation = Homography*EquivGrid;
    s = length(Estimation(1,:));
    for k = 1:s
       Estimation(1:2,k)  = Estimation(1:2,k)/Estimation(3,k);
    end
    Estimation(3,:) = [];
    
    %Calculating Consensus
    MatrixDiff = PointsInImage -Estimation;
    Consensus(j) = 0;
    for k = 1:length(MatrixDiff(1,:))
        %This gets the average pixel difference between the estimated and
        %the ones in the picture
       Consensus(j) = Consensus(j) + norm(MatrixDiff(1:2,k)); 
    end
    
    Consensus(j) = Consensus(j)/length(MatrixDiff(1,:));
    
end

%Now we are going to get the set of errors that are less than or equal to
%the one given in the function and use the points corresponding to those
%errors to find the least square estimate of the matrix
BestConsensus = [];
for i = 1:length(Consensus)
    if Consensus(i) < MaxError
        BestConsensus = [BestConsensus Consensus(i)];
    end
end

% Now that we have a set of errors, we are going to find the indeces of
% those errors in our matrix
for i = 1:length(BestConsensus)
    Index(i) = find(Consensus==BestConsensus(i));
end

%Gets four equivalent points of the best consensus
FourPoints = [];
FourEquivPoints = [];
for k = 1:length(Index)
    for i=1:4
       FourPoints = [FourPoints PointsInImage(:,RandomPoints(i,Index(k)))];
       FourEquivPoints = [FourEquivPoints EquivGrid(:,RandomPoints(i,Index(k)))];
    end
end
    
Homog = GetHomographyLSM(FourPoints, FourEquivPoints);
end

