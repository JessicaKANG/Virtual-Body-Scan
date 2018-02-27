function [xlim,ylim,zlim] = findmodel( cameras )
%FINDMODEL: locate the model to be carved relative to the cameras
%
%   [XLIM,YLIM,ZLIM] = FINDMODEL(CAMERAS) determines the bounding box (x, y
%   and z limits) of the model which is to be carved. This allows the
%   initial voxel volume to be constructed.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.0 $    $Date: 2006/06/30 00:00:00 $


camera_positions = cat( 2, cameras.T );

x = max(abs(min( camera_positions(1,:) )),abs(max( camera_positions(1,:) )));
z = max(abs(min( camera_positions(3,:) )),abs(max( camera_positions(3,:) )));


xlim = [-x, x];
zlim = [-z, z];
ylim = [min( camera_positions(2,:)), max( camera_positions(2,:) )];

% For the ylim we need to see where each camera is looking. 
range = 0.6 * sqrt( diff( xlim ).^2 + diff( zlim ).^2 );

for ii=1:numel( cameras )
    viewpoint = cameras(ii).T - range * spacecarving.getcameradirection( cameras(ii) );
    ylim(1) = min( ylim(1), viewpoint(2) );
    ylim(2) = max( ylim(2), viewpoint(2) );
end

voxels = spacecarving.makevoxels( xlim, ylim, zlim, 40000 );
figure('Position',[100 100 600 400]);
spacecarving.showscene( cameras, voxels );

%Move the limits in a bit since the object must be inside the circle
xrange = diff( xlim );
xlim = xlim + xrange/4*[1 -1];
zrange = diff( zlim );
zlim = zlim + zrange/4*[1 -1];

voxels = spacecarving.makevoxels( xlim, ylim, zlim, 40000 );
figure('Position',[100 100 600 400]);
spacecarving.showscene( cameras, voxels );

% Now perform a rough and ready space-carving to narrow down where it is
for ii=1:numel(cameras)
    voxels = spacecarving.carve( voxels, cameras(ii) );
end

% Make sure something is left!
if isempty( voxels.XData )
    error( 'SpaceCarving:FindModel', 'Nothing left after initial serach! Check your camera matrices.' );
end

% Check the limits of where we found data and expand by the resolution
xlim = [min( voxels.XData ),max( voxels.XData )] + 2*voxels.Resolution*[-1 1];
ylim = [min( voxels.YData ),max( voxels.YData )] + 2*voxels.Resolution*[-1 1];
zlim = [min( voxels.ZData ),max( voxels.ZData )] + 2*voxels.Resolution*[-1 1];
