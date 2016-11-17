function [] = LetMeTakeASelfie( ObjectLines, T_ow, KMatrix, CameraHeight, CameraWidth, T_cw)
%LETMETAKEASELFIE This function takes a picture of what our camera sees
%and plots it in a figure. It takes into consideration the Intrinsic and
%Extrinsic parts of the camera model

%% INPUT HYGIENE
% Checking the ObjectLines matrix. It should be a 4x2n matrix:
s = size(ObjectLines);
if s(1) ~= 4 || mod(s(2),2) ~= 0
   error('ObjectLines is not a valid matrix')
end

% Checking the transformation Matrices, which should be a 4x4
s = size(T_ow);
if s(1) ~= 4 || s(2) ~= 4
    error('T_ow has an invalid size');
end

s = size(T_cw);
if s(1) ~= 4 || s(2) ~= 4
    error('T_cw has an invalid size');
end

% Checking the KMatrix. It should be a 3x3 Matrix as specified in the
% CameraModel.m function

s = size(KMatrix);
if s(1)~= 3 || s(2) ~= 3
   error('The Camera Model is not valid'); 
end


%% Transformation of Camera and Object:

% Transform object to world coordinates
ObjectLines = T_ow*ObjectLines;

%Transform The Object to camera coordinates
ObjectLines = T_cw\ObjectLines;

% Projects out the 4th "dimension" and multiplies with intrinsic component
ObjectLines = KMatrix * ObjectLines(1:3,:);

%Normalizing
s = size(ObjectLines);
for j = 1:s(2)
   ObjectLines(1:2,j)  = ObjectLines(1:2,j)/ObjectLines(3,j);
end

plot(ObjectLines(1,:), ObjectLines(2,:));
axis ij
axis([0 CameraWidth 0 CameraHeight])
title('Picture taken by the camera');

end

