% Likely input

A = imread('C:\Users\Marcelo\Documents\MATLAB\B1Project\Chapter6\ReportAndImages\ChequerboardPicture.jpg');
%WARNING: Checkerboard must be aymmetric (31x30 for example), otherwise
%this function might return the wrong orientation of the board
s = size(A);

cameraWidth = s(2);
cameraHeight = s(1);

[imagePoints,boardSize] = detectCheckerboardPoints(A);
imagePoints = imagePoints';

subplot(1,2,1);
image(A);
title('Input to program');
axis([0 cameraWidth 0 cameraHeight]);
axis square

subplot(1,2,2);
plot(imagePoints(1,:),imagePoints(2,:),'r.');
title('Input to script');
axis([0 cameraWidth 0 cameraHeight]);
axis ij
axis square