function [ K ] = getRealK( KM )
%GETREALK Summary of this function goes here
%   Detailed explanation goes here
KM(1,3) = KM(1,3)+1;
KM(2,3) = KM(2,3)+1;
KM(1:2,1:3) = KM(1:2,1:3)*100;

K = KM;

end

