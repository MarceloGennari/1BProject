function [ T ] = PositionObject()
%POSITIONOBJECT This function just returns the 4D matrix to rotate and
%transpose an object from a reference point to another. Here just for
%testing we are going to use a random generator of rotation matrix and a
%random Position Vector

%Generates Random Rotation Matrix
R = RandomRotationMatrix();

%Generates Random Position Vector at most sqrt(3) units away.
PositionVector = 1000*rand(3,1);
PositionVector = PositionVector / norm(PositionVector);

% Returns 4D Transform Matrix
T = [R PositionVector; ones(1,3)*0 1];
end

