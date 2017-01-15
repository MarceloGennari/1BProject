function [PointsInImageWOut N] = ImplOutlier(PointsInImage, p, CameraWidth,CameraHeight)
%IMPLOUTLIER Considering the fact that the computer algorithm that detects
%the edges of the chequerboard might detect some outliers (maybe because of
%shadow / lighting conditions / unexpected dust or something in the way
%idk), we are going to input some random outlier points using this function

%   This gets the matrix of points (u,v) - PointsInImage and randomly places
%   some outliers inside the frame [0 CameraWidth 0 CameraHeight]
% The probability (or density) of outliers is determined by the argument p

size = length(PointsInImage(1,:));
if p>=1 || p<0
    error('the probability p needs to be between 0 and 1');
end
number = 0;
for l = 1:size
    if p>rand
        PointsInImage(1,l) = rand*CameraWidth;
        PointsInImage(2,l) = rand*CameraHeight;
        number = number+1;
    end
end

PointsInImageWOut = PointsInImage;
N = number;
end

