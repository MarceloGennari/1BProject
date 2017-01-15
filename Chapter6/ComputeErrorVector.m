function [ ErrorMatrix ] = ComputeErrorVector(KMatrix, AngleAxis, translation, PointsInImage, GridCorresp)
%COMPUTEERRORVECTOR This function takes the KMatrix, the Position Vector
%and the points in the Image and compute the back projection error (sum of
%the squares of the differences in the poitns

H = getHomography(KMatrix,AngleAxis,translation);

BackProjection = H*GridCorresp;

s = size(BackProjection);
    for j = 1:s(2)
    BackProjection(:,j) = BackProjection(:,j)/BackProjection(3,j);
    end
     
ErrorMatrix = BackProjection(1:2,:)-PointsInImage(1:2,:);
end

