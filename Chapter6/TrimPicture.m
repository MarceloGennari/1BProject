function [ PointsInImage EquivalentGrid] = TrimPicture( ObjectLines,OrigObject,CameraWidth,CameraHeight )
%TRIMPICTURE This takes as an argumento ObjectLines (which are points in
%perspective according to the camera model) and transform it to
%PointsInImage (which are the points in perspective that are inside the
%array of pixels of the picture taken). It also returns the set of points
%of the original grid in its reference frame

%This part makes sure that the returned values will be only the points that
%are inside the picture taken
k = 1;
for j = 1:length(ObjectLines(1,:))
    IsInside = 1;
   if ObjectLines(1,j)>CameraWidth || ObjectLines(1,j)<0
       IsInside = 0;
   end
   if ObjectLines(2,j)>CameraHeight || ObjectLines(2,j)<0
       IsInside = 0;
   end
   
   if IsInside ==1
      PointsInImage(:,k) = ObjectLines(:,j);
      EquivalentGrid(:,k) = OrigObject(:,j);
      k = k +1;
   end
end
end

