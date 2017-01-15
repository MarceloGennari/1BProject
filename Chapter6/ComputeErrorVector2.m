function [ ErrorMatrix ] = ComputeErrorVector(KMatrix, AngleAxis, translation, PointsInImage, GridCorresp)
%COMPUTEERRORVECTOR This function takes the KMatrix, the Position Vector
%and the points in the Image and compute the back projection error (sum of
%the squares of the differences in the poitns

Theta = norm(AngleAxis);
Axis = AngleAxis/Theta;

Perspectivity = RodriguesMatrix(Theta,Axis);
M = [Perspectivity translation
     zeros(1,3) 1];
 
%Just converting to Homogeneous Poitns in case it is not
if length(GridCorresp(:,1))<4
   s = length(GridCorresp(1,:));
   GridCorresp(4,:) = GridCorresp(3,:);
   GridCorresp(3,:) =  zeros(1,s);
end

BackProjection = KMatrix*[eye(3) zeros(3,1)]*M*GridCorresp;
     
ErrorMatrix = BackProjection(1:2,:)-PointsInImage(1:2,:);
end

