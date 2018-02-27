clc;
disp('Visual Body Scan by Kang & Tiara');
disp('Version 4 @ 2017');
disp('SFM code based on SFMedu Princeton');
disp('Space Carving code based on SpaceCarving Oxford');

%% set up things
clear ;
close all;


addpath(genpath('matchSIFT'));
addpath(genpath('denseMatch'));
addpath(genpath('RtToolbox'));
addpath(genpath('SfmToolbox'));

 load body_21fs
 %load 245 %doll 1st point cloud
 %load 432 %doll 2nd point cloud
  if visualize, visualizeGraph(mergedGraph,frames); title('after bundle adjustment'); end
%}

%%
%{
visualize = true;

%% Read the Input Image Sequence and display

%imageDir = fullfile('images/*.JPG');%for testing with image sequence
imageDir = fullfile('images/*.tif');% testing image extracted from video

di = dir(imageDir);
imds = imageDatastore(imageDir);

for k= 1:length(di)%length(frames.images)-1:length(di)%1
    frames.images{k} = ['images/',di(k).name];
end

frames.length = length(frames.images);

% Display the input images.
if visualize 
   figure;
   montage(imds.Files, 'Size', [1,frames.length]);
   title('Input Image Sequence');
end

%% Load cameraParam and resize image 

load('cameraParams.mat');
f = cameraParams.FocalLength;
frames.focal_length = f(1); 

fprintf('Before image resize focal_length = %d\n',frames.focal_length);

% Resize image
maxSize = 1024;
frames.imsize = size(imread(frames.images{1}));
if max(frames.imsize)>maxSize
    scale = maxSize/max(frames.imsize);
    frames.focal_length = frames.focal_length * scale;
    frames.imsize = size(imresize(imread(frames.images{1}),scale));
end

fprintf('After image resize focal_length = %d\n',frames.focal_length);

frames.K = f2K(frames.focal_length);
disp('intrinsics:');
disp(frames.K);

%% SIFT matching image pairs and Fundamental Matrix Estimation

for frame=1:frames.length-1%length(frames.images)-1:frames.length-1 %frame=15:frames.length-1 %2   
    % need to set this random seed to produce exact same result
    s = RandStream('mcg16807','Seed',10); 
    RandStream.setGlobalStream(s);
    
    % keypoint matching
    pair = match2viewSIFT(frames, frame, frame+1);% group two neighbour images
     
    % Estimate Fundamental matrix
    pair = estimateF(pair); %fits fundamental matrix using RANSAC   
    
    % Convert Fundamental Matrix to Essential Matrix
    pair.E = frames.K' * pair.F * frames.K; % MVG Page 257 Equation 9.12

    % Get Poses from Essential Matrix
    pair.Rt = RtFromE(pair,frames);
    
    % Convert the pair into the BA format
    Graph{frame} = pair2graph(pair,frames);
    
    % re-triangulation
    Graph{frame} = triangulate(Graph{frame},frames);
 
    % 2-view bundle adjustment
    Graph{frame} = bundleAdjustment(Graph{frame});
end

%% merge two point cloud

fprintf('\n\nmerging graphs....\n');

mergedGraph = Graph{1};

for frame=2:frames.length-1 
    % merge graph
    mergedGraph = merge2graphs(mergedGraph,Graph{frame});
    
    % re-triangulation
    mergedGraph = triangulate(mergedGraph,frames);
    
    % bundle adjustment
    mergedGraph = bundleAdjustment(mergedGraph);
    
    % outlier rejection
    mergedGraph = removeOutlierPts(mergedGraph, 10);
    
    % bundle adjustment
    mergedGraph = bundleAdjustment(mergedGraph);    
      
end

% visualize camera position and sparse point cloud
if visualize, visualizeGraph(mergedGraph,frames); title('after bundle adjustment'); end
%}
%%

%% Multiple View Stereo: dense matching by Matching Propagation(ZNCC)
[Graph,mergedGraph] = MultipleViewStereo(Graph,mergedGraph,frames,visualize);
% output as ply file to open in Meshlab (Open Software available at http://meshlab.sourceforge.net )

