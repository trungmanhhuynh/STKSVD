% ========================================================================
% Initialization for Label consistent KSVD algorithm
% USAGE: [Dinit,Tinit,Winit,Q] = initialization4LCKSVD(training_feats,....
%                               H_train,dictsize,iterations,sparsitythres)
% Inputs
%       training_feats  -training features
%       H_train         -label matrix for training feature
%       dictsize        -number of dictionary items
%       iterations      -iterations
%       sparsitythres   -sparsity threshold
% Outputs
%       Dinit           -initialized dictionary
%       Tinit           -initialized linear transform matrix
%       Winit           -initialized classifier parameters
%       Q               -optimal code matrix for training features
%
% Author: Zhuolin Jiang (zhuolin@umiacs.umd.edu)
% Date: 10-16-2011
% ========================================================================


function [Dinit,Tinit,Winit,Q]=initialization4LCKSVD(training_feats,training_states , training_fr, ...
    training_labels,H_train,LCKSVDparam) 

numClass = size(H_train,1); % number of objects
Dinit = [] ;
dictLabelMat = [] ; 
for classid=1:numClass
    
    %Create dictionary and training data for each class
    col_ids = find(H_train(classid,:)==1);
    data_ids = find(colnorms_squared_new(training_feats(:,col_ids)) > 1e-6);   % ensure no zero data elements are chosen
    dataPart = training_feats(:,data_ids);
    classLabel = training_labels(col_ids(1)); 
    Dpart = LCKSVDparam.Dinit(:,LCKSVDparam.dictLabels == classLabel );
    Dpart(isnan(Dpart(:))) =  0; 

    % Set KSVD parameters
    KSVDparam.InitializationMethod = 'GivenMatrix' ;       % Use data elements as dictionary
    KSVDparam.initialDictionary = Dpart ;
    KSVDparam.K =  size(Dpart ,2) ;               % dictionary size
    KSVDparam.L = ceil(0.1* KSVDparam.K);           % number of coefficients
    KSVDparam.preserveDCAtom = 0 ;
    KSVDparam.numIteration = LCKSVDparam.numIteration ;
    KSVDparam.displayProgress = 1 ;
    
    % Start train dictionary
    [Dictionary,output] = KSVD(dataPart,KSVDparam);
    
    %Gather Dpart to get final init Dictionary
    Dinit = [Dinit Dpart];
        
    labelvector = zeros(numClass,1);
    labelvector(classid) = 1;
    dictLabelMat = [dictLabelMat repmat(labelvector,1, KSVDparam.K)];
end
dictsize = size(Dinit,2);

% Q (label-constraints code); T: scale factor
T = eye(dictsize,dictsize); % scale factor
Q = zeros(dictsize,size(training_feats,2)); % energy matrix
for frameid=1:size(training_feats,2)
    label_training = H_train(:,frameid);
    [maxv1,maxid1] = max(label_training);
    for itemid=1:size(Dinit,2)
        label_item = dictLabelMat(:,itemid);
        [maxv2,maxid2] = max(label_item);
        if(maxid1==maxid2)
            Q(itemid,frameid) = 5*spatial_temporal_similarity(itemid, frameid,...
                                LCKSVDparam, training_states , training_fr);
        else
            Q(itemid,frameid) = 0;
        end
    end
end

% Set KSVD parameters
KSVDparam.InitializationMethod = 'GivenMatrix' ;       % Use data elements as dictionary
Dinit(isnan(Dinit(:))) =  0; 

KSVDparam.initialDictionary = Dinit ;
KSVDparam.K =  size(Dinit ,2) ;               % dictionary size
KSVDparam.L = ceil(0.1* KSVDparam.K);           % number of coefficients
KSVDparam.preserveDCAtom = 0 ;
KSVDparam.numIteration = LCKSVDparam.numIteration ;
KSVDparam.displayProgress = 1 ;

% ksvd process
[Dinit,output] = KSVD(training_feats,KSVDparam);

Xtemp = output.CoefMatrix ;
% learning linear classifier parameters
Winit = inv(Xtemp*Xtemp'+eye(size(Xtemp*Xtemp')))*Xtemp*H_train';
Winit = Winit';

Tinit = inv(Xtemp*Xtemp'+eye(size(Xtemp*Xtemp')))*Xtemp*Q';
Tinit = Tinit';
end 

function [score] = spatial_temporal_similarity(atomId, dataId, LCKSVDparam, training_states , training_fr)
    spatialVar = 30 ;
    temporalDiff = abs(training_fr(dataId) - LCKSVDparam.D_fr(atomId)); 
    spatialDiff = sqrt((training_states(1,dataId) - LCKSVDparam.D_states(1,atomId))^2 + ...
                       (training_states(2,dataId) - LCKSVDparam.D_states(2,atomId))^2);
    score = exp(-temporalDiff*spatialDiff/spatialVar) ; 
end 