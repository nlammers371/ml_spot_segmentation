function [rangeCell, filterCell] = find_ranges(dimVec,pVec,kDim)
    
    fullY = pVec(1)-kDim:pVec(1)+kDim;
    fullX = pVec(2)-kDim:pVec(2)+kDim;
    fullZ = pVec(3)-kDim:pVec(3)+kDim;    
    
    rangeCell{1} = (max(1,pVec(1)-kDim):min(dimVec(1),pVec(1)+kDim));
    rangeCell{2} = (max(1,pVec(2)-kDim):min(dimVec(2),pVec(2)+kDim));
    rangeCell{3} = (max(1,pVec(3)-kDim):min(dimVec(3),pVec(3)+kDim));
    
    filterCell{1} = fliplr(ismember(fullY,rangeCell{1}));
    filterCell{2} = fliplr(ismember(fullX,rangeCell{2}));
    filterCell{3} = fliplr(ismember(fullZ,rangeCell{3}));