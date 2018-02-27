function correct_images(cameraparam, video)

%[a,b]=size(video);

dir_corr='corrette/';
dir_silhouettes='silhouettes/';

%[rows,cols,bands]=size(v);

b = video.NumberOfFrames;
for i=1:10:b
    frames = read(video,i);
    %I = undistortImage(video(i).cdata, cameraparam);
    %I = undistortImage(video(:,:,:,i), cameraparam);
    %I = undistortImage(frames,cameraparam);
    I = frames;
    silhouette=segmenta_silhouette(I);
    
    
    
    num_seq=num2str(i,'%05i');

    nomefile_corr=strcat('imm_',num_seq,'.tif');
    nomefile_corr=strcat(dir_corr,nomefile_corr);
    
    nomefile_silhouette=strcat('silhouette_',num_seq,'.tif');
    nomefile_silhouette=strcat(dir_silhouettes,nomefile_silhouette);
    
    
    imwrite(I,nomefile_corr); 
    imwrite(silhouette,nomefile_silhouette); 
    
end