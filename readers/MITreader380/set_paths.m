%set_paths
s=cd;
base_path_CASANOSA= [s(1:(strfind(s,'CrIS_CALVAL'))-1),'CrIS_CALVAL_CASANOSA',filesep];
path(path,[base_path_CASANOSA,'Readers\CrIS'])
path(path,[base_path_CASANOSA,'Readers'])