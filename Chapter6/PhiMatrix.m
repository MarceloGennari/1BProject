function [ Phi ] = PhiMatrix( x,y,u,v )
%PHIMATRIX This function returns the Phi matrix as defined in page 38 of
%the notes
%   Phi will be a 2x8 matrix, which will eventually be concatenated to form
%   the A Matrix that will need to be optimized
%   x and y are the coordinates of the points in the grid frame and u and v
%   are the coordinates in the pixel frame

Phi = [x y 1 0 0 0 -u*x -u*y
       0 0 0 x y 1 -v*x -v*y];
end

