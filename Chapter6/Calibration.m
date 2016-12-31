

%Build Camera based on Iphone 7
[KMatrix, CameraHeight, CameraWidth] = BuildCamera();

%Build grid and Grid corners in their reference frame
GridSize = 1000;
Spacing = 10;
[Grid GridCorners] = BuildGrid(GridSize, Spacing);

%Create transformation matrix from grid reference to world reference
T_wg = PositionObject();

%move grid and grid corners to world referencef frame
GridW = T_wg*Grid;
GridCornersW = T_wg*GridCorners;

%Create Transformation matrix from camera reference to world reference
T_cw = FillImage(T_wg,KMatrix,CameraHeight,CameraWidth,GridCornersW,GridSize);

%Takes a picture
GridPointsPhoto = LetMeTakeASelfie(GridW,T_wg,KMatrix,CameraHeight,CameraWidth,T_cw);
GridCornersPhoto = LetMeTakeASelfie(GridCornersW,T_wg,KMatrix,CameraHeight,CameraWidth,T_cw);

%Here we plot the Picture and make sure the axis goes from 0 to CamerHeigth
%from the top to bottom using the axis ij command.
plot(GridPointsPhoto(1,:), GridPointsPhoto(2,:),'r.');
hold on
plot(GridCornersPhoto(1,:), GridCornersPhoto(2,:),'b.','markers',15);
axis ij
axis([0 CameraWidth 0 CameraHeight])
title('Picture taken by the camera');

%plot in world reference frame
figure
plot3(GridW(1,:),GridW(2,:),GridW(3,:),'r.');
hold on
plot3(GridCornersW(1,:),GridCornersW(2,:),GridCornersW(3,:),'b.','markers',15);
PlottingCamera(T_cw);