function [ R ] = RodriguesMatrix( Theta, axis )
%RODRIGUESMATRIX This implements the Rodrigues Rotation Matrix 
%   This returns the rotation matrix given the angle and the axis
%   angle is in radians and axis is a unit vector

%just to make sure the axis is unit vector
axis = axis/norm(axis);

x = axis(1);
y = axis(2);
z = axis(3);

K = [0 -z y
     z 0 -x
     -y x 0];
I = eye(3);

% Rodrigues Formula
R = I + sin(Theta)*K+(1-cos(Theta))*K*K;
end

