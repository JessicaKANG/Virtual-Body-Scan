disp('Extracting image frames from video');

%% set up things
clear;
close all;

%% load cameraparam
cameraparam = load('cam_jess.mat');
cameraparam=cameraparam.cameraParams;

%% correct images from video

video=VideoReader('IMG_2475.MOV');

correct_images(cameraparam,video);

