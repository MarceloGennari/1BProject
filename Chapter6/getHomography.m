function [ Homography ] = getHomography(KMatrix, AxisAngle, Translation)
%GETHOMOGRAPHY Gets Homography from AxisAngle representation of Rotation
%matrix (using Rodrigues Formula), the translation and the KMatrix

    Rotation = RodriguesMatrix2(AxisAngle);
    M = [Rotation Translation; zeros(1,3) 1];
    H = KMatrix*[eye(3) zeros(3,1)]*M;
    H = [H(:,1:2) H(:,4)];
    H = H/H(3,3);
    
    Homography = H;
end

