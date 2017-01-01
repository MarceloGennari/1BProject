function [ Amatrix PMatrix] = AMatrix( numberPoints, GridPhoto, Grid )
%AMATRIX This builds the A and P matrices as specified in page 38 of the notes

A = PhiMatrix(Grid(1,1),Grid(2,1),GridPhoto(1,1),GridPhoto(2,1));
P = [GridPhoto(1,1);GridPhoto(2,1)];
for j = 2:numberPoints
   A = [A; PhiMatrix(Grid(1,j),Grid(2,j),GridPhoto(1,j),GridPhoto(2,j))];
   
   P = [P; GridPhoto(1,j);GridPhoto(2,j)];
end

Amatrix = A;
PMatrix = P;
end

