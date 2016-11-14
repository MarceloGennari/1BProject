function [KMatrix] = CameraModel( ChipSize, FocalLength, EffectiveSize, Skewness, PointOffset )
%CameraMode This function returns the K Matrix of the pinhole camera model,
%given a set of 5 parameters.

%% Parameters
%   ChipSize - Vector where ChipSize(1) is the chip width in x pixels
%                           ChipSize(2) is the chip height in y pixels
%   FocalLength - This is a scalar representing the camera focal length
%   EffectiveSize - Vector where EffectiveSize(1) is the pixel size in x
%                                EffectiveSize(2) is the pixel sizei in y
%   Skewness - This is a scalar representing the skewness of the chip
%   PointsOffset - Vector where PointOffset(1) is the offset in x
%                               PointsOffset(2) is the offset in y

%% Explanation for the choice of parameters
% I decided to use 5 prameters in the function to make it more readable for
% future reference. It is way easier to remember what parameters are going
% in what order in a function written this way than in a function that
% accepts only one big "vector" parameter. This is especially useful when
% you are writing code, since matlab's autocompletion show you the name of
% the arguments that the function accepts once you type "CameraModel(" in
% the script or Commmand Window.

% I went for the obvious choice of joining parameters that represent the
% same entity (so for example, I put the x and y coordinates of PointOffset
% in a single vector, and I did the same for the effective sizes of pixels
% and the Chip Size.

%% Initial range of each parameter
%   200 < ChipSize(1) < 4000 - Integer
%   300 < ChipSize(2) < 5000 - Integer
%   1.0 < FocalLength < 100.0 - Value in mm
%   0.0001 < EffectiveSize(1) < 0.1 - Value in mm
%   0.0001 < EffectiveSize(2) < 0.1 - Value in mm
%   -0.1 < Skewness < 0.1 - Any number in this range
%   0.25 < PointOffset(1) < 0.75 - Any fraction in this range
%   0.25 < PointOffset(2) < 0.75 - Any fraction in this range

%% Input Hygiene

% Testing whether ChipSize has integer values and is a [x;y] vector
    if ChipSize(1)-fix(ChipSize(1)) ~= 0
       % This gets the name of the input argument
       s = inputname(1);
       % If it doesn't have a name (if the user inputs [1;1] for example, then
       % we just return the name of the local variable
        if isempty(s)
            error('ChipSize(1) is not an integer');
        end
        error('%s(1) is not an integer', s);
    end

    if ChipSize(2)-fix(ChipSize(2)) ~= 0 
       s = inputname(1);
        if isempty(s)
            error('ChipSize(2) is not an integer');
        end
        error('%s(2) is not an integer', s);
    end

% Testing for ranges
    TestRange(ChipSize(1),200,4000, 'ChipWidth');
    TestRange(ChipSize(2),200,4000, 'ChipHeight');
    TestRange(FocalLength, 1.0, 100.0, 'Focal Length');
    TestRange(EffectiveSize(1),0.0001, 0.1, 'Pixel Width');
    TestRange(EffectiveSize(2), 0.0001,0.1,'PixelHeight');
    TestRange(Skewness,-.1,.1,'Skewness');
    TestRange(PointOffset(1),0.25,0.75,'X Offset');
    TestRange(PointOffset(2),0.25,0.75,'Y Offset');
    
%% Calculating K Matrix
    FLengthPix(1) = FocalLength / EffectiveSize(1);
    FLengthPix(2) = FocalLength / EffectiveSize(2);
    
    KMatrix = [FLengthPix(1)    Skewness     PointOffset(1)*ChipSize(1);
              0         FLengthPix(2)  PointOffset(2)*ChipSize(2);
              0               0             1];
          

end