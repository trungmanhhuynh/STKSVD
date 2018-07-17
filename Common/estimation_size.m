function [size_state] = estimation_size(Trk,ystate,fr)

%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.

init_time = Trk.ifr;
nof_s = 4;
count = 0 ;

sum_size = Trk.state{end}(3:4);
if fr == Trk.last_update && Trk.Conf_prob > 0.6
    size_state = ystate(3:4);
else
    if fr > init_time + nof_s 
        for j=1:nof_s
            if(Trk.Conf_Mat(j) > 0.6)
                sum_size = sum_size + Trk.state{end-j}(3:4);
                count = count + 1;
            end
        end
        size_state = sum_size/(count+1);
    else
        all_est = cell2mat(Trk.state);
        
        sum_size = sum_size + sum(all_est(3:4,:),2);
        size_state = sum_size/ (size(all_est,2)+1);
    end
end

end




