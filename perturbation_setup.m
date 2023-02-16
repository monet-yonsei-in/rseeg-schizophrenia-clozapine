% SETUP for CSD DCM perturbation example for resting-state EEG
%
% This scirpt setup for CSD DCM perturbation example for resting-state EEG.
% Contents of the setup code.
%   ------------------------  Mandatory Section   ------------------------
%   1. Check pathdef.m permission
%   2. Mandatory path check & addpath
%   ----------------------------------------------------------------------
%   $ FEB 2023, Jinseok Eo , urjinseok@gmail.com
%   ______________________________________________________________________

setupPath     = fileparts(mfilename('fullpath'));
[~,setFolder] = fileparts(setupPath);

%   Check pathdef.m permission
err = savepath;
if  err
    warning(['savepath() failed. ' ...
             'Setup will continue but chages will not be saved.']);
end

%   Check path already added
isWin   = (~isempty(contains(computer, 'PCWIN')) || ...
           strcmp(computer, 'i686-pc-mingw32'));
isOSX   = (~isempty(contains(computer, 'MAC'))   || ... 
           ~isempty(contains(computer, 'apple-darwin')));
isLinux = (strcmp(computer,'GLNX86') || strcmp(computer,'GLNXA64') ||...
           ~isempty(contains(computer, 'linux-gnu')));
       
if  isOSX || isLinux
    mpath = strsplit(path,':');
elseif isWin
    mpath = strsplit(path,';');
end
r = regexp(mpath, ['^.*' setFolder '.*$'],'match');
r = r(~cell2mat(cellfun(@isempty,r,'UniformOutput',false)));       
if  isempty(r)
    addpath(setupPath);
end

%   Mandatory path check
%    -SPM 12
%    -Repository

SPMpath = which('spm');
%   Check SPM path is in repository path 
%   Add SPM 12 path 
%   - If SPM path is not same, warning
if  isempty(SPMpath) 
    addpath(fullfile(setupPath,'external','spm12'));
end
MEEGpath = which('spm_csd_mtf');
if  isempty(MEEGpath)
    addpath(fullfile(setupPath,'external','spm12','toolbox','dcm_meeg'));
end
%   Add mandatory path 

%   Check Data 

disp('Setup ran successfully.');