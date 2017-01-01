function [ HVec ] = LeastSquareSolve(A,P)
%LEASTSQUARESOLVE Given a System Ax = b, this function minimizes x given
%that A is oversconstrained and the cost function is |Ax-b|^2. This uses
%the singular-value decomposition method

%In this case, we are minimizing |A*HVec-P|^2, where Hvec is a 8x1 vector
%and A is a 2nx8 vector, and P is 2nx1 vector

[U,D,V] = svd(A,'econ');

%"Invert" the diagonal matrix
for i = 1:8
    D(i,i) = 1/D(i,i);
end

%This formula is on page 40 of the notes
HVec = V*(D*(U'*P));

