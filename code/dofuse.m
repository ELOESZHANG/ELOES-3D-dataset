function dofuse(data,frame_list,wSF,sptemp,folderName)
rgbPath=['./input/RGB',folderName];
finalsalPath=['./output/finalsaliency',folderName];
eps=0.05;
lthred=80;hthred=180;
sp_list = data.superpixels;
bx_flow=data.bx_flow;by_flow=data.by_flow;
param_list = set_param;
imnames = dir([ rgbPath '*' 'bmp']);
wSFD=cell(length(imnames),1);
ms=cell(length(imnames),1);
for showNum = 1:length(imnames)
    appearance=data.appearance{showNum};
    maxApp=max(appearance(:));minApp=min(appearance(:));
    appearance=(appearance-minApp)/(maxApp-minApp);
    depth=double(data.Depth{showNum}(:,:,1));
    maxDepth=max(depth(:));minDepth=min(depth(:));
    depth=(depth-minDepth)/(maxDepth-minDepth);
    superpixel=data.superpixels{showNum};
    for i=1:max(superpixel(:))
        [depX,depY]=find(superpixel==i);
        sumTemp=0;
        for j=1:length(depX)
            sumTemp=depth(depX(j),depY(j))+sumTemp;
        end
        meanSumTemp=sumTemp/length(depX);
        weight=meanSumTemp;
        for j=1:length(depX)
            appearance(depX(j),depY(j))=appearance(depX(j),depY(j))*weight;
        end
        wSFD{showNum}(i)=wSF{showNum}(i)*weight;
        ms{showNum}(i)=((sptemp{showNum}(i))*0.5+(wSF{showNum}(i))*0.5)*weight;%Wf
       
    end
    
    wSFD{showNum}=wSFD{showNum}';%深度加权空间显著图      
    %% combine Appearance and Location (运动显著图)
    adjcell=data.adjcMatrix;
    depth=double(data.Depth{showNum}(:,:,1));
    str=strel('square',4);
    Img=imopen(depth,str);
    [f,c2]=cv(Img,200);%得到深度置信面
    if c2<lthred
        a=0.5;
    elseif c2>hthred
        a=0.9;
    else
        x=(2.197/(hthred-lthred))*c2; 
        a=1/(1+exp(-x));%得到深度置信权值alpha
    end

    %能量优化得到最后的视频显著性
    bgWeight=1-wSFD{showNum};%Wb
    fgWeight=ms{showNum};%Wf
    conn_edge_mat = construct_edge_matrix(sp_list{showNum},1);
    long_edge_mat = construct_edge_matrix(sp_list{showNum},4);
        [init_aff, ~, ~, ~] = construct_affinity_matrix(frame_list{showNum}, sp_list{showNum}, ...
            bx_flow{showNum}, by_flow{showNum}, conn_edge_mat, long_edge_mat, param_list);
    mu = 0.1; 
    W = init_aff+adjcell{showNum}*mu;                      %add regularization term
    D = diag(sum(W));
    bgLambda = 4;                                   
    E_bg = diag(bgWeight*(1-a)*bgLambda);               %background term
    E_fg = diag(fgWeight*a);                           %foreground term

    spNum = length(bgWeight);
    saliency =(D - W + E_bg + E_fg) \ (E_fg * ones(spNum, 1));

     %归一化显著性
    for i=1:max(superpixel(:))
            maxtemp=max(saliency(:));
            mintemp=min(saliency(:));
            saliency=((saliency-mintemp)/(maxtemp-mintemp+eps))*1;
    end

    superpixels=sp_list{showNum};
    imName = [ rgbPath imnames(showNum).name ];  
    [input_im,w]=removeframe(imName);% run a pre-processing to remove the image frame               
    [m,n,r]=size(input_im);
    image_sam_1=zeros(m,n);
    image_sam_1(:)=saliency(superpixels(:));
    image_saliency_1 = zeros(w(1), w(2));
    image_saliency_1(w(3):w(4), w(5):w(6)) = image_sam_1;
    finaloutname=[finalsalPath imnames(showNum).name(1:end-4) '.bmp'];
    imwrite(image_saliency_1,finaloutname);%输出最终的显著性图
end
end

