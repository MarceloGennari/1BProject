function [ T_cw ] = FillImage( T_wg, KMatrix, CameraHeight, CameraWidth, GridCornersW,GridSize)
%FILLIMAGE Summary of this function goes here
%   Detailed explanation goes here

InsideImage = 1;
CameraDistance = 10000;
while InsideImage ==1;
    InsideImage = 0;
    
    %Create Transformation matrix from camera reference to world reference
    T_cw = PositionCamera(T_wg,CameraDistance);
    GridCornersPhoto = LetMeTakeASelfie(GridCornersW, T_wg, KMatrix, CameraHeight, CameraWidth, T_cw);
    
    % Tests whether all four points are inside the picture frame or not. If it is, it sets Inside Image 
    %to 1 and the loop runs again, until all the corners are outside the frame and consequently the grid 
    %filled the image 
    
    for j =1:4
        if GridCornersPhoto(1,j) < CameraWidth && GridCornersPhoto(1,j) > 0
            InsideImage = 1;
        end
        if GridCornersPhoto(2,j) < CameraHeight && GridCornersPhoto(2,j) > 0
            InsideImage = 1;
        end
    end
  
    %If at least one of the corners are inside the picture, then we shrink
    %the distance from the camera to the object / grid
    if InsideImage == 1
        CameraDistance = CameraDistance - 10;
        fprintf('%f mm\n',CameraDistance);
    end
end

%If the camera distance is less then half of the grid size, issues might
%occur like points being behind the camera. We don't want this to happen.
if CameraDistance < GridSize/2;
   error('Camera too close to Chequerboard. Try changing camera angle');
end

end

