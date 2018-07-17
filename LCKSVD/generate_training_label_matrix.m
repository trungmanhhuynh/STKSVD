function [H_train] = generate_training_label_matrix(label_train)

    numOfClass = max(label_train); 
    H_train = zeros(numOfClass,size(label_train,2));

    for classId = 1:numOfClass
        dataIdx = find(label_train == classId); 
        H_train(classId,dataIdx) = 1 ;
       
    end
    
end 