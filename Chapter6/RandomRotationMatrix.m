function [ R ] = RandomRotationMatrix()
%RandomRotationMatrix Generates a Rotation Matrix with all its properties
%   The matrix is orthonormal, symetric and unitary.

%   Make sure that the minimum value of the vector is accepted as an
%   arithmetic operator in matlab:

xnorm = 0;
while xnorm<eps
   x = rand(3,1);
   xnorm = norm(x);
end

%   The 'random' unit vector
xhat = x/xnorm;

% Do the same with y:
ynorm = 0;
while ynorm<eps
   y = rand(3,1);
   
   %    Make sure that y is orthogonal to x
   y = y-dot(y,xhat)*xhat;
   
   ynorm = norm(y);
end

yhat = y/ynorm;

%   Get a third orthogonal vector
zhat = cross(xhat,yhat);


R = [xhat yhat zhat];

end

