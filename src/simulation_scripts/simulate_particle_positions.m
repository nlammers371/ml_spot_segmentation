%function [frameInfo, xyzMat] = simulate_particle_positions(dimVec,xySpeed,zSpeed,nbSize,nParticles,tVec,xyzRes)
    
% Generates a vectors of simulated positions for transcriptional loci over
% a specified period of time within a specified imaging volume. For
% simplicity, trajectories are treated as random walks and boundaries are
% treated as reflecting
%
% 
% INPUTS
% dimVec: 1x3 Integer vector containing dimensions (in microns) of imaging
% volume (y,x,z)
% xySpeed: Numeric scalar  specifying characteristic rate of drifting (um/s)
% zSpeed: Numeric Scalar. Analagous variable in Z dimension
% nbSize: Numeric scalar. Sets neighborhood size of particles. Mimics
% reality that particles are situated within nuclei and this cannot overlap
% completely
% nParticles: Integer scalar. Number of particles to simulate
% tVec: Fx1 numeric vector of times. Where F is the number of frames to
% simulate. 
% xyzRes: Nuemeric scalar. Specifies resolution (in meters) to use for
% siumlation
%
% RETURNS
% xyzMat: nParticlesx3xF numeric array containing simulated positions of each particle
% over time
% frameInfo: Structure containing key attributes of simulated data

function [frameInfo, xyzMat] = simulate_particle_positions(nParticles,tVec,varargin)

    close all
    
    % set defaults 
    xyzRes = .2e-6;
    nbSize = 2e-6;
    xySpeed = .05e-6;
    zSpeed = .01e-6;
    dimVec = [100 100 10]*1e-6;
    for i=1:length(varargin)  
        if isstring(varargin{i})
            if ismember(varargin{i},{'xyzRes', 'nbSize', 'xySpeed', 'zSpeed','dimVec'})       
                eval([varargin{i} '=varargin{i+1}']);
            end
        end
    end
    % recored attributes
    frameInfo.xyzRes = xyzRes;
    frameInfo.nbSize = nbSize;
    frameInfo.xySpeed = xySpeed;
    frameInfo.zSpeed = zSpeed;
    frameInfo.dimVec = dimVec;
    frameInfo.tVec = tVec;
    
    % calculate basic simulation parameters
    tRes = tVec(2) - tVec(1); % seconds
    xyStep = xySpeed * tRes / xyzRes;
    zStep = zSpeed * tRes / xyzRes;
    xyzNPixels = round(dimVec / xyzRes) + 1;    
    nbPix = ceil(nbSize / xyzRes);
    
    % initialize position array 
    xyzMat = NaN(nParticles,3,numel(tVec));
    
    % draw initial particle positions
    yOptions = nbPix:nbPix:xyzNPixels(1);
    xOptions = nbPix:nbPix:xyzNPixels(2);
    zOptions = nbPix:nbPix:xyzNPixels(3);
    nOptions = numel(xOptions)*numel(yOptions)*numel(zOptions);
    % random samples with sapcing enforced
    indInit = randsample(1:nOptions,nParticles,false);
    [yPos, xPos, zPos] = ind2sub([numel(yOptions),numel(xOptions),numel(zOptions)],indInit);
    % record initial positions
    xyzMat(:,:,1) = [yPos', xPos', zPos']*nbPix;
    
    % now step forward in time
    pIndex = 1:nParticles;
    for t = 2:numel(tVec)
        % assign particle positions in ranomized order
        pOrder = randsample(pIndex,nParticles,false);
        for p = 1:nParticles
            posCurrent = xyzMat(pOrder(p),:,t-1);
            accepted = 0;
            while ~accepted
                % draw new position
                proposal = mvnrnd(posCurrent,[xyStep xyStep, zStep]);
                % check distance from other particles    
                distVec = Inf;
                if p > 1
                    distVec = sqrt(sum((xyzMat(pOrder(1:p-1),:,t)-proposal).^2,2));
                end
                proposal = round(proposal);
                accepted = all(distVec>nbPix)&all(proposal>1)&all(proposal<xyzNPixels);
            end
            xyzMat(pOrder(p),:,t) = proposal;
        end     
    end