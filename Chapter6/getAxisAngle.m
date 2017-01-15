function [ Persp ] = getAxisAngle(K, Data )
%GETAXISANGLE Summary of this function goes here
%   Detailed explanation goes here

nImages = length(Data');
Persp = cell(nImages,2);
for n = 1:nImages
   
    %Extracting Homography from Data provided
    Homography = Data{n,1};
    PointsEstimated = Data{n,2};
    EquivGrid = Data{n,3};
    
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

end

