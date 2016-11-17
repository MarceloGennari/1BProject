function [] = LetMeTakeASelfie( ObjectLines, T_ow, KMatrix, CameraHeight, CameraWidth, T_cw)
%LETMETAKEASELFIE This function takes a picture of what our camera sees
%and plots it in a figure. It takes into consideration the Intrinsic and
%Extrinsic parts of the camera model

%% INPUT HYGIENE



%% Transformation of Camera and Object:

% Transform object to world coordinates
ObjectLines = T_ow*ObjectLines;

%Transform The Object to camera coordinates
ObjectLines = T_cw\ObjectLines;

% Projects out the 4th "dimension" and multiplies with intrinsic component
ObjectLines = KMatrix * ObjectLines(1:3,:);

plot(ObjectLines(1,:), ObjectLines(2,:));
axis ij
title('Picture taken by the camera');

end

