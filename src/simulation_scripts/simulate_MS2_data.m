function [xyzMat, spotInfo, frameInfo] = simulate_MS2_data(project,nParticles,tVec,varargin)
    tic
    % set default subfunction calls
    particle_fun = 'simulate_particle_positions(nParticles,tVec';
    trace_fun = 'simulate_particle_traces(tVec';
    attribute_fun = 'generate_particle_attributes(frameInfo';
    tiff_fun = 'generate_tiff_stacks(frameInfo,spotInfo';
    
    for i=1:length(varargin)        
        if isstring(varargin{i})
            % check particle sim arguments first
            if ismember(varargin{i},{'xyzRes', 'nbSize', 'xySpeed', 'zSpeed','dimVec'})       
                particle_fun = [particle_fun ',' varargin{i} '=' num2str(varargin{i+1})];           
            elseif ismember(varargin{i},{'K', 'w', 'R', 'r_emission','noise','pi0'})       
                trace_fun = [trace_fun ',' varargin{i} '=' num2str(varargin{i+1})]; 
            elseif ismember(varargin{i},{'na', 'refractionIndex', 'lambdaExcitation'})       
                trace_fun = [trace_fun ',' varargin{i} '=' num2str(varargin{i+1})]; 
            elseif ismember(varargin{i},{'nSlices','SNR','noiseSigma'})       
                trace_fun = [trace_fun ',' varargin{i} '=' num2str(varargin{i+1})]; 
            end
        end      
    end
    % Cap function calls
    particle_fun = [particle_fun ');'];
    trace_fun = [trace_fun ');'];
    attribute_fun = [attribute_fun ');'];
    tiff_fun = [tiff_fun ');'];
    
    % call particle position simulation function
    eval(['[frameInfo, xyzMat] = ' particle_fun])
    
    % call stochastic trace simulation function
    spotInfo = struct;
    for i = 1:nParticles
        eval(['gillespie = ' trace_fun])
        fnames = fieldnames(gillespie);
        for j = 1:numel(fnames)
            spotInfo(i).(fnames{j}) = gillespie.(fnames{j});
        end
        spotInfo(i).xyzMat = reshape(xyzMat(i,:,:),3,numel(tVec))';
    end
    
    % call function to generate physical particle attributes
    eval(['frameInfo = ' attribute_fun])    
    
    % call function to generate tiff slices
    eval(['[tiffCell, frameInfo] = ' tiff_fun])
    
    % save data
    dataPath = ['../../dat/' project '/'];
    mkdir(dataPath)
    tiffPath = [dataPath 'tiffFiles/'];    
    mkdir(tiffPath)
    
    save([dataPath 'frameInfo.mat'],'frameInfo')
    save([dataPath 'spotInfo.mat'],'spotInfo')
    save([dataPath 'xyzMat.mat'],'xyzMat')
   
    for t = 1:numel(tVec)
        tiff = tiffCell{t};
        imwrite(tiff(:,:,1),[tiffPath 'sim_data_t' sprintf('%03d',t) '.tif']);
        for i = 2:size(tiff,3)
            imwrite(tiff(:,:,i),[tiffPath 'sim_data_t' sprintf('%03d',t) '.tif'],'WriteMode','append');
        end
    end
    toc