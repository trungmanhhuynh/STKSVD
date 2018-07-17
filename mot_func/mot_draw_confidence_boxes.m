function [bg_image] = mot_draw_confidence_boxes(bg_image, wind_lx,wind_ly,windw,windh,Labels,conf)
%% Copyright (C) 2014 Seung-Hwan Bae
%% All rights reserved.


rectcolor = jet(16)*255;
ncol = size(rectcolor,1);

    
%imshow(bg_image);
%clf, imagesc(bg_image); hold on
%set(gca,'Position',[0,0,1,1],'visible','off');
%hold on;


l_width = 5;
base_fonts = 15;
for i=1:length(wind_lx)
    Roi = [wind_lx(i), wind_ly(i), windw(i), windh(i)]; 
    lab = Labels(i);
    

    wsize = windw(i);
    if wsize < 25
        fonts = base_fonts-1;
    elseif (wsize >= 25) && (wsize < 30)
        fonts = base_fonts;
    elseif (wsize >= 30) && (wsize < 35)
        fonts = base_fonts +1;
    elseif (wsize >= 35) && (wsize < 40)
        fonts = base_fonts +2;
    elseif (wsize >= 40) && (wsize < 45)
        fonts = base_fonts + 3;
    elseif (wsize >= 45) && (wsize < 50)
        fonts = base_fonts + 4;
    else
        fonts = base_fonts + 7;
    end
    
   
   [txt_cx txt_cy] = LeftToCenter(wind_lx(i),  wind_ly(i), windh(i),  windw(i));
   txt_cy = txt_cy -12;
   nfonts = fonts + 3;
   
   
   
   cindx = min([ceil(conf(i)*ncol),16]);
   if cindx <= 0
       cindx = 1;
   end
   
   Roi = int32([wind_lx(i), wind_ly(i), windw(i), windh(i)]); 
   %text(wind_lx(i), wind_ly(i) ,sprintf('%d',lab),'Color','k','Fontsize',nfonts,...
    %   'HorizontalAlignment','Center','FontWeight','bold');
   shapeInserter = vision.ShapeInserter('BorderColor','Custom',...
'CustomBorderColor', rectcolor(cindx,:),'LineWidth',5);

   bg_image = shapeInserter(bg_image, Roi);
   bg_image = insertText(bg_image, [wind_lx(i), wind_ly(i)], lab);
   
   %

end


