function [ detections ] = read_detection_file( data_path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

det_mat = csvread(data_path) ;

numOfFrame = max(det_mat(:,1));
detections = [] ;
for frameId = 1:numOfFrame
    idx = find(det_mat(:,1) == frameId); 
    thisFrame.x = round(det_mat(idx,3) + det_mat(idx,5)/2) ;
    thisFrame.y = round(det_mat(idx,4) + det_mat(idx,6)/2) ;
    thisFrame.w = det_mat(idx,5) ; 
    thisFrame.h = det_mat(idx,6) ;

    detections = [detections;thisFrame]; 
end

