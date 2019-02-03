%function frameInfo = generate_particle_attributes(frameInfo,varargin)
    
% Calculates (observable) physical attributes for set of particles given
% specified microscope optical characterstics. Using very simple approach
% that assumes all loci will be diffraction-limited and that ignores
% diffraction patterning and optical aberrations. 
%
% 
% INPUTS
% spotInfo: Structure containing particle characteristics
% OPTIONS
% na: Numeric scalar. Numerical Aperture (Default=1.4)
% refractionIndex: Numeric scalar: Index of refraction for imaging medium
% lambdaExcitation: NUmeric scalar: Excitation wavelength used to excite
% fluorophores
%
% RETURNS
% spotInfo: Augmented spotInfo structure

function frameInfo = generate_particle_attributes(frameInfo,varargin)

    close all
    % set defaults
    na = 1.4;
    lambdaExcitation = 488e-9;   
    refractionIndex = 1.51;
    
    for i=1:length(varargin)  
        if isstring(varargin{i})
            if ismember(varargin{i},{'na', 'refractionIndex', 'lambdaExcitation'})       
                eval([varargin{i} '=varargin{i+1}']);
            end
        end
    end
    % get resultion within focal plain
    rXY = .61 * lambdaExcitation / na;
    % axial direction
    rZ = 1.4 * lambdaExcitation * refractionIndex / na^2;
    
    % add info to spot structure
    for i = 1:numel(frameInfo)
        frameInfo(i).rXY = rXY;
        frameInfo(i).rZ = rZ;
        frameInfo(i).na = na;
        frameInfo(i).lambdaExcitation = lambdaExcitation;
        frameInfo(i).refractionIndex = refractionIndex;
    end
    
        