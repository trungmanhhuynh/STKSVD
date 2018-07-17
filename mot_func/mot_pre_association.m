function [Y] = mot_pre_association(detections,Y,start_frame,end_frame)

%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.

cur_det = detections(start_frame);
for i=1:length(cur_det.x)
    Y(start_frame).child{i} = 0;
end


for q=start_frame+1:end_frame
    prev_det = detections(q-1);
    cur_det = detections(q);
    asso_idx = [];
    for i=1:length(cur_det.x)
        ovs1 = calc_overlap2(cur_det,prev_det,i);
        [ovs1_max,ovs1_idx] = max(ovs1);
        ovs1(:) = 0 ; 
        ovs1(ovs1_idx) = ovs1_max ;
        inds1 = find(ovs1 > 0.3);
        ratio1 = cur_det.h(i)./prev_det.h(inds1);
        inds2 = (min(ratio1, 1./ratio1) > 0.5); 
        if ~isempty(inds1(inds2))
            Y(q).child{i} = inds1(inds2);  
        else
            Y(q).child{i} = 0;
        end
        asso_idx = [asso_idx,inds1(inds2)]; 
    end
    Y(q-1).iso_idx(asso_idx) = 0;
    
end

end