function [prm] = wingSetParams(prm)
%setParams calculates further wing parameters 
%
% Inputs:
%    prm                    Struct which contains all wing parameters, in -
%                           (struct, see parameter files for wings)
%
% Outputs:
%    prm                  	Struct which contains all wing parameters, in -
%                           (struct)
%
% See also: wingLoadParameters

% Disclaimer:
%   SPDX-License-Identifier: GPL-3.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

% aircraft geometry constants
% wing area (scalar), in m^2
prm.S = trapz( prm.eta_segments_wing*prm.b./[1,cos(prm.nu)], prm.c );  
% aspect ratio, in -
prm.AR = prm.b^2 / prm.S;
% taper ratio (total wing), in -
prm.tau = prm.c(end) / prm.c(1);   

% number of actuators, in - 
prm.num_actuators = sum( unique(prm.control_input_index) ~= 0 );

% y-coordinates of wing parts, in m
if prm.is_symmetrical
    prm.y_segments_wing = prm.eta_segments_wing * prm.b/2;
else
    prm.y_segments_wing = prm.eta_segments_wing * prm.b;
end

% Compute the section_type for each section. The first entry of this array
% is 0, the next one is 0 if it uses the same profile name (section) or +1
% if it is different... and so on.
num_section = length(prm.section(:,1));
prm.section_type = zeros(1,num_section);
% for i = 2:num_section
%     for j = 1:i-1
%         if all( prm.section(i,:) == prm.section(j,:) )
%             prm.section_type(i) = prm.section_type(j);
%             break;
%         elseif j == i-1
%             prm.section_type(i) = prm.section_type(i-1) + 1;
%         end
%     end
% end

% Modification DC 8/2025: Not clear what the intent here was, but I assume
% section_type should be an index pointing to the relevant airfoil; the
% method above assumes they are always in order, regardless of name. 
% Instead, we can use unique, and subtract 1 to keep the same convention:
[~,~, section_type_tmp] = unique(prm.section, 'rows');
prm.section_type = section_type_tmp' - 1;


end
