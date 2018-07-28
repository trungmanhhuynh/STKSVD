function [score_mat] = mot_eval_association_matrix(stage,trackId, Refer,Test,param,type,KSVDparam,LCKSVDparam,withMotion)

test_feats = [] ;
D = [ ]; W= [] ;

score_mat =zeros(length(Refer),length(Test));

if(param.use_KSVD && KSVDparam.n_update ~= 0)
    %% Classify using KSVD
    
    %create test data
    for tid = 1:length(Test)
        test_feats = [test_feats, Test(tid).hist];
    end
    
    if ~isempty(test_feats)
        
        subD = [] ;  subW = [] ; chosenAtomIdx =[] ;subD_labels = [] ;
        for i = 1: length(trackId)
            label = Refer(i).label ;
            Dpart =  KSVDparam.D(:,KSVDparam.dict_labels == label);
            subD = [subD Dpart] ;
            subD_labels = [subD_labels KSVDparam.dict_labels(KSVDparam.dict_labels  == label)];
        end
        
        sparsitythres = ceil(0.1*size(subD,2));
        
        A = OMP(subD,test_feats, sparsitythres);
        A = abs(full(A));           %convert to dense matrix
        
        appSim_mat = zeros(length(trackId),size(test_feats,2));
        for i = 1: size(test_feats,2)
            for j = 1: length(trackId)
                classIdx = find(subD_labels == Refer(j).label) ;
                appSim_mat(j,i) = max(A(classIdx,i)); 
            end
        end

        
    end
    
elseif (param.use_LCKSVD && LCKSVDparam.n_update ~= 0)
    %% Classify usiing LCKSVD
    %create test data
    
    for tid = 1:length(Test)
        test_feats = [test_feats, Test(tid).hist];
    end
    %run omp to find sparse code on test data
    %set up omp parameters
    if ~isempty(test_feats)
        
        %get results in local stages
        if(stage == 1)
            sparsitythres = ceil(0.1*size(LCKSVDparam.D2,2));
            A = OMP(LCKSVDparam.D2,test_feats,sparsitythres );
            A =  LCKSVDparam.W2* A ;
            A = A(trackId,:);
            appSim_mat = abs(full(A));           %convert to dense matrix
        else
            %get results in global stage
            % Get dictionary of each class
            subD = [] ;  subW = [] ; chosenAtomIdx =[] ; subD_labels = [] ;
            for i = 1: length(trackId)
                label = Refer(i).label ;
                Dpart =  LCKSVDparam.D2(:,LCKSVDparam.dictLabels == label);
                subD = [subD Dpart] ;
                subD_labels = [subD_labels LCKSVDparam.dictLabels(LCKSVDparam.dictLabels == label)];
            end
            
            sparsitythres = ceil(0.1*size(subD,2));
            
            A = OMP(subD,test_feats, sparsitythres);
            A = abs(full(A));           %convert to dense matrix
            
            appSim_mat = zeros(length(trackId),size(test_feats,2));
            residual_mat = zeros(length(trackId),size(test_feats,2)) ;
            for i = 1: size(test_feats,2)
                for j = 1: length(trackId)
                    classIdx = find(subD_labels == Refer(j).label) ;
                    sparsecode = A(:,i) ;
                    sparsecode(~classIdx) = 0 ;
                    residual = norm(test_feats(:,i) - subD*sparsecode) ;
                    residual_mat(j,i) = abs(residual) ;
                end
            end
            appSim_mat = 1./residual_mat ;
        end
    else
        return ;
    end
    
end





for i=1:length(Refer)
    
    refer_hist = Refer(i).hist(:)/sum(Refer(i).hist(:));
    refer_h = Refer(i).h;
    refer_w = Refer(i).w;
    
    
    for j=1:length(Test)
        
        % Appearance affinity
        test_hist = Test(j).hist(:)/sum(Test(j).hist(:));
        
        if(param.use_KSVD && KSVDparam.n_update ~= 0)
            ReferIdx = find(KSVDparam.dict_labels == i);
            app_sim = 0.90 ; %max(appSim_mat(ReferIdx,j),2);
        elseif param.use_LCKSVD && LCKSVDparam.n_update ~= 0
            app_sim = 1.5*appSim_mat(i,j);
        else
            app_sim = mot_color_similarity(refer_hist,test_hist);
        end
        % Motion affinity
        [mot_sim] =  mot_motion_similarity(Refer(i), Test(j), param, type);
        
        
        % Shape affinity
        test_h = Test(j).h;
        test_w = Test(j).w;
        shp_sim = mot_shape_similarity(refer_h, refer_w, test_h, test_w);
        if(withMotion)
            score_mat(i,j) = mot_sim*app_sim*shp_sim;
        else
            ReferPos = [Refer(i).FMotion.X(1); Refer(i).FMotion.X(3)] ;
            if (strcmp(type,'Trk') == 1)
                TestPos = [Refer(i).FMotion.X(1); Refer(i).FMotion.X(3)] ;
            else
                TestPos = Test.pos ;
            end
            if(norm(ReferPos - TestPos) < 30)
                score_mat(i,j) = app_sim*shp_sim;
            else
                score_mat(i,j)  = 0 ;
            end
            
        end
        
    end
end
end

