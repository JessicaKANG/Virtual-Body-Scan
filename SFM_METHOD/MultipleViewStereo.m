function [Graph,mergedGraph] = MultipleViewStereo(Graph,mergedGraph,frames,visualize)

%% dense matching by Matching Propagation(ZNCC)
fprintf('dense matching ...\n');
for frame=1:frames.length-1
    Graph{frame} = denseMatch(Graph{frame}, frames, frame, frame+1);
end

%% dense reconstruction
fprintf('triangulating dense points ...\n');
for frame=1:frames.length-1
    clear X;
    P{1} = frames.K * mergedGraph.Mot(:,:,frame);
    P{2} = frames.K * mergedGraph.Mot(:,:,frame+1);
    %par
    for j=1:size(Graph{frame}.denseMatch,2)
        X(:,j) = vgg_X_from_xP_nonlin(reshape(Graph{frame}.denseMatch(1:4,j),2,2),P,repmat([frames.imsize(2);frames.imsize(1)],1,2));
    end
    X = X(1:3,:) ./ X([4 4 4],:);
    x1= P{1} * [X; ones(1,size(X,2))];
    x2= P{2} * [X; ones(1,size(X,2))];
    x1 = x1(1:2,:) ./ x1([3 3],:);
    x2 = x2(1:2,:) ./ x2([3 3],:);
    Graph{frame}.denseX = X;
    Graph{frame}.denseRepError = sum(([x1; x2] - Graph{frame}.denseMatch(1:4,:)).^2,1);
    
    Rt1 = mergedGraph.Mot(:, :, frame);
    Rt2 = mergedGraph.Mot(:, :, frame+1);
    C1 = - Rt1(1:3, 1:3)' * Rt1(:, 4);
    C2 = - Rt2(1:3, 1:3)' * Rt2(:, 4);
    view_dirs_1 = bsxfun(@minus, X, C1);
    view_dirs_2 = bsxfun(@minus, X, C2);
    view_dirs_1 = bsxfun(@times, view_dirs_1, 1 ./ sqrt(sum(view_dirs_1 .* view_dirs_1)));
    view_dirs_2 = bsxfun(@times, view_dirs_2, 1 ./ sqrt(sum(view_dirs_2 .* view_dirs_2)));
    Graph{frame}.cos_angles = sum(view_dirs_1 .* view_dirs_2);
    
    c_dir1 = Rt1(3, 1:3)';
    c_dir2 = Rt2(3, 1:3)';
    Graph{frame}.visible = (sum(bsxfun(@times, view_dirs_1, c_dir1)) > 0) & (sum(bsxfun(@times, view_dirs_2, c_dir2)) > 0);
end

%% output as ply file to open in Meshlab (Open Software available at http://meshlab.sourceforge.net )
plyPoint = [];
plyColor = [];
for frame=1:frames.length-1
    goodPoint =  (Graph{frame}.denseRepError < 0.05) & (Graph{frame}.cos_angles < cos(5 / 180 * pi)) & Graph{frame}.visible;
    X = Graph{frame}.denseX(:,goodPoint);
    % get the color of the point
    P{1} = frames.K * mergedGraph.Mot(:,:,frame);
    x1= P{1} * [X; ones(1,size(X,2))];
    x1 = round(x1(1:2,:) ./ x1([3 3],:));
    x1(1,:) = frames.imsize(2)/2 - x1(1,:);
    x1(2,:) = frames.imsize(1)/2 - x1(2,:);
    indlin = sub2ind(frames.imsize(1:2),x1(2,:),x1(1,:));
    im = imresize(imread(frames.images{frame}),frames.imsize(1:2));
    imR = im(:,:,1);
    imG = im(:,:,2);
    imB = im(:,:,3);
    colorR = imR(indlin);
    colorG = imG(indlin);
    colorB = imB(indlin);
    plyPoint = [plyPoint X];
    plyColor = [plyColor [colorR; colorG; colorB]];
end

points2ply('dense.ply',plyPoint,plyColor);

fprintf('SFMedu is finished.\n Open the result dense.ply in Meshlab (Open Software available at http://meshlab.sourceforge.net ).\n Enjoy!\n');

%% visualize the dense point cloud

if visualize
    figure;
    for frame=1:frames.length-1
        hold on
        goodPoint =  Graph{frame}.denseRepError < 0.05;
        plot3(Graph{frame}.denseX(1,goodPoint),Graph{frame}.denseX(2,goodPoint),Graph{frame}.denseX(3,goodPoint),'.b','Markersize',1);
    end
    hold on
    grid on
    plot3(mergedGraph.Str(1,:),mergedGraph.Str(2,:),mergedGraph.Str(3,:),'.r')
    axis equal
    title('dense cloud')
    for i=1:frames.length
        drawCamera(mergedGraph.Mot(:,:,i), frames.imsize(2), frames.imsize(1), frames.K(1,1), 0.001,i*2-1,i);
    end
    axis tight
end