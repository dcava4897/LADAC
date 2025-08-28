function airfoil = airfoilAnalytic0515LoadParams( filename )
% airfoilAnalytic0515LoadParams loads a parameter struct for an analytic
% airfoil computation.
% 
% Example:
%   airfoil = airfoilAnalytic0515LoadParams( 'airfoilAnalytic0515_params_F15' )

% Disclaimer:
%   SPDX-License-Identifier: GPL-3.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************
% Modified August 2025, Davide Cavaliere
% - Adds options for loading MAT files as well, and for accomodating
%   different types of parameters (neural networks, interpolated matrices,
%   etc.)
% *************************************************************************

[filepath,filename,file_ext] = fileparts(filename);

switch file_ext
    case '.m' % Run script to load parameters
        run( filename );
        
    case '.mat' % load MAT file to load parameters
        load( filename, 'airfoil' );
    otherwise % Extension not provided
        if ~isempty(which(filename)) % which returns empty for a MAT-file, but returns a path for a function
            run( filename );
        else
            load( filename, 'airfoil' );
        end
end

%

switch airfoil.type
    case 'neurln'
        airfoil.wcl = mergeOutputLayer( airfoil.wcl, airfoil.ncl, airfoil.ocl );
        airfoil.wcd = mergeOutputLayer( airfoil.wcd, airfoil.ncd, airfoil.ocd );
        airfoil.wcm = mergeOutputLayer( airfoil.wcm, airfoil.ncm, airfoil.ocm );
        
        % Add empty 'interp' fields to avoid 'Mixed field types' error
        airfoil.fclv = zeros(6,9);
        airfoil.fcdv = zeros(6,9);
        airfoil.fcmv = zeros(5,9);
        airfoil.grid = struct('Mach', zeros(1,9));
    case 'interp'
        %TODO: add ability to interpolate between 2 airfoils?
        
        % To improve interpolation speed (by up to 50%, in theory!), we
        % store the matrices as griddedInterpolant cell vectors. 
        % Note: removed for now because griddedInterpolant is not
        % compatible with code generation
%         for i_par = 1:size(airfoil.fclv,1)
%             airfoil.Fclv{i_par,1}  = griddedInterpolant(airfoil.grid.ScheduledVariables.Mach, airfoil.fclv(i_par,:),...
%                                 'linear', 'nearest');
%         end
%         for i_par = 1:size(airfoil.fcmv,1)
%             airfoil.Fcmv{i_par,1}  = griddedInterpolant(airfoil.grid.ScheduledVariables.Mach, airfoil.fcmv(i_par,:),...
%                                 'linear', 'nearest');
%         end
%         for i_par = 1:size(airfoil.fcdv,1)
%             airfoil.Fcdv{i_par,1}  = griddedInterpolant(airfoil.grid.ScheduledVariables.Mach, airfoil.fcdv(i_par,:),...
%                                 'linear', 'nearest');
%         end
        
%         airfoil = rmfield(airfoil, {'fclv', 'fcmv', 'fcdv'});

        % Add empty neural network fields to avoid mixed types error
        airfoilAnalytic0515_params_empty; %Should simple add 'empty' neun fields + change type to neun
        airfoil.type = 'interp';
        
        airfoil.wcl = mergeOutputLayer( airfoil.wcl, airfoil.ncl, airfoil.ocl );
        airfoil.wcd = mergeOutputLayer( airfoil.wcd, airfoil.ncd, airfoil.ocd );
        airfoil.wcm = mergeOutputLayer( airfoil.wcm, airfoil.ncm, airfoil.ocm );
        
        airfoil.grid = struct('Mach', airfoil.grid.ScheduledVariables.Mach);
end

%Temporary fix: Simulink not compatible with function handles, removed here
airfoil.info = rmfield(airfoil.info, {'liftCurve', 'momentCurve', 'dragCurve'});
airfoil = orderfields(airfoil);
end


function wcl = mergeOutputLayer( weights, numNeurons, numOutputs )

idx1 = numOutputs;
idx2 = idx1 + numNeurons*2;
weights1 = reshape( weights(idx1+1:idx2), [], 2 );
weights2 = diag( weights(1:idx1) ) * reshape( weights(idx2+1:end), [], numNeurons+1 );
wcl.weights1 = weights1;
wcl.weights2 = weights2;

end