
clc;
close all;
clear all;
%% Add paths
addpath(genpath('Optical FlowCVPR2016'))
addpath(genpath('SLIC'))
addpath(genpath('others'))
folderName='/car3/';
%% input paths
rgbPath=['./input/RGB',folderName];
depthPath=['./input/Depth',folderName];
%% output paths
supPath=['./output/superpixel',folderName];
optPath=['./output/optical flow',folderName];
finalsalPath=['./output/finalsaliency',folderName];
if ~exist(supPath,'file')
    mkdir(supPath);
end
if ~exist(finalsalPath,'file')
    mkdir(finalsalPath);
end
if ~exist(optPath,'file')
    mkdir(optPath);
end
%% load path
data.supPath=supPath;data.optPath=optPath;%%%%
%% Load frames
[frame_list, orig_size, border_tblr] = load_frames(rgbPath);
 %% Optical flow computation
[fx_flow, fy_flow] = estimate_forward_optcial_flow(frame_list, optPath);
[bx_flow, by_flow] = estimate_backward_optical_flow(frame_list, optPath);
    
[fx_flow_two, fy_flow_two] = estimate_forward_optcial_flow_two(frame_list, optPath);
[bx_flow_two, by_flow_two] = estimate_backward_optical_flow_two(frame_list, optPath);

fx_flow{end} = bx_flow{end};
fy_flow{end} = by_flow{end};

bx_flow{1} = fx_flow{1};
by_flow{1} = fy_flow{1};
data.fx_flow=fx_flow;data.fx_flow_two=fx_flow_two;data.fy_flow=fy_flow;data.fy_flow_two=fy_flow_two;
data.bx_flow=bx_flow;data.bx_flow_two=bx_flow_two;data.by_flow=by_flow;data.by_flow_two=by_flow_two;
%% load depth data 
data.Depth=loadDepth(depthPath);%%%%
%% load superpixels
imnames = dir([ rgbPath '*' 'bmp']);
supcell=cell(length(imnames),1);
adjcell=cell(length(imnames),1);
for ii = 1:length(imnames)
    disp(ii);   
 %%------------------------generate superpixels----------------------%%
    im=imread(strcat(rgbPath,imnames(ii).name));
    [idxImg, adjcMatrix, pixelList] = SLIC_Split(im, 500);
    spNum=length(pixelList);
    suppic=drawregionboundaries(idxImg, im, [255 255 255]);
    outname=[supPath imnames(ii).name(1:end-4) '.bmp'];
    imwrite(suppic,outname);% ‰≥ˆ≥¨œÒÀÿ∑÷∏ÓÕº∆¨
    supcell{ii}=idxImg;
    adjcell{ii}=adjcMatrix;
end
data.superpixels=supcell;%%%%
data.adjcMatrix=adjcell;%%%%
%%-----------------º∆À„ø’º‰œ‘÷¯ÕºSs---------------%%
[appearance,SF]=compuspa(data,rgbPath);
data.appearance=appearance;%%%%
frames = length( supcell );
wSF = cell( frames, 1 );
for i = 1: frames 
     maxval=max(SF{i}(:,1));
     minval=min(SF{i}(:,1));
     wSF{i}(:,1)=(SF{i}(:,1)-minval)/(maxval-minval+eps);
end
%%-----------------º∆À„ ±º‰œ‘÷¯ÕºSm---------------%%    
sptemp_list=computem(supcell,frame_list,border_tblr,orig_size,data);
frames = length( supcell );
sptemp = cell( frames, 1 );
for i = 1: frames 
    maxval=max(sptemp_list{i}(:,1));
    minval=min(sptemp_list{i}(:,1));
    sptemp{i}(:,1)=(sptemp_list{i}(:,1)-minval)/(maxval-minval+eps);
end
%% doEdge 
dofuse(data,frame_list,wSF,sptemp,folderName); 


