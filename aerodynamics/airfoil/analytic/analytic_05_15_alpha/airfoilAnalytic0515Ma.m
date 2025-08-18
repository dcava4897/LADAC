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
    
    fun_type = 'neun';
else
    airfoil_anl = varargin{1};
    Ma = varargin{2};
    coeff_type = varargin{3};
    
    weights = []; % Must be defined regardless
    
    fun_type = airfoil_anl.type;
    
    % TODO: add a check on whether scheduling variable is indeed Mach (or
    % generalize script to any scheduling variable(s) and check that user has
    % specified it correctly)
end
    
num_inputs = length(Ma);
Ma = Ma(:)';

switch fun_type 
    case 'neun'
        
        %Select correct coefficient type:
        if isempty(weights)
            switch coeff_type
                case 'cl'
                    weights = airfoil_anl.wcl;
                case 'cm'
                    weights = airfoil_anl.wcm;
                case 'cd'
                    weights = airfoil_anl.wcd;
            end
        end
        
        bias_in = ones(1,num_inputs);

        % forward propagation
        inputHiddenLayer = weights.weights1 * [Ma;bias_in];

        outputHiddenLayer = tanh( inputHiddenLayer );

        fMa = weights.weights2 * [ outputHiddenLayer; bias_in ];
    case 'interp'
        % Note: The method of interpolating below (griddedInterpolants in
        % cell arrays, evaluated one at a time) has been tested to work
        % faster than either interp1 or a cellfun implementation.
        % From R2021a onwards, griddedInterpolant can handle values with +1
        % dimension, e.g. 2-D matrices interpolated over a 1-D grid (like
        % interp1). Future work could take advantage of this.
        
        switch coeff_type
            case 'cl'
                field_name = 'Fclv';
            case 'cm'
                field_name = 'Fcmv';
            case 'cd'
                field_name = 'Fcdv';
        end
        
        fMa = zeros(numel(airfoil_anl.(field_name),num_inputs));
        for i_fun = 1:numel(airfoil.anl.(field_name))
            fMa(i_fun) = aifoil.anl.(field_name){i_fun}(Ma);
        end
        
        
end
end