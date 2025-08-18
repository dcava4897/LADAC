% Generates lift, drag, and moment curve parameter maps scheduled with Mach
% for CRM airfoils. 
% Note:
% - Only a single Reynolds number is considered, but in principle they
%   could also be scheduled with Reynolds
% - The moment curve fit is not excellent, especially at lower mach numbers
% - The actual AoA fit range is -6 to 16. A wider range is available, but the
%   functions do not easily fit. 

files_path = which(['airfoil', filesep, 'section_database', filesep, 'CRM', filesep, 'CRM9w000.mat']);
files_path = strrep(files_path, 'CRM9w000.mat','');

file_names = dir([files_path, 'CRM9*.mat']);

%% 
b_visualize = 0;

for i_file = 1:numel(file_names)
    [airfoil.fclv, airfoil.fcdv, airfoil.fcmv, airfoil.grid, airfoil.info] ...
        = airfoilAnalytic0515Al_uCRM9([strrep(file_names(i_file).name,'.mat', '')],...
                b_visualize);
%         = airfoilAnalytic0515Al_uCRM9([file_names(i_file).folder, filesep,file_names(i_file).name],...
%                 b_visualize);
    
    airfoil.type = 'interp';
    
    file_save = ['airfoilAnalytic0515_params_', file_names(i_file).name];
%     file_save = strrep(file_save, '.mat', '_params.mat');
    
    save(['CRM9', filesep, file_save], 'airfoil');
    
end