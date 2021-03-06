function [Trk] = MOT_Confidence_Update(Trk,param,fr,lambda)

if nargin < 4
    lambda = 1.2;
end
%% Tracklet confidence update

for i=1:length(Trk)
    if Trk(i).last_update == fr
        hyp_score = Trk(i).hyp.score;
        
        L_T = 0;
        ass_idx = [];
        for ii = length(hyp_score):-1:1
            %if hyp_score(ii) == 0
            if ii ==  Trk(i).ifr
                break;
            end
            L_T = L_T + 1;
            ass_idx = [ass_idx,ii];
        end
        
        Conf_prob = 1/(L_T) * sum(hyp_score(ass_idx)) * (1 - exp(-lambda*sqrt(L_T)));
        Trk(i).Conf_prob = Conf_prob;
        Trk(i).Conf_Mat(fr) = Conf_prob ;
        Trk(i).Cont_Asso = L_T;
        
    else
        Conf_prob = Trk(i).Conf_prob;
        Trk(i).Conf_prob = Conf_prob*param.atten;
        Trk(i).Conf_Mat(fr) = Conf_prob ;

    end
end


end



