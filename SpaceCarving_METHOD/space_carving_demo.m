
%% Setup
% All functions for this demo are in the "spacecarving" package and the
% data in the "InputData" folder.
import spacecarving.*;
datadir = fullfile( fileparts( mfilename( 'fullpath' ) ), 'InputData/walk' );
close all;


%% Load the Camera and Image Data

cameras = loadcameradata( datadir, 1:16 );
%spacecarving.showcamera(cameras);

montage( cat( 4, cameras.Image ) );
set( gcf(), 'Position', [100 100 600 600] )
axis off;

%% Convert the Images into Silhouettes
% The image in each camera is converted to a binary image.
for c=1:numel(cameras)
    cameras(c).Silhouette = getsilhouette( cameras(c).Image );
end

figure('Position',[100 100 600 300]);

subplot(1,2,1)
imshow( cameras(c).Image );
title( 'Original Image' )
axis off

subplot(1,2,2)
imshow( cameras(c).Silhouette );
title( 'Silhouette' )
axis off

makeFullAxes( gcf );

%% Work out the space occupied by the scene
% Initially we have no idea where to look for the model. We will assume
% that the model lies in the space spanned by the cameras and their
% principal view directions. We then perform a very low-res space-carve
% using all the cameras to narrow down exactly where the object is. This
% isn't foolproof, but good enough for this demo.
[xlim,ylim,zlim] = findmodel( cameras )


%% Create a Voxel Array
% This creates a regular 3D grid of elements ready for carving away. The
% input arguments set the bounding box and the approximate number of voxels
% to create. Since the voxels must be cubes, the actual number generated
% may be a little more or less. We'll start with about six million voxels
% (you may need to reduce this if you don't have enough memory).
%
% For "real world" implementations of space carving you certainly wouldn't
% create a uniform 3D matrix like this. OctTrees and other refinement
% representations give much better efficiency, both in memory and
% computational time.
voxels = makevoxels( xlim, ylim, zlim, 6000000 );
starting_volume = numel( voxels.XData );

% Show the whole scene
figure('Position',[100 100 600 400]);
showscene( cameras, voxels );

%% Carve the Voxels Using the First Camera Image
% The silhouette is projected onto the voxel array.
% Any voxels that lie outside the silhouette are carved away, leaving only
% points inside the model. Using just one camera, we end up with a
% dinosaur-prism - a single camera provides no information on depth.
voxels = carve( voxels, cameras(1) );

% Show Result
figure('Position',[100 100 600 300]);
subplot(1,2,1)
showscene( cameras(1), voxels );
title( '1 camera' )
subplot(1,2,2)
showsurface( voxels )
title( 'Result after 1 carving' )

%% Add More Views
% Adding more views refines the shape. If we include two more, we already
% have something recognisable, albeit a bit "boxy".
voxels = carve( voxels, cameras(4) );
voxels = carve( voxels, cameras(7) );

% Show Result
figure('Position',[100 100 600 300]);
subplot(1,2,1)
title( '3 cameras' )
showscene( cameras([1 4 7]), voxels );
subplot(1,2,2)
showsurface(voxels)
title( 'Result after 3 carvings' )


%% Now Include All the Views
% In this case we have 16 views (roughly every 10 degrees).
for ii=1:numel(cameras)
    voxels = carve( voxels, cameras(ii) );
end

%%%%%%%%%%%%%
figure('Position',[100 100 600 300]);
subplot(1,2,1)
title( '16 cameras' )
showscene( cameras, voxels );
subplot(1,2,2)
showsurface(voxels)
title( 'Result after 16 carvings' )
%%%%%%%%%%%%%%

figure('Position',[100 100 600 700]);
showsurface(voxels)
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 16 carvings' )

final_volume = numel( voxels.XData );
fprintf( 'Final volume is %d (%1.2f%%)\n', ...
    final_volume, 100 * final_volume / starting_volume )

%% Get real values
% We ideally want much higher resolution, but would run out of memory.
% Instead we can use a trick and assign real values to each voxel instead
% of a binary value. We do this by moving all voxels a third of a square in
% each direction then seeing if they get carved off. The ratio of carved to
% non-carved for each voxel gives its score (which is roughly equivalent to
% estimating how much of the voxel is inside).
offset_vec = 1/3 * voxels.Resolution * [-1 0 1];
[off_x, off_y, off_z] = meshgrid( offset_vec, offset_vec, offset_vec );

num_voxels = numel( voxels.Value );
num_offsets = numel( off_x );
scores = zeros( num_voxels, 1 );
for jj=1:num_offsets
    keep = true( num_voxels, 1 );
    myvoxels = voxels;
    myvoxels.XData = voxels.XData + off_x(jj);
    myvoxels.YData = voxels.YData + off_y(jj);
    myvoxels.ZData = voxels.ZData + off_z(jj);
    for ii=1:numel( cameras )
        [~,mykeep] = carve( myvoxels, cameras(ii) );
        keep(setdiff( 1:num_voxels, mykeep )) = false;
    end
    scores(keep) = scores(keep) + 1;
end
voxels.Value = scores / num_offsets;
figure('Position',[100 100 600 700]);
showsurface( voxels );
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 16 carvings with refinement' )


%% Final Result
% For online galleries and the like we would colour each voxel from the
% image with the best view (i.e. nearest normal vector), leading to a
% colour 3D model. This makes zero difference to the volume estimate (which
% was the main purpose of the demo), but does look pretty!
figure('Position',[100 100 600 700]);
ptch = showsurface( voxels );
colorsurface( ptch, cameras );
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 16 carvings with refinement and colour' )

