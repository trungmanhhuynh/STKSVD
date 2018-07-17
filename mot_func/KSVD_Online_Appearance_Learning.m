function [KSVDparam] = KSVD_Online_Appearance_Learning(rgbimg,img_path,img_List,fr,Trk, param, KSVDparam)

% Intialize parameters
training_feats = [] ; 
training_labels = [] ; 

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
end


% Set parameters for KSVD
KSVDparam.numIteration = 5;                              % number of iterations 
KSVDparam.errorFlag    = 0 ;                             % fix number of coefficients will be used 
KSVDparam.preserveDCAtom = 0 ;                            %
KSVDparam.displayProgress = 1 ;
KSVDparam.nAtomsPerClass = 10 ;
%Initialize dictionary 
D = [] ; 
dict_labels = []; 
for labelId = 1:max(training_labels)
    dataId = find(training_labels == labelId); 
    realnAtoms = min(10,size(dataId,2)); 
    dataId = dataId(end-realnAtoms+1:end);
    D = [D training_feats(:,dataId)] ;
    dict_labels = [dict_labels training_labels(dataId)] ; 
            
end 

KSVDparam.InitializationMethod = 'GivenMatrix' ;       % Use data elements as dictionary 
KSVDparam.initialDictionary = D ;
KSVDparam.K =  size(D ,2) ;               % dictionary size 
KSVDparam.L         = ceil(0.1* KSVDparam.K);           % number of coefficients 

disp([sprintf('dictionary size = %04d',size(D,2))]);

% Start train dictionary 
[Dictionary,output] = KSVD(training_feats,KSVDparam);

KSVDparam.n_update = 1;
KSVDparam.D = Dictionary ;
KSVDparam.dict_labels = dict_labels ;

end
