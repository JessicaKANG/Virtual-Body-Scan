function cameras = loadcameradata(dataDir, idx)
%LOADCAMERADATA: Load the dino data
%
%   CAMERAS = LOADCAMERADATA() loads the dinosaur data and returns a
%   structure array containing the camera definitions. Each camera contains
%   the image, internal calibration and external calibration.
%
%   CAMERAS = LOADCAMERADATA(IDX) loads only the specified file indices.
%
%   Example:
%   >> cameras = loadcameradata(1:3);
%   >> showcamera(cameras)
%
%   See also: SHOWCAMERA

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.0 $    $Date: 2006/06/30 00:00:00 $

cameras = struct( ...
    'Image', {}, ...
    'P', {}, ...
    'K', {}, ...
    'R', {}, ...
    'T', {}, ...
    'Silhouette', {} );

%% First, import the camera Pmatrices
load('cameraParams_walk2.mat');


%% Now loop through loading the images
tmwMultiWaitbar('Loading images',0);
for ii=idx(:)'
    
    filename = fullfile( dataDir, sprintf( 'im.%05d.JPG', ii ) );

    cameras(ii).Image = imread( filename );

%% get projection from calibration
    
    fly = cameraParams_walk2;
    
    K = fly.IntrinsicMatrix';
    cameras(ii).K = K/K(3,3);
     R = fly.RotationMatrices(:,:,ii); 
     t = fly.TranslationVectors(ii,:);
     t = t * -0.002;
     t = t';
     p = K * [R' t];
     P{ii} = p;
     
    cameras(ii).rawP = P{ii};
    cameras(ii).P = P{ii};
    
    cameras(ii).R = R';
    cameras(ii).T = -R*t;
    
    cameras(ii).Silhouette = [];
    tmwMultiWaitbar('Loading images',ii/max(idx));
end
tmwMultiWaitbar('Loading images','close');

