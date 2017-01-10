function [ KMatJac, FrameJac ] = Jacobian(KMatrix, Axis, Translation, PointsInImage, EquivGrid )
%JACOBIAN This function takes the 5 parameters of the KMatrix and the 6
%parameters of one Image and returns two blocks: the 5x2n corresponding to
%the partial derivatives with respect to the changes of the parameters in
%the KMatrix and the 6x2n coresponding to the partial derivatives with
%respect to the changes of the parameters in the Axis and Translation
%matrices.


%   STEPS:
%   1. Find the Original Estimation
%   2. For Each Image:
%   3. For the 5x2n Block:
%       3.1 Disturb one of the parameters
%       3.2 Recalculate the Estimation
%       3.3 Take the difference of the Recalculated and the Original
%       3.4 Divide by the disturbance of the parameter
%   4. For the 6x2n Block:
%       4.1 Disturb one of the parameters
%       4.2 Recalculate the Estimation
%       4.3 Take the Difference of the Recalculated and the Original
%       4.4 Divide by the disturbance of the parameter

%   Now, the disturbances will depend on the parameter. So for now I will
%   assume a disturbance of 1% of the value of the parameter.

%   Unfortunately, the matrices are in the form:
%   u1 u2 u3 ...        x1 x2 x3 ...
%   v1 v2 v3 ... and    y1 y2 y3 ...
%   1  1  1  ...         1  1  1 ...

% So I will first transform everything to the form given in the notes:
% First in case EquivGrid is not in Homogenous Coordinates:

if length(EquivGrid(:,1))<4
   s = length(EquivGrid(1,:));
   EquivGrid(4,:) = EquivGrid(3,:);
   EquivGrid(3,:) =  zeros(1,s);
end

R = RodriguesMatrix2(Axis);
EstimatedPoints = KMatrix*[eye(3) zeros(3,1)]*[R Translation; zeros(1,3) 1]*EquivGrid;

 s = size(EstimatedPoints);
   for j = 1:s(2)
      EstimatedPoints(1:2,j)  = EstimatedPoints(1:2,j)/EstimatedPoints(3,j);
   end
   
EstimatedPoints = EstimatedPoints(1:2,:);

% Here it transforms from a matrix of points to a vector
EstimatedPoints = EstimatedPoints(:);

%Gets number of Images
nImage = length(EquivGrid(1,:));

%% Calculating KMatJac
% Since there are 5 Parameters in the KMatrix and all have difference order
% of magnitudes of disturbances, I will create a 5 cell with the
% disturbance matrices in each of them:
DisK = cell(5);
DisK{1} = [0.01 0 0; 0 0 0; 0 0 0];
DisK{2} = [0 0.0001 0; 0 0 0; 0 0 0];
DisK{3} = [0 0 0.025; 0 0 0; 0 0 0];
DisK{4} = [0 0 0; 0 0.01 0; 0 0 0];
DisK{5} = [0 0 0; 0 0 0.025; 0 0 0];

for k = 1:5
    % Disturbing KMatrix:
    KDist = KMatrix + DisK{k};
    EstPointsDist = KDist*[eye(3) zeros(3,1)]*[R Translation; zeros(1,3) 1]*EquivGrid;
    
       s = size(EstPointsDist);
       for j = 1:s(2)
          EstPointsDist(1:2,j)  = EstPointsDist(1:2,j)/EstPointsDist(3,j);
       end
   
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);

    % This is the df1 / dk1 column
    KMatJac(:,k) = (EstPointsDist-EstimatedPoints)/max(max(DisK{k}));
end

%% CALCULATING FRAME JAC

%For the same reason I used for the KMatrix, I will create 2 a 3 cells with
%disturbances
AxisCell = cell(3);
AxisCell{1} = [0.005; 0; 0];
AxisCell{2} = [0; 0.005; 0];
AxisCell{3} = [0; 0; 0.005];

for k = 1:3
    AxisD = Axis + AxisCell{k};
    %Creating Disturbed Rotation Matrix
    RD = RodriguesMatrix2(AxisD);
    %Building Homogeneous Transformation
    RD = [RD Translation; zeros(1,3) 1];
    
    %Estimating transformed points
    EstPointsDist = KMatrix*[eye(3) zeros(3,1)]*RD*EquivGrid;
    
     s = size(EstPointsDist);
       for j = 1:s(2)
          EstPointsDist(1:2,j)  = EstPointsDist(1:2,j)/EstPointsDist(3,j);
       end
       
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);

    % This is the df1 / dk1 column
    FrameJac(:,k) = (EstPointsDist-EstimatedPoints)/max(max(AxisCell{k}));
end

TrCell = cell(3);
TrCell{1} = [0.01; 0; 0];
TrCell{2} = [0; 0.01; 0];
TrCell{3} = [0; 0; 0.01];

for k = 1:3
    %Creating Disturbed Translation Vector
    TranslationD = Translation + TrCell{k};
    
    R = RodriguesMatrix2(Axis);
    
    %Building Homogeneous Transformation
    RD = [R TranslationD; zeros(1,3) 1];
    
    %Estimating transformed points
    EstPointsDist = KMatrix*[eye(3) zeros(3,1)]*RD*EquivGrid;
    
     s = size(EstPointsDist);
     for j = 1:s(2)
        EstPointsDist(1:2,j)  = EstPointsDist(1:2,j)/EstPointsDist(3,j);
     end
       
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);

    % This is the df1 / dk1 column
    FrameJac(:,k+3) = (EstPointsDist-EstimatedPoints)/max(max(TrCell{k}));
end

