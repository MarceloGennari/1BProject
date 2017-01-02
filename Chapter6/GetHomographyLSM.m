function [ Homography ] = GetHomographyLSM(PointsInImage, EquivGrid)
%GETHOMOGRAPHYLSS Just returns Homography based on Least square method

[A P] = AMatrix(length(PointsInImage(1,:)),PointsInImage,EquivGrid);

%if the Rank of A is less then 8, then there is an infinite number of
%solutions, so therefore we cannot solve for Homography
if rank(A)<8
   Homography = zeros(3,3);
   return
end
H = LeastSquareSolve(A,P);
Homography = ConstructHomography(H);
end

