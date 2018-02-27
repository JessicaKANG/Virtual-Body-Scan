imageDir = fullfile('hm/*.JPG');

di = dir(imageDir);
imds = imageDatastore(imageDir);

for k= 1:length(di)
    frames.images{k} = ['hm/',di(k).name];
end

dir_R='hm_R/';
%dir_G='human_G/';
dir_B='hm_B/';

% T = 80;
% for i=1:k
%     I = imread(frames.images{i});  
%     R = I(:,:,1)>T;
%     G = I(:,:,2)>T;
%     B = I(:,:,3)>T;
%     
%     num_seq=num2str(i,'%05i');
% 
%     nomefile_R=strcat('imR_',num_seq,'.JPG');
%     nomefile_R=strcat(dir_R,nomefile_R);
%     
%     nomefile_G=strcat('imG_',num_seq,'.JPG');
%     nomefile_G=strcat(dir_G,nomefile_G);
%     
%     nomefile_B=strcat('imB_',num_seq,'.JPG');
%     nomefile_B=strcat(dir_B,nomefile_B);
%     
%     imwrite(R,nomefile_R); 
%     imwrite(G,nomefile_G);
%     imwrite(B,nomefile_B);
%     
% end

T = 70;
for i=1:k
    I = imread(frames.images{i});  
    R = I(:,:,1)>T;
    %G = I(:,:,2);
    B = I(:,:,3)>T;
    
    num_seq=num2str(i,'%05i');

    nomefile_R=strcat('imR_',num_seq,'.JPG');
    nomefile_R=strcat(dir_R,nomefile_R);
    
%     nomefile_G=strcat('imG_',num_seq,'.JPG');
%     nomefile_G=strcat(dir_G,nomefile_G);
    
    nomefile_B=strcat('imB_',num_seq,'.JPG');
    nomefile_B=strcat(dir_B,nomefile_B);
    
    imwrite(R,nomefile_R); 
%     imwrite(G,nomefile_G);
    imwrite(B,nomefile_B);
    
end
