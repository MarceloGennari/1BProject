function [KMatrix, CameraHeight, CameraWidth ] = BuildCamera( )
%BUILDCAMERA This function just returns the Kmatrix, the cameraheight and
%the camera width to test the Simulation Task1. I will just input some
%numbers in here to make the SImulationTask1 cleaner and easier to read

%  Defining the characteristics of the Camera:
ChipSize = [200; 200];
FocalLength = 35;
EffectiveSize = [0.08; 0.08];
Skewness = 0.01;
PointsOffset = [0.5;0.5];

% Getting the K Matrix and returing the camera heights and width
KMatrix = CameraModel(ChipSize,FocalLength,EffectiveSize,Skewness,PointsOffset);
CameraHeight = ChipSize(2);
CameraWidth = ChipSize(1);

end

