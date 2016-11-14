function [ R ] = RodriguesRotationFormula( RotationAxis, AngleOfRotation )
%RodriguesRotationFormula This function returns a rotation formula given
%the rotation axis and the angle of rotation
%   Detailed explanation goes here

%% INPUT HYGIENE
if length(RotationAxis) ~= 3
   error('RotationAxis is not a three element vector'); 
end

%Normalizing the Rotation Axis in case the user didn't input a unit vector
norma = norm(RotationAxis);

if norma < eps
   error('Axis input cannot be calculated reliable'); 
end

RotationAxis = RotationAxis / norma;

%% GETTING THE ROTATION MATRIX
%Calculating the K Matrix for Rodrigues formula (which is not the same as
%the intrinsic matrix of the camera btw
K = [0 -RotationAxis(3) RotationAxis(2);
    -RotationAxis(3) 0 -RotationAxis(1);
    RotationAxis(2) -RotationAxis(1) 0];

R = eye(3) + sin(RotationAngle)*K + (1-cos(RotationAngle))*K^2;
end

