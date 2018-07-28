function [LCKSVDparam] = LCSVD_Online_Appearance_Learning(rgbimg,img_path,img_List,fr,Trk, param, LCKSVDparam)


% Intialize parameters
training_feats = [] ;
training_labels = [] ;
training_states = [] ;
training_fr = [] ;
% extract training features
% use features in high confidence for tracking
for i=1:length(Trk)
    % Pactch cropping
    highConfIdx  = find(Trk(i).Conf_Mat(:) > 0.5);
    states = cell2mat(Trk(i).state(highConfIdx));
    
    [bbs] = mot_impatch_crop(states');
    % Feature extraction
    for j=1:length(bbs)
        img_idx = fr - length(bbs) + j;
        filename = strcat(img_path,img_List(img_idx).name);
        rgbimg = imread(filename);
        col_hist = mot_appearance_model_generation(rgbimg,param,bbs{j}');
        col_hist = squeeze(col_hist);
        training_feats = [training_feats, col_hist];
        nofd = size(col_hist,2);
        training_labels = [training_labels, repmat(Trk(i).label, 1, nofd)];
    end
    training_states = [training_states , states ] ;    
    %frNumber = Trk(i).ifr:Trk(i).last_update ;    
    training_fr = [training_fr , highConfIdx' ] ;
    
    
end
if(isempty(training_feats)) 
    return ;
end

%% Learn dictionary for  tracklets

%Initialize dictionary
D = [] ;D_states = [] ; D_fr = [];
dict_labels = [];
classList = [] ;
nAtoms = 5 
for labelId = 1:max(training_labels)
    dataId = find(training_labels == labelId);
    if size(dataId,2) > nAtoms
        stride = round(size(dataId,2) / nAtoms);
        strideIdx= 1:stride:size(dataId,2);
        dataId = dataId(strideIdx);
    end
    D = [D training_feats(:,dataId)] ;
    D_states = [D_states training_states(:,dataId)];
    D_fr = [ D_fr  training_fr(:,dataId)];
    dict_labels = [dict_labels training_labels(dataId)] ;
end

%create training label in 2d matrix form
[H_train] = generate_training_label_matrix(training_labels) ;
H_train(sum(H_train,2) == 0,:) = [];

LCKSVDparam.K =  size(D ,2) ;                             % dictionary size
LCKSVDparam.sparsitythres         = ceil(0.1* LCKSVDparam.K);           % number of coefficients
LCKSVDparam.numIteration = 5;                              % number of iterations
LCKSVDparam.dictLabels = dict_labels ;
LCKSVDparam.dataLabels = training_labels ;
LCKSVDparam.D_states = D_states ;
LCKSVDparam.D_fr = D_fr ;
LCKSVDparam.Dinit = D ;
%Initialize classifier parameter also
%learn seperate dictionary for each class
[Dinit,Tinit,Winit,Q_train]= ...
    initialization4LCKSVD(training_feats,  training_states , training_fr, training_labels,H_train,LCKSVDparam) ;

%learn LCKSVD
[LCKSVDparam.D2,X2,T2,LCKSVDparam.W2] = labelconsistentksvd2(training_feats,Dinit,Q_train,...
    Tinit,H_train,Winit,...
    LCKSVDparam.numIteration,LCKSVDparam.sparsitythres,LCKSVDparam.sqrt_alpha,...
    LCKSVDparam.sqrt_beta);

LCKSVDparam.n_update = 1 ;

end

