function [] = BackProjection(HomogData)
%BACKPROJECTION This function plots the back projection of the points in
%the homog data.

s = size(HomogData);
for i = 1:s(1)
    Projection = HomogData{i,2};
    ActualPoints = HomogData{i,4};
    
    figure
    subplot(1,3,1)
    plot(Projection(1,:),Projection(2,:),'r.');
    axis([0 200 0 200])
    axis square
    title('Back Projection Points')
    xlabel('u pixels')
    ylabel('v pixels')
    
    subplot(1,3,3)
    plot(ActualPoints(1,:),ActualPoints(2,:),'g.');
    axis([0 200 0 200])
    axis square
    title('Actual Points')
    xlabel('u pixels')
    ylabel('v pixels')
    
    subplot(1,3,2)
    plot(Projection(1,:),Projection(2,:),'r.');
    hold on
    plot(ActualPoints(1,:),ActualPoints(2,:),'g.');
    axis([0 200 0 200])
    axis square
    title('Superimposed Back Projection and Actual Points')
    xlabel('u pixels')
    ylabel('v pixels')
    
    
    e = Projection(1:2,:) - ActualPoints(1:2,:);
    e = e(:);
    
    E(i) = e'*e;
    pause
    close all;
end
end

