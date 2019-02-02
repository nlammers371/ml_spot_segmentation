function [xyzMat, spotInfo] = simulate_MS2_data(nParticles,tVec,...
    varargin)

    % set default subfunction calls
    particle_fun = 'simulate_particle_positions(nParticles,tVec';
    trace_fun = 'simulate_particle_traces(tVec';
    
    for i=1:length(varargin)        
        if isstring(varargin{i})
            % check particle sim arguments first
            if ismember(varargin{i},{'xyzRes', 'nbSize', 'xySpeed', 'zSpeed','dimVec'})       
                particle_fun = [particle_fun ',' varargin{i} '=' num2str(varargin{i+1})];           
            elseif ismember(varargin{i},{'K', 'w', 'R', 'r_emission','noise','pi0'})       
                trace_fun = [trace_fun ',' varargin{i} '=' num2str(varargin{i+1})]; 
            end
        end      
    end
    % Cap function calls
    particle_fun = [particle_fun ');'];
    trace_fun = [trace_fun ');'];
    % call particle position simulation function
    eval(['xyzMat = ' particle_fun])
    % call stochastic trace simulation function
    spotInfo = struct;
    for i = 1:nParticles
        eval(['gillespie = ' trace_fun])
        fnames = fieldnames(gillespie);
        for j = 1:numel(fnames)
            spotInfo(i).(fnames{j}) = gillespie.(fnames{j});
        end
    end