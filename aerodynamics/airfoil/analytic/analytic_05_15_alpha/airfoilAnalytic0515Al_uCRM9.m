function [fclv, fcdv, fcmv, grid, info] = airfoilAnalytic0515Al_uCRM9(af_filename, b_visualize)


% This test loads airfoil data, performs an analytic fit and visualizes the
% results.
% After that, an analytic approximation of the different fits for multiple
% Mach numbers is performed using a shallow neural network (with NeuN).

% Disclaimer:
%   SPDX-License-Identifier: GPL-3.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

% *************************************************************************
% Modified from airfoilAnalytic0515Al_example to fit uCRM9 airfoil data
% Davide Cavaliere, July 2025
% - Flap deflection fit is poor and has been removed; in any case it is not
%   normally used. 
% 
% *************************************************************************


%% test actuator state

% af_filename = 'uCRM9_wr_40';

af_tmp = wingAirfoilMapSetSim(wingAirfoilMapLoadSection(af_filename));

map_cl = getScellArrAt( af_tmp.map_cl, 1 );
map_cd = getScellArrAt( af_tmp.map_cd, 1 );
map_cm = getScellArrAt( af_tmp.map_cm, 1 );

fclv = zeros(6,length(af_tmp.Mach.data));
fcdv = zeros(6,length(af_tmp.Mach.data));
fcmv = zeros(5,length(af_tmp.Mach.data));
% fdclv = zeros(3,length(af_tmp.Mach.data));
% fdcdv = zeros(3,length(af_tmp.Mach.data));
% fdcmv = zeros(3,length(af_tmp.Mach.data));
i_Rey = 5;
i_act = 5; % 0° flap deflection
for i = 1:length(af_tmp.Mach.data)
    [fclv(:,i),fcdv(:,i),fcmv(:,i), info] = airfoilAnalytic0515AlFit( af_tmp.alpha.data, af_tmp.Mach.data(i), reshape(map_cl(:,i,i_Rey,i_act,1),1,[]), reshape(map_cd(:,i,i_Rey,i_act,1),1,[]), reshape(map_cm(:,i,i_Rey,i_act,1),1,[]), b_visualize );
    sgtitle(['M', num2str(af_tmp.Mach.data(i)), ' | Re', num2str(af_tmp.Reynolds.data(i_Rey)), ' | ', af_filename]);
end

%% Prepare accompanying data
grid = struct;
grid.ScheduledVariableOrder = {'Mach'}; %Also reynolds, later?
grid.ScheduledVariables.Mach = af_tmp.Mach.data;
grid.ConstantVariables.Reynolds_s = af_tmp.Reynolds.data(i_Rey);
grid.ConstantVariables.Actuator = af_tmp.actuator_1.data(i_act);
grid.AlphaLimits = [-6, 16]; 

%%

% for i = 1:length(af_tmp.Mach.data)
%     [fdclv(:,i),fdcdv(:,i),fdcmv(:,i)] = airfoilAnalytic0515DeFit( af_tmp.alpha.data, af_tmp.actuator_1.data, reshape(map_cl(:,i,i_Rey,:,1)-map_cl(:,i,i_Rey,5,1),1,[]), reshape(map_cd(:,i,i_Rey,:,1)-map_cd(:,i,i_Rey,5,1),1,[]), reshape(map_cm(:,i,i_Rey,:,1)-map_cm(:,i,i_Rey,5,1),1,[]), 1 );
% end

%%
% Mach is already regularly spaced, no need to re-interpolate
% Maq = af_tmp.Mach.data;
% fclvq = interp1( af_tmp.Mach.data', fclv', Maq', 'pchip' )';
% fcdvq = interp1( af_tmp.Mach.data', fcdv', Maq', 'pchip' )';
% fcmvq = interp1( af_tmp.Mach.data', fcmv', Maq', 'pchip' )';
% fdclvq = interp1( af_tmp.Mach.data', fdclv', Maq', 'pchip' )';
% fdcdvq = interp1( af_tmp.Mach.data', fdcdv', Maq', 'pchip' )';
% fdcmvq = interp1( af_tmp.Mach.data', fdcmv', Maq', 'pchip' )';

% fclmax = max(abs(fclvq),[],2);
% fcdmax = max(abs(fcdvq),[],2);
% fcmmax = max(abs(fcmvq),[],2);
% fdclmax = max(abs(fdclvq),[],2);
% fdcdmax = max(abs(fdcdvq),[],2);
% fdcmmax = max(abs(fdcmvq),[],2);

