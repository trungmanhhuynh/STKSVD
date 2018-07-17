function [detections] = mot_generate_pseudo_detections(Trk, detections, Obs_grap, param, fr, rgbimg)
%% Copyright (C) 2017 Huynh Manh
%% All rights reserved.
%% Desciption
%  This function generates pseudo detections for each tracklets
%  in active tracking state with both high and low confident level
%
%%

figure(1) ;
imshow(rgbimg);
hold on ;

tidx = Idx2Types(Trk,'High');
  
for ii = 1:length(tidx)
    
    tid = tidx(ii);
    % get motion state of each target
    X = Trk(tid).FMotion.X(:,end);
    
    % plot velocity vector on image
    quiver(X(1),X(3),5*X(2),5*X(4),'Color','r');   % scale = 5 for display
    
    %create searching area as a circle segment
    expandangle = pi/4 ;                        % angle between velocity vector and the outline
    radius = 30   ;                             % radius of searching area
    angleInRad = mod(atan2(X(4),X(2)),2*pi) ;
    vel_threshold = 2;
    if(norm([X(2),X(4)]) >= vel_threshold)
        [xarc,yarc] = generate_arc(angleInRad+expandangle,angleInRad-expandangle,X(1),X(3),radius);
    else
        expandangle = pi ;
        [xarc,yarc] = generate_arc(angleInRad+expandangle,angleInRad-expandangle,X(1),X(3),radius);
        
    end
    
    
    % find random points (gaussian distribution) inside searching area
    xq = radius*randn(250,1) + X(1);            % generate random points
    yq = radius*randn(250,1) + X(3);            % arround target's location and
    % variance = radius
    [in,on] = inpolygon(xq,yq,xarc,yarc);
    
    P = fill(xarc,yarc,'r');
    plot(xq(in),yq(in),'b+') % points inside
    
    % get all states (x,y,w,h) of location candidates
    % all these locations have same size
    numIn = numel(xq(in)) ;
    w = Trk(tid).state{end}(3);
    h = Trk(tid).state{end}(4);
    states = [ xq(in)' ; yq(in)' ; repmat(w,1,numIn) ; repmat(h,1,numIn)] ;
    
    %get histogram for each pseudo-detection
    [tmpl_hist] = mot_appearance_model_generation(rgbimg, param, states);
    
    % find color similarity between each pseudo-detection and track
    refer_hist = Trk(tid).A_Model ;
    refer_hist = refer_hist(:)/sum(refer_hist);
    scores = [] ;
    for i = 1:size(states,2)
        test_hist = tmpl_hist(:,:,i);
        test_hist = test_hist(:)/sum(test_hist);
        thisScore = mot_color_similarity(refer_hist,test_hist);
        scores = [scores thisScore] ;
    end
    
    % find pseudo-detections that has the best color similarity
    [maxVal,maxInd] = max(scores);
    
    % display pseudo-detections
%     rectcolor = jet(16)*255;
%     thisState = states(:,maxInd);
%     Roi = int32([thisState(1) - thisState(3)/2, thisState(2) - thisState(4)/2,thisState(3),thisState(4)]);
%     shapeInserter = vision.ShapeInserter('BorderColor','Custom',...
%         'CustomBorderColor', rectcolor(1,:),'LineWidth',5);
%     bg_image = shapeInserter(rgbimg, Roi);
%     figure, imshow(bg_image);
%     
    
    %add this pseudo-detection to the list
    detections(fr).x = [detections(fr).x ;states(1,maxInd)];
    detections(fr).y = [detections(fr).y ;states(2,maxInd)];
    detections(fr).w = [detections(fr).w ;states(3,maxInd)];
    detections(fr).h = [detections(fr).h ;states(4,maxInd)];
end

end


function [xarc,yarc] = generate_arc(a,b,h,k,r)
% Plot a circular arc as a pie wedge.
% a is start of arc in radians,
% b is end of arc in radians,
% (h,k) is the center of the circle.
% r is the radius.
% Try this:   plot_arc(pi/4,3*pi/4,9,-4,3)
% Author:  Matt Fig
t = linspace(a,b);
x = r*cos(t) + h;
y = r*sin(t) + k;
xarc = [x h x(1)];
yarc = [y k y(1)];


end