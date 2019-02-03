% tiffCell = generate_tiff_stacks(frameInfo,spotInfo,varargin)
    
% Generates a vectors of simulated positions for transcriptional loci over
% a specified period of time within a specified imaging volume. For
% simplicity, trajectories are treated as random walks and boundaries are
% treated as reflecting
%
% 
% INPUTS
% frameInfo: Data structure containing FOV attributes
% spotInfo: Data structure containing spot attributes (position, intensity,
% etc.)
% OPTIONS
% xyzResOut: Numeric vector (3x1) specifying experimental resolution to
% siimulate
% simulated TIFF stacks
% SNR: Numeric scalar. Sets level of background fluorescence relative to
% spot brightness
% noiseNoise: Numeric scalar. Standard deviation of bkg noise.
% RETURNS
% tiffCell: Cell array (1xF). Each element is 3D array containing all TIFFS for a
% single time point
function [tiffCell, frameInfo] = generate_tiff_stacks(frameInfo,spotInfo,varargin)

    close all
    
    % set defaults 
    xyzResOut = [.2 .2 .5] * 1e-6;
    SNR = .05;
    noiseNoise = .5;
    for i=1:length(varargin)  
        if isstring(varargin{i})
            if ismember(varargin{i},{'xyzResOut','SNR','noiseSigma'})       
                eval([varargin{i} '=varargin{i+1}']);
            end
        end
    end
    
    % recored attributes
    frameInfo.SNR = SNR;
    frameInfo.noiseSigma = noiseNoise;
    frameInfo.xyzResOut = xyzResOut;
    
    % extract params
    dimVec = frameInfo.dimVec;
    tVec = frameInfo.tVec;
    xyzResSim = frameInfo.xyzRes;
    rXY = frameInfo.rXY;
    rZ = frameInfo.rZ;
    % calculate number of pixels to simulate in each direction
    xyzNPixelsSim = round(dimVec ./ xyzResSim) + 1;   
    xyzNPixelsOut = round(dimVec ./ xyzResOut) + 1;    
    % calculate PSF
    inSigma = [rXY rXY rZ] ./ xyzResSim;
    psfKer = nonIsotropicGaussianPSF(inSigma);
    kDim = floor(size(psfKer,1)/2);
    % calculate bkg fluo level
    noiseMu = mean([spotInfo.fluo_MS2]) * SNR * max(psfKer(:));
    noiseSigma = noiseMu * noiseNoise;
    % for each time point, generate high-res volumes then downsample
    tiffCell = cell(1,numel(tVec));
    for t = 1:numel(tVec)
        % start with bkg noise
        fullFrame = normrnd(noiseMu,noiseSigma,xyzNPixelsSim(1),xyzNPixelsSim(2),xyzNPixelsSim(3));
        % iterate through spots and add to stack
        for i = 1:numel(spotInfo)
            fluo = spotInfo(i).fluo_MS2(t);
            position = spotInfo(i).xyzMat(t,:);    
            [rangeCell, filterCell] = find_ranges(xyzNPixelsSim,position,kDim);            
            fullFrame(rangeCell{1}, rangeCell{2}, rangeCell{3}) = ...
                fullFrame(rangeCell{1}, rangeCell{2}, rangeCell{3}) + ...
                fluo * psfKer(filterCell{1}, filterCell{2}, filterCell{3});
        end
        % now rescale
        fullFrameOut = imresize3(fullFrame,xyzNPixelsOut);
        tiffCell{t} = fullFrameOut;
    end