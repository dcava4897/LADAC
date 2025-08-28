function fMa = airfoilAnalytic0515Ma( varargin )
% airfoilAnalytic0515Ma returns the coefficients for analytic functions in
% the airfoilAnalytic0515 project for different Mach number based on either 
% the weights of a shallow (one hidden layer) neural network or
% interpolation of matrices. 
%   The computation of the coefficients based on a neural network is
%   usually faster than interpolation of stored data.
%   The legacy input method (only for neural network inputs) has been
%   preserved for backward compatiblity.
% 
% fMa = airfoilAnalytic0515Ma( airfoil_anl, Ma, coeff_type )
% % Inputs:
%   airfoil_anl     struct containing all parameters for a given airfoil.
%                   Usually this struct is 
%                   elements are no weights but maximum input values used
%                   for normalization) (1x1 struct)
%   Ma              vector of Mach numbers (Mx1 or 1xM array)
%   coeff_type      char defining which analytic curve is desired; it is
%                   either 'cl', 'cd', or 'cm'
% 
% 
% Legacy mode: (NeuN only)
% fMa = airfoilAnalytic0515Ma( weights, Ma )
% Inputs:
%   weights         weights of the neural network (note that the first
%                   elements are no weights but maximum input values used
%                   for normalization) (1xN array)
%   Ma              vector of Mach numbers (Mx1 or 1xM array)
% 

% 
% Outputs:
%   fMa             concentrated coefficients of analytic function for all
%                   Mach numbers ((numOutputs)xM array)
% 
% See also: airfoilAnalytic0515NeunFit, airfoilAnalytic0515AlCl
% 

% Disclaimer:
%   SPDX-License-Identifier: GPL-3.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************
% Modified August 2025 by Davide Cavaliere
% Adds alternate inputs modes and compatibility with interpolated analytic
% function parameters, as well as edited description.
% *************************************************************************


if numel(varargin) == 2 %legacy input mode
    weights = varargin{1};
    Ma = varargin{2};
    coeff_type = '';
    
    fun_type = 'neurln';
else
    airfoil_anl = varargin{1};
    Ma = varargin{2};
    coeff_type = varargin{3};
    
%     weights = struct; % Must be defined regardless
    
    fun_type = airfoil_anl.type;
    
    % TODO: add a check on whether scheduling variable is indeed Mach (or
    % generalize script to any scheduling variable(s) and check that user has
    % specified it correctly)
end
    
num_inputs = length(Ma);
Ma = Ma(:)';

%for code gen, fMa must always be assigned
fMa = zeros(6,numel(Ma));

switch fun_type 
    case 'neurln'
        
        %Select correct coefficient type:
        if ~isempty(coeff_type) %If it is empty, we are assuming legacy input mode
            switch coeff_type
                case 'cl'
                    weights = airfoil_anl.wcl;
                case 'cm'
                    weights = airfoil_anl.wcm;
                case 'cd'
                    weights = airfoil_anl.wcd;
            end
        end
        
        idx_row_max = size(weights.weights2,1); %For codegen, fMa must have predetermined # of rows
        
        bias_in = ones(1,num_inputs);

        % forward propagation
        inputHiddenLayer = weights.weights1 * [Ma;bias_in];

        outputHiddenLayer = tanh( inputHiddenLayer );

        fMa(1:idx_row_max, :)  = weights.weights2 * [ outputHiddenLayer; bias_in ];
    case 'interp'
        
        %Note: griddedInterpolant not compatible with Simulink code
        %generation, removed for now. 
        % Note: The method of interpolating below (griddedInterpolants in
        % cell arrays, evaluated one at a time) has been tested to work
        % faster than either interp1 or a cellfun implementation.
        % From R2021a onwards, griddedInterpolant can handle values with +1
        % dimension, e.g. 2-D matrices interpolated over a 1-D grid (like
        % interp1). Future work could take advantage of this.
        
%         switch coeff_type
%             case 'cl'
%                 field_name = 'Fclv';
%             case 'cm'
%                 field_name = 'Fcmv';
%             case 'cd'
%                 field_name = 'Fcdv';
%         end
%         
%         fMa = zeros(numel(airfoil_anl.(field_name)),num_inputs);
%         for i_fun = 1:numel(airfoil_anl.(field_name))
%             fMa(i_fun,:) = airfoil_anl.(field_name){i_fun}(Ma);
%         end
%         
        % Normal interpolation
        switch coeff_type
            case 'cl'
                field_name = 'fclv';
            case 'cm'
                field_name = 'fcmv';
            case 'cd'
                field_name = 'fcdv';
        end
        
        idx_row_max = size(airfoil_anl.(field_name),1);
        
        %Quick fix: bound Ma to the avaailable grid manually, since interp1
        %cannot mix 'nearest' extrapolation with linear interpolation
        Ma = max(Ma, airfoil_anl.grid.Mach(1));
        Ma = min(Ma, airfoil_anl.grid.Mach(end));
        fMa(1:idx_row_max, :) = interp1( airfoil_anl.grid.Mach , airfoil_anl.(field_name)', Ma, 'linear', 'extrap');
           
%     otherwise %for code gen, fMa must always be assigned
%         fMa = zeros(6,numel(Ma));

end
end