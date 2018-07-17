%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.

%% Get image lists
machine = 2; % 1 : run on windows
% 2 : run on linux

if(machine == 1)
    det_path =[ 'D:\CUDenver\Research\Dataset\MOTchallenge2015\2DMOT2015\' sequenceName '\det\det.txt' ] ;
    detections = read_detection_file(det_path) ;
    img_path = ['D:\CUDenver\Research\Dataset\MOTchallenge2015\2DMOT2015\' sequenceName '\img1\' ];
    img_List = dir(strcat(img_path,'*.jpg'));
    %% Draw Tracking Results
    out_path = ['./Results/' sequenceName '/'];
else
    det_path =[ '/home/manh/Research/Dataset/MOTchallenge2015/2DMOT2015/' sequenceName '/det/det.txt' ] ;
    detections = read_detection_file(det_path) ;
    img_path = ['/home/manh/Research/Dataset/MOTchallenge2015/2DMOT2015/' sequenceName '/img1/' ];
    img_List = dir(strcat(img_path,'*.jpg'));
    %% Draw Tracking Results
    out_path = ['./Results/' sequenceName '/'];
 
end
%% Common parameter
param.label(1,:) = zeros(1,10000);
param.show_scan = 3;
param.new_thr = param.show_scan + 1;    % Temporal window size for tracklet initialization
param.local_thr = 0.4;                    % Threshold for local and global association
param.global_thr = 0.4;                    % Threshold for local and global association
param.type_thr = 0.5;                   % Threshold for changing a tracklet type
param.pos_var = diag([25^2 25^2]);      % Covariance used for motion affinity evalutation
param.alpha = 0.25;

%% Tracklet confidence
param.lambda = 1.2;
param.atten = 0.85;
param.init_prob = 0.75;                 % Initial confidence

%% Appearance Model
param.tmplsize = [64, 32];                           % template size (height, width)
param.Bin = 48;                                      % # of Histogram Bin
param.vecsize = param.tmplsize(1)*param.tmplsize(2);
param.subregion = 1;
param.subvec = param.vecsize/param.subregion ;
param.color.type = 'RGB';                            % RGB or HSV



%% Motion model
% kalman filter parameter
param.Ts = 1; % Frame rates

Ts = param.Ts;
F1 = [1 Ts;0 1];
Fz = zeros(2,2);
param.F = [F1 Fz;Fz F1]; % F matrix: state transition matrix

% Dynamic model covariance
q= 0.05;

Q1 = [Ts^4 Ts^2;Ts^2 Ts]*q^2;
param.Q = [Q1 Fz;Fz Q1];

% Initial Error Covariance
ppp = 5;
param.P = diag([ppp ppp ppp ppp]');
param.H = [1 0 0 0;0 0 1 0]; % H matrix: measurement model
param.R = 0.1*eye(2); % Measurement model covariance


%% ILDA parameters
% param.use_ILDA = 0; % 1:ILDA, 0: No-ILDA
% ILDA.n_update = 0;
% ILDA.eigenThreshold = 0.01;
% ILDA.up_ratio = 3;
% ILDA.duration = 5;
% ILDA.feat_data = [];
% ILDA.feat_label = [];


%% LCKSVD1 parameters
% param.use_LCKSVD1 = 0 ;
% LCKSVD1.n_update = 0;
% LCKSVD1.sparsitythres = [];     % sparsity prior
% LCKSVD1.sqrt_alpha = 4;         % weights for label constraint term
% LCKSVD1.sqrt_beta = 2;          % weights for classification err term
% LCKSVD1.dictsize =   0;         % dictionary size
% LCKSVD1.iterations = 1;        % iteration number
% LCKSVD1.iterations4ini = 1;     % iteration number for initialization
% LCKSVD1.training_feats = [] ;   % training features
% LCKSVD1.H_train = [] ;          % label stored in matrix type
% LCKSVD1.label_train = [] ;      % label
% LCKSVD1.D1 = [] ;
% LCKSVD1.X1 = [] ;
% LCKSVD1.T1 = [] ;
% LCKSVD1.W1 = [] ;

%% KSVD parameters
param.use_KSVD = 0 ;
KSVDparam.n_update  = 0 ;

%% LCKSVD parameters
param.use_LCKSVD = 1 ;
LCKSVDparam.n_update  = 0 ;
LCKSVDparam.sqrt_alpha = 4 ; % weights for label constraint term
LCKSVDparam.sqrt_beta = 2; % weights for classification err term


