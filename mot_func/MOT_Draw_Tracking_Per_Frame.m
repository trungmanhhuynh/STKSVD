function [result] = MOT_Draw_Tracking_Per_Frame(Trk_sets, out_path, img_path, img_List, option)


% Draw Tracking Results
if ~isfield(option,'new_thr');
    option.isdraw = 1;
    option.iswrite = 1;
    option.new_thr = 5;
end
new_thr = option.new_thr;
all_mot = [];
result = [] ;
for q=length(Trk_sets)
    
    filename = strcat(img_path,img_List(q).name);
    rgbimg = imread(filename);
    
    wind_cx=[];  wind_cy =[]; windw = []; windh = [];
    Labels =[]; trk_idx = [];  trk_sts =[]; conf = [];
    
    
    if q<=new_thr
        trk_idx = Trk_sets(q).high;
        for i=1:length(trk_idx)
            states = Trk_sets(q).states{trk_idx(i)};
            lab = Trk_sets(q).label;
            trk_sts = zeros(1,length(trk_idx));
            if sum(states(:,q)) ~=0
                wind_cx = [wind_cx, states(1,q)];
                wind_cy = [wind_cy, states(2,q)];
                windw = [windw,states(3,q)];
                windh = [windh,states(4,q)];
                Labels = [Labels,lab(trk_idx(i))];
                conf(i)  = 0.33 + rand *0.33;
            end
        end
    else
        high = Trk_sets(q).high;
        low = Trk_sets(q).low;
        trk_idx = [high,low];
        
        for i=1:length(trk_idx)
            states = Trk_sets(q).states{trk_idx(i)};
            wind_cx = [wind_cx, states(1,end)];
            wind_cy = [wind_cy, states(2,end)];
            windw = [windw,states(3,end)];
            windh = [windh,states(4,end)];
            conf(i) = Trk_sets(q).conf(trk_idx(i));
        end
        if ~isempty(wind_cx)
            all_lab = Trk_sets(q).label;
            Labels = [all_lab(high), all_lab(low)];
        end
    end
    
    [wind_lx wind_ly] = CenterToLeft(wind_cx,wind_cy,windh,windw);
    
    
    %% Draw results
    if option.isdraw
        
        imageRes = mot_draw_confidence_boxes(rgbimg, wind_lx, wind_ly,windw,windh,Labels, conf);
        
        if ~exist(out_path);mkdir(out_path);end;
        
        out_filename = strcat(out_path,sprintf('Tracking_Results_%04d.jpg',q));
        
        if option.iswrite
            
            imwrite(imageRes, out_filename);
        end
    end
        
    %% Output
    if ~isempty(wind_cx)

        %write to result file txt
        for tId=1:size(Labels,2)
            result_q = [q Labels(tId) wind_lx(tId) wind_ly(tId) windw(tId) ...
                       windh(tId) conf(tId) -1 -1 -1 ];
             result = [result ;result_q ] ;
        end 
     
        
    end
    
end

end