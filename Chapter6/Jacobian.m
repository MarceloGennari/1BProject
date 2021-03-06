function [ KMatJac, FrameJac ] = Jacobian(KMatrix, Axis, Translation, EquivGrid )
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
H = getHomography(KMatrix,Axis,Translation);
EstimatedPoints = H*EquivGrid;

 s = size(EstimatedPoints);
   for j = 1:s(2)
      EstimatedPoints(:,j)  = EstimatedPoints(:,j)/EstimatedPoints(3,j);
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
diff(1) = KMatrix(1,1)*0.0001;
diff(2) = KMatrix(1,2)*0.0001;
diff(3) = KMatrix(1,3)*0.0001;
diff(4) = KMatrix(2,2)*0.0001;
diff(5) = KMatrix(2,3)*0.0001;
DisK{1} = [diff(1) 0 0; 0 0 0; 0 0 0];
DisK{2} = [0 diff(2) 0; 0 0 0; 0 0 0];
DisK{3} = [0 0 diff(3); 0 0 0; 0 0 0];
DisK{4} = [0 0 0; 0 diff(4) 0; 0 0 0];
DisK{5} = [0 0 0; 0 0 diff(5); 0 0 0];

for k = 1:5
    % Disturbing KMatrix:
    KDist = KMatrix + DisK{k};
    
    H = getHomography(KDist,Axis,Translation);
    EstPointsDist = H*EquivGrid;
    
       s = size(EstPointsDist);
       for j = 1:s(2)
          EstPointsDist(:,j)  = EstPointsDist(:,j)/EstPointsDist(3,j);
       end
   
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);
    e = EstPointsDist-EstimatedPoints;
    % This is the df1 / dk1 column
    KMatJac(:,k) = e/diff(k);
end

%% CALCULATING FRAME JAC

%For the same reason I used for the KMatrix, I will create 2 a 3 cells with
%disturbances
AxisCell = cell(3);
diff(1) = Axis(1)*0.000000001;
diff(2) = Axis(2)*0.000000001;
diff(3) = Axis(3)*0.000000001;
AxisCell{1} = [diff(1); 0; 0];
AxisCell{2} = [0; diff(2); 0];
AxisCell{3} = [0; 0; diff(3)];

for k = 1:3
    AxisD = Axis + AxisCell{k};

    H = getHomography(KMatrix, AxisD, Translation);
    
    %Estimating transformed points
    EstPointsDist =H*EquivGrid;
    
     s = size(EstPointsDist);
       for j = 1:s(2)
          EstPointsDist(1:2,j)  = EstPointsDist(1:2,j)/EstPointsDist(3,j);
       end
       
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);
    e = EstPointsDist-EstimatedPoints;
    % This is the df1 / dk1 column
    FrameJac(:,k) = e/diff(k);
end

TrCell = cell(3);
diff(1) = Translation(1)*0.0001;
diff(2) = Translation(2)*0.0001;
diff(3) = Translation(3)*0.0001;
TrCell{1} = [diff(1); 0; 0];
TrCell{2} = [0; diff(2); 0];
TrCell{3} = [0; 0; diff(3)];

for k = 1:3
    %Creating Disturbed Translation Vector
    TranslationD = Translation + TrCell{k};
    
    H = getHomography(KMatrix,Axis,TranslationD);
    
    %Estimating transformed points
    EstPointsDist = H*EquivGrid;
    
     s = size(EstPointsDist);
     for j = 1:s(2)
        EstPointsDist(:,j)  = EstPointsDist(:,j)/EstPointsDist(3,j);
     end
       
    EstPointsDist = EstPointsDist(1:2,:);
    EstPointsDist = EstPointsDist(:);

    e = EstPointsDist - EstimatedPoints;
    % This is the df1 / dk1 column
    FrameJac(:,k+3) = e/diff(k);
end

