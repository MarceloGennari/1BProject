function [ R ] = RodriguesMatrix2( Axis )
%RODRIGUESMATRIX2 This function simply takes the axis whose norm is equal
%to the angle and computes the rotation matrix using rodrigues formula

Angle = norm(Axis);
Axis = Axis / Angle;

R = RodriguesMatrix(Angle,Axis);

end

