function [NoisyPointsInImage NoisyEquivGrid ] = BuildNoisyCorrespondence(PointsInImage, EquivGrid, level)
%BUILDNOISYCORRESPONDENCE This function adds some noise to the points in
%the image and in the points in the grid, just like a computer vision
%algorithm would do

s1 = length(PointsInImage(1,:));
s2 = length(EquivGrid(1,:));
a = level*randn(1,s1);
b = rand(1,s1)*4*pi;

NoisyPointsInImage = [PointsInImage(1,:)+a.*cos(b);
                      PointsInImage(2,:)+a.*sin(b)];
NoisyEquivGrid = [EquivGrid(1,:) + level*randn(1,s2)
                  EquivGrid(2,:) + level*randn(1,s2)];
              

