function [ObjectLines] = LetMeTakeASelfie( ObjectLines, T_ow, KMatrix, T_cw)
%LETMETAKEASELFIE This function takes a picture of what our camera sees
%and plots it in a figure. It takes into consideration the Intrinsic and
%Extrinsic parts of the camera model

%% INPUT HYGIENE

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

%Normalizing the points. This involves dividing the points by their
%distances to the plane. This is because even though two points have the
%same x or y values for example, if they are in different distances away
%from you, they seem like they hae different x and y values. To get an
%intuition about this, think about two tress of the same size. One of them
%is 10 meters from you and the other one is 100 meters from you. The one
%furthest from you will look like it is smaller than the one close to you.
%The sizes are proportional to the distance, so the one 100 meters from you
%will look like 10 times smaller (this is proven by a simple triangle
%analysis) This is why here in this loop we divide the x and y values of
%the object lines (ObjectLines(1:2,j)) by their distances from the plane
%(ObjectLines(3,j)).
s = size(ObjectLines);
for j = 1:s(2)
   ObjectLines(1:2,j)  = ObjectLines(1:2,j)/ObjectLines(3,j);
end
end

