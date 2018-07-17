function [tmpl_hist] = mot_appearance_model_generation(img, param, state)
% input :
% img: a color image
% state: [Center(X), Center(Y), Width, Height]
% output :
% tmpl_hist: color histograms

%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.

numberOfDetections = size(state,2);
imgWidth = size(img,2); 
imgHeight = size(img,1); 

if strcmp(param.color.type,'HSV')
    hsv_img = rgb2hsv(img);
else
    hsv_img = img;
end
h_img = double(hsv_img(:,:,1)) ;
s_img = double(hsv_img(:,:,2)) ;
v_img = double(hsv_img(:,:,3)) ;

tmpl_hist =[];

%create histogram of upper and lower part
%each detection
for j=1:numberOfDetections       
    
    xc = round(state(1,j)) ;
    yc = round(state(2,j));
    w = round(state(3,j));
    h = round(state(4,j))    ;
    xl = max([xc - round(w/2), 1]) ;
    yl = max([yc - round(h/2), 1]) ;

    
    %get bounding box for upper part and lower part
    upperpart = hsv_img(yl:yl + round(h/2) , xl:min([xl+w , imgWidth]),:);
    lowerpart = hsv_img(yl + round(h/2):min([yl + h, imgHeight]),xl:min([xl+w, imgWidth]),:);
    
    lowerhist = [] ;
    upperhist = [] ;
    for channelId = 1:3       
        lowerhist_c= imhist(lowerpart(:,:,channelId),param.Bin);
        upperhist_c= imhist(upperpart(:,:,channelId),param.Bin);
        lowerhist = [lowerhist ;lowerhist_c] ;
        upperhist = [upperhist ; upperhist_c] ;
    end
    %get final histogram feature for a detection 
    tmpl_hist(:,:,j) =  [lowerhist ; upperhist] ;
    
    %normalize hist to range[0;1]
    tmpl_hist(:,:,j) = tmpl_hist(:,:,j)./(max(tmpl_hist(:,:,j)));
end

end

