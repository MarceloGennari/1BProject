function [KMatrix ] = OptimizeKMatrix2( K, Data )
%OPTIMIZEKMATRIX This function uses the Levenberg-Marquadt algorithm to
%optimize the KMatrix model of the camera
%   K is the first model of the camera, and Data is a Matlab cell
%   containing 3 columns: The first of Homographies, the second of the
%   final points in the image matrix and the third of the equivalent grid
%   in its coordinate frame.

%% STEPS
%   1. Compute the angle-axis rotation matrix to get the perspectivity
%   2. Compute the error vector e
%   3. Compute the Cost Function E (sum of the suares of error)
%   4. Compoute the Jacobian J and the product J'J
%   5. Find the norm of J'J, normalize and scale it by app. 0.1
%   6. Solve for dp where (J'J+muI)*dp = -J'e
%   7. REPEAT:
%       7.1 if J'e is small enough, terminate
%       7.2 Compute the change e'Jdp
%       7.3 If error goes up, reject change, recompute mu and make it bigger
%       7.4 If error goes down, accept change, recompute my and make it smaller


nImages = length(Data');


%This cell stores the parameters of the LM algorithm
% 1 Error Vector
% 2 Jacobian
% 3 FrameParameterJacobian
Params = cell(nImages,3);

%% 1. Compute Angle-Axis Rotation Matrix

%This cell will store the parameters for the perspectivities of each image
%(a.k.a the axis which has norm equal to the angle and the translation)
Persp = cell(nImages,2);

for n = 1:nImages
   
    %Extracting Homography from Data provided
    Homography = Data{n,1};
    
    %Calculate modeled Perspectivity
    Perspectivity = K\ Homography;
    
    %Making first column a unit vector
    lambda = norm(Perspectivity(:,1));
    Perspectivity = Perspectivity / lambda;
    
    t = Perspectivity(:,3);
    
    r1Hat = Perspectivity(:,1); %this is unit vector, therefore Hat
    r2 = Perspectivity(:,2); %this is might have r1 components
    
    r2 = r2 -dot(r1Hat,r2)*r1Hat; % this extracts any r1 components from r2
    
    r2Hat = r2/norm(r2); % makes r2 a unit vector
    
    %Now r1Hat and r2Hat are orthonormal
    r3Hat = cross(r1Hat,r2Hat);
    
    Rotation = [r1Hat r2Hat r3Hat];
    
    CosTheta = (trace(Rotation)-1)/2;
    
    %Make sure that Theta will return a real value
    if CosTheta > 1
       CosTheta = 1; 
    end
    if CosTheta<-1
       CosTheta = -1; 
    end
    %Angle of Rotation
    Theta = acos(CosTheta);
    
    %Finding eigenvectors:
    [V W] = eig(Rotation);
    W = diag(W);
    
    %We know that the eigenvalues will be unit and one of them will be
    %real. Due to MATLAB precision, the real one will be something like
    %1+0.00000001j. So to identify it it is better to find the "maximum"
    %real value of the eigenvalues
    index = find(max(real(W))==W);
    
    %The axis of rotation of this matrix is the real eigenvector of the
    %matrix
    Axis = V(:,index);
    Axis = Axis/norm(Axis);
    
    %This axis can be in two directions. We need to find the one that is
    %the right. To do this, we compare it with the original rotation matrix
    %and see which one has a smaller error
    
    Rot1 = RodriguesMatrix(Theta,Axis);
    Rot2 = RodriguesMatrix(Theta,-Axis);
    
    error1 = Rotation-Rot1;
    error2 = Rotation-Rot2;
    
    if norm(error2)<norm(error1);
        Axis = -Axis;
    end
    
    %Using the shifted angle formula
    Theta = Theta+4*pi;
    Axis = Axis*Theta;
    
    Persp{n,1} = Axis;
    Persp{n,2} = t;
end

%% 2. Compute the error vector e

%Initial Error
E0 = 0;

%Letting J be a cell
J = cell(nImages,nImages+1);

%Allocating space for J transpose J
JTJ = zeros(5+6*nImages);

%Allocating space for the Gradient Vec
Gradient = zeros(5+6*nImages,1);

for j = 1:nImages
    
    Axis = Persp{j,1};
    t = Persp{j,2};
    PointsInImage = Data{j,2};
    EquivGrid = Data{j,3};
        
    %Calculate the error vector e for each image
    e = ComputeErrorVector2(K, Axis,t, PointsInImage,EquivGrid);
    
    % Tranform from 2xnMeasurements to vector 2*nMeasurementsx1
    e = e(:);
    % e'*e is the sum of the square of the errors and E0 is the initial
    % error
    E0 = E0 + 0.5*(e'*e);
    
    % Computing the Jacobian
    [ KMatJac, FrameJac ] = Jacobian2(K, Axis, t, EquivGrid);
    
    %Building Jacobian:
    J{j,1} = KMatJac;
    J{j,1+j} = FrameJac;
    
    %% COMPUTING JTJ
    % The top 5x5 block is the sum of the products of the KMatJacs
    JTJ(1:5,1:5) = JTJ(1:5,1:5) + KMatJac'*KMatJac;
    
    % Diagonal Block:
    StartRow = 6+(j-1)*6;
    EndRow = StartRow+5;
    
    JTJ(StartRow:EndRow,StartRow:EndRow) = FrameJac'*FrameJac;
    JTJ(1:5,StartRow:EndRow) = KMatJac'*FrameJac;
    JTJ(StartRow:EndRow,1:5) = JTJ(1:5,StartRow:EndRow)';
    
    %Gradient Vector:
    Gradient(1:5) = Gradient(1:5)+KMatJac'*e;
    Gradient(StartRow:EndRow) = FrameJac'*e;
end

%Initial Value of mu
mu = max(diag(JTJ))*0.1;

%Initial value of nu, which controls the rate of mu basically
nu = 2;

CurrentError = E0;
Searching = 1;
Iterations = 0;
MaxIterations = 100;

while Searching == 1
   Iterations = Iterations + 1;
   
   if Iterations > MaxIterations
      fprintf('returned because of too many iterations');
      KMatrix = KMatPerturbed;
      return
      %Just to prevent infinite loops I guess
      
   end
   
   %Test for convergence
    if norm(Gradient)/(5+6*nImages) < 0.001
       break 
    end
    
    % using equtions from notes
    dp = -(JTJ + mu*eye(5+6*nImages))\Gradient;
    PredictedChange = Gradient'*dp;
    
    %New parameters:
    KMatPerturbed = K;
    FrameParametersPerturbed = Persp;
    
    KMatPerturbed(1,1) = KMatPerturbed(1,1) + dp(1);
    KMatPerturbed(1,2) = KMatPerturbed(1,2) + dp(2);
    KMatPerturbed(1,3) = KMatPerturbed(1,3) + dp(3);
    KMatPerturbed(2,2) = KMatPerturbed(2,2) + dp(4);
    KMatPerturbed(2,3) = KMatPerturbed(2,3) + dp(5);
    
    KMatPerturbed
    
    %Initialize the Error
    NewError = 0;
    for j = 1:nImages
        PointsInImage = Data{j,2};
        EquivGrid = Data{j,3};
        
        %Perturb the image location
        StartRow = 6+(j-1)*6;
        FrameParametersPerturbed{j,1} = FrameParametersPerturbed{j,1}+dp(StartRow:StartRow+2);
        FrameParametersPerturbed{j,2} = FrameParametersPerturbed{j,2} +dp(StartRow+3:StartRow+5);
        
        %Compute error
         e = ComputeErrorVector2(KMatPerturbed, FrameParametersPerturbed{j,1},FrameParametersPerturbed{j,2},PointsInImage,EquivGrid);
         e = e(:);
         NewError = NewError+0.5*e'*e;
    end
    
    ChangeInError = NewError - CurrentError;
    Gain = ChangeInError/PredictedChange
    
    if ChangeInError>=0
        %Error has gone up
        mu = mu*nu;
        nu = nu*2;
        fprintf('bigger\n')
    else
       %Error has gone down
       nu = 2;
       mu = mu*max([1/3,(1-(2*Gain-1)^3)]);
       fprintf('smaller\n');
       %Update the parateres
       K = KMatPerturbed;
       Params = FrameParametersPerturbed;
       
       %Update the error
       CurrentError = NewError;
       
       if Gain<1/3
           %Letting J be a cell
            J = cell(nImages,nImages+1);

            %Allocating space for J transpose J
            JTJ = zeros(5+6*nImages);

            %Allocating space for the Gradient Vec
            Gradient = zeros(5+6*nImages,1);
                
          %The gain is poor, so I will have to recompute the Jacobian
          for j =1:nImages
                Axis = Params{j,1};
                t = Params{j,2};
                PointsInImage = Data{j,2};
                EquivGrid = Data{j,3};

                %Calculate the error vector e for each image
                e = ComputeErrorVector2(K, Axis,t, PointsInImage,EquivGrid);

                % Tranform from 2xnMeasurements to vector 2*nMeasurementsx1
                e = e(:);

                % Computing the Jacobian
                [ KMatJac, FrameJac ] = Jacobian2(K, Axis, t, EquivGrid);

                %Building Jacobian:
                J{j,1} = KMatJac;
                J{j,1+j} = FrameJac;

                %% COMPUTING JTJ
                % The top 5x5 block is the sum of the products of the KMatJacs
                JTJ(1:5,1:5) = JTJ(1:5,1:5) + KMatJac'*KMatJac;

                % Diagonal Block:
                StartRow = 6+(j-1)*6;
                EndRow = StartRow+5;

                JTJ(StartRow:EndRow,StartRow:EndRow) = FrameJac'*FrameJac;
                JTJ(1:5,StartRow:EndRow) = KMatJac'*FrameJac;
                JTJ(StartRow:EndRow,1:5) = JTJ(1:5,StartRow:EndRow)';

                %Gradient Vector:
                Gradient(1:5) = Gradient(1:5)+KMatJac'*e;
                Gradient(StartRow:EndRow) = FrameJac'*e;
          end
       end
    end
     
end
    
KMatrix = K;
end


