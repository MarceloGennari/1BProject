function [ Grid, GridCorners ] = BuildGrid(Size,Spacing)
%BUILDGRID This function returns a grid using homogeneous coordinates
%(4Vectors (x,y,0,1); This function models what a vision algorithm would
%return when you input a picture of a Tsai pattern: it will return the
%corners of the Grid. So this function returns a set of points that are
%likely to be the cornerns of the tsai pattern. Also, I know that for the
%FillImage function I will need to know the corners of the Entire Grid, so
%I am returning that as well.

%   This function takes two arguments: Size of the chequerboard and Spacing
%   between the tiles, and returns a set of points of the position of the
%   corners of the tiles in the chequerboard.

%% INPUT HYGIENE
if Size < Spacing
   error('The spacing between the corners of the chequerboard is bigger than the size of it'); 
end

if Size <= 0 || Spacing < 0
   error('The Spacing and the Size of the chequerboard need to be positive numbers'); 
end

%% CHEQUERBOARD
x = 0:Spacing:Size;
y = 0:Spacing:Size;
[X,Y] = meshgrid(x,y);
X = X(:)';
Y = Y(:)';

%Creates the 4Vector in the form (x,y,0,1) - Homogeneous Coordinates
Grid(1,:) = X;
Grid(2,:) = Y;
Grid(3,:) = zeros(length(X),1);
Grid(4,:) = ones(length(X),1);

%% FINDING CORNERS OF THE WHOLE GRID

%If Spacing is not a factor of Size, then the corners won't be necessarily
%where the size of the chequerboard is set to. For example, if Size is 5
%and the Spacing is 1.2, then the Corners will be at
%(0,0);(4.8,0);(0,4.8);(4.8,4.8);

MaxX = max(Grid(1,:));
MaxY = max(Grid(2,:));

GridCorners = [0 MaxX 0 MaxX
              0 MaxY MaxY 0
               0 0 0 0
               1 1 1 1];
           
%% POSITION GRID SO THAT ORIGIN IS IN THE MIDDLE
Grid(1,:) = Grid(1,:) - MaxX*ones(1,length(Grid(1,:)))/2;
Grid(2,:) = Grid(2,:) - MaxY*ones(1,length(Grid(2,:)))/2;
GridCorners(1,:) = GridCorners(1,:) - MaxX*ones(1,length(GridCorners(1,:)))/2;
GridCorners(2,:) = GridCorners(2,:) - MaxY*ones(1,length(GridCorners(2,:)))/2;

%% PLOTTING RESULT
%plot(Grid(1,:),Grid(2,:), 'b.'); %just for development use. Can be commented out
%hold on
%plot(GridCorners(1,:),GridCorners(2,:), 'r.','markers',15);

end

