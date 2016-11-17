function [KMatrix, CameraHeight, CameraWidth ] = BuildCamera( )
%BUILDCAMERA This function just returns the Kmatrix, the cameraheight and
%the camera width to test the Simulation Task1. I will just input some
%numbers in here to make the SImulationTask1 cleaner and easier to read

%  Defining the characteristics of the Camera:
ChipSize = [300; 300];
FocalLength = 20;
EffectiveSize = [0.1; 0.1];
Skewness = 0;
PointsOffset = [0.5;0.5];

% Getting the K Matrix and returing the camera heights and width
KMatrix = CameraModel(ChipSize,FocalLength,EffectiveSize,Skewness,PointsOffset);
CameraHeight = 10;
CameraWidth = 10;

end

