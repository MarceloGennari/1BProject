function [ Homography ] = ConstructHomography( HomogVec )
%CONSTRUCTHOMOGRAPHY This gets a 8vector and constructs a 3x3 Homography Matrix 

Homography = [HomogVec(1,1) HomogVec(2,1) HomogVec(3,1)
              HomogVec(4,1) HomogVec(5,1) HomogVec(6,1)
              HomogVec(7,1) HomogVec(8,1) 1];
end

