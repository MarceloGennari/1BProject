function [ Psi ] = getPsi( HomographyMatrix )
%GETPSI This function returns the PsiJ, as specified in Page 55 of the
%notes

h = HomographyMatrix;

A = h(1,1)^2-h(1,2)^2;
B = 2*(h(1,1)*h(2,1)-h(1,2)*h(2,2));
C = 2*(h(1,1)*h(3,1)-h(1,2)*h(3,2));
D = h(2,1)^2-h(2,2)^2;
E = 2*(h(2,1)*h(3,1)-h(2,2)*h(3,2));
F = h(3,1)^2 - h(3,2)^2;
G = h(1,1)*h(1,2);
H = h(1,1)*h(2,2)+h(2,1)*h(1,2);
I = h(1,1)*h(3,2)+h(3,1)*h(1,2);
J = h(2,1)*h(2,2);
K = h(2,1)*h(3,2)+h(3,1)*h(2,2);
L = h(3,1)*h(3,2);

Psi = [A B C D E F
       G H I J K L];

end

