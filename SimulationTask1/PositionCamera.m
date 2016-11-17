function [ T_cw] = PositionCamera( T_ow )
%POSITIONCAMERA This function returns a random 4D transpose and rotation matrix
%for the camera so that it will probably point at the object for Simulation
%task 1

%T_ow is the 4D transpose and position vector of the object relative to the
%world reference point

%Getting the object origin:
%This is the vector that goes from the origin of world coordinates to the
%origin of the object
ObjOrigin = T_ow(1:3,4);

%This is a vector that goes from the origin of the object to the origin of
%the camera frame. This means that the camera origin will always be 5
%meters away from the Object
CameraOrigin = 10000*(rand(3,1)-[0.5;0.5;0.5]);

%This is the vector that goes from the origin of the world coordinate
%system to the origin of the camera. 
Org = ObjOrigin - CameraOrigin;

%Now we define the direction of the z-axis so that it points to the object,
%which is actually the vector CameraOrigin, since it is the vector pointing
%from the object to the camera
Znorm = norm(CameraOrigin);
if Znorm < eps
   error('EPS reached, so cannot perform algebraic calculations'); 
end

%Unit vector
CameraZ = CameraOrigin / Znorm;

%Perturb the z-axis a bit so that we get different angles everytime
CameraZ = CameraZ- 0.02*(rand(3,1)-[0.5; 0.5; 0.5]);
CameraZ = CameraZ/norm(CameraZ); %And normalize it again

%Create random x-Axis that is perpendicular to Z
CameraX = rand(3,1);
CameraX = CameraX - dot(CameraZ,CameraX)*CameraZ; %Take the Z element out

%Normalizing it
Xnorm = norm(CameraX); 
if Xnorm < eps
   error('cannot perform algebraic calculations');
end

CameraX = CameraX / Xnorm;

%Define Y-axis

CameraY = cross(CameraZ,CameraX);

T_cw = [CameraX CameraY CameraZ Org; zeros(1,3) 1];
end

