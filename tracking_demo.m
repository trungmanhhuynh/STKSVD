%% Robust Online Multi-Object Tracking based on Tracklet Confidence
%% and Online Discriminative Appearance Learning (CVPR2014)
% Last updated date: 2014. 07. 27
%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.


function tracking_demo(sequenceName)
base = [pwd, '/'];
addpath(genpath(base));

mot_setting_params;

frame_start = 1;
if length(img_List) > 10
    frame_end = length(detections);
else
    frame_end = 10;
end

All_Eval = [];
cct = 0;
Trk = []; Trk_sets = []; all_mot =[];

%% Initiailization Tracklet
tstart1 = tic;
init_frame = frame_start + param.show_scan;

for i=frame_start:init_frame
    Obs_grap(i).iso_idx = ones(size(detections(i).x));
    Obs_grap(i).child = [];
    Obs_grap(i).iso_child =[];
end


[Obs_grap] = mot_pre_association(detections,Obs_grap,frame_start,init_frame);
st_fr = 1;
en_fr = init_frame;

for fr = frame_start:init_frame
    filename = strcat(img_path,img_List(fr).name);
    rgbimg = imread(filename);
    init_img_set{fr} = rgbimg;
end

[Trk,param,Obs_grap] = MOT_Initialization_Tracklets(init_img_set,Trk,detections,param,...
    Obs_grap,init_frame);

%% Tracking
result = [] ;
for fr = frame_start:init_frame
    [Trk,Trk_sets] = MOT_Tracking_Results(Trk,Trk_sets,fr);
    
    DrawOption.isdraw = 1;
    DrawOption.iswrite = 1;
    DrawOption.new_thr = param.new_thr;
    
    [resultFrame] = MOT_Draw_Tracking_Per_Frame(Trk_sets, out_path, img_path, img_List, DrawOption);
    result = [result ; resultFrame] ;
end
disp('Tracking objects...');
for fr = init_frame+1:frame_end
    disp([sprintf('Tracking:Frame_%04d',fr)]);
    
    filename = strcat(img_path,img_List(fr).name);
    rgbimg = imread(filename);
    init_img_set{fr} = rgbimg;
    
    %% Generate pseudo detections
  %  detections = mot_generate_pseudo_detections(Trk, detections, Obs_grap, param, fr, rgbimg);
    
    %% Local Association
    [Trk, Obs_grap, Obs_info] = MOT_Local_Association(Trk, detections, Obs_grap, param, fr, rgbimg, KSVDparam,LCKSVDparam);
    %% Global Association
    [Trk, Obs_grap] = MOT_Global_Association(Trk, Obs_grap, Obs_info,  param, KSVDparam,LCKSVDparam,fr);
       
   % [Trk, Obs_grap] = MOT_LostTarget_Association(Trk, Obs_grap, Obs_info,  param, KSVDparam,LCKSVDparam,fr);

    %% Tracklet Confidence Update
    [Trk] = MOT_Confidence_Update(Trk,param,fr, param.lambda);
    [Trk] = MOT_Type_Update(rgbimg,Trk,param.type_thr,fr);
    
    %% Tracklet State Update & Tracklet Model Update
    [Trk] = MOT_State_Update(Trk, param, fr);
    %% New Tracklet Generation
    [Trk, param, Obs_grap] = MOT_Generation_Tracklets(init_img_set,Trk,detections,param,...
        Obs_grap,fr);
    
    %% Dictionary learning
    if param.use_KSVD
        [KSVDparam] = KSVD_Online_Appearance_Learning(rgbimg,img_path,img_List,fr,Trk, param, KSVDparam);
    elseif param.use_LCKSVD
        [LCKSVDparam] = LCSVD_Online_Appearance_Learning(rgbimg,img_path,img_List,fr,Trk, param, LCKSVDparam);
    end 
    
    
    %% Tracking Results
    [Trk, Trk_sets] = MOT_Tracking_Results(Trk,Trk_sets,fr);
    
    DrawOption.isdraw = 1;
    DrawOption.iswrite = 1;
    DrawOption.new_thr = param.new_thr;
    %     % Box colors indicate the confidences of tracked objects
    %     % High (Red)-> Low (Blue)
    [resultFrame] = MOT_Draw_Tracking_Per_Frame(Trk_sets, out_path, img_path, img_List, DrawOption);
    result = [result ; resultFrame] ;

end
%%
disp('Tracking done...');
TotalTime = toc(tstart1);
AverageTime = TotalTime/(frame_start + frame_end);
disp([sprintf('Average running time:%.3f(sec/frame)', AverageTime)]);

%% Save tracking results
dlmwrite(['./Results/Euclidean/MOT17/test/' sequenceName '.txt'], result,'delimiter',',') ;


end 