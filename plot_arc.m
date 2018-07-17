function P = plot_arc(a,b,h,k,r)
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
x = [x h x(1)];
y = [y k y(1)];
P = fill(x,y,'r');
axis([h-r-1 h+r+1 k-r-1 k+r+1]) 
axis square;
if ~nargout
    clear P
end

rng default
xq = randn(250,1);
yq = randn(250,1);

[in,on] = inpolygon(xq,yq,x,y);

hold on
plot(xq(in),yq(in),'b+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside

quiver(h,k,1,1);
end 