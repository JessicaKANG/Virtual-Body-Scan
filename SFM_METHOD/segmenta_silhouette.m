function silhouette=segmenta_silhouette(img_in)

    [rows,cols]=size(img_in);
    hy = fspecial('sobel');
    hx = hy';
    %I=rgb2gray(img_in);
    I=img_in(:,:,1);
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
    
    
    a=gradmag>20;
    
    mask = imerode(a,strel('disk',2));
    mask = imdilate(mask,strel('disk',3));
    
   
    
    
    for j=1:10:360
        
  %      mask = imopen(mask,strel('line',20,i));
        mask = imclose(mask,strel('line',2,j));

    end
    
    
    mask = imdilate(mask,strel('line',8,90));
    mask = imdilate(mask,strel('line',8,45));
    mask = imdilate(mask,strel('line',8,0));
    mask = imdilate(mask,strel('line',8,135));
     %mask(:,1)=1;
     mask(1780,:)=1;
     mask(1:1700,1)=1;
    b=imfill(mask,'holes');
   % b(1000,:)=0;
    STATS = regionprops(b,'Area','Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelIdxList','ConvexArea','ConvexHull','ConvexImage','Extrema','BoundingBox');

    [B,L] = bwboundaries(b,'noholes');
    
    silhouette=b;
    