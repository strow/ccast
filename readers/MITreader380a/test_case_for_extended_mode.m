%set_paths
clear
clear global
s=cd;
base_path_CASANOSA= [s(1:(strfind(s,'CrIS_CALVAL'))-1),'CrIS_CALVAL_CASANOSA',filesep];
path(path,[base_path_CASANOSA,'Readers\CrIS'])
path(path,[base_path_CASANOSA,'Readers\CrIS\bit_unpack_C_files_all_types'])
path(path,[base_path_CASANOSA,'Readers'])


[DATA,META]=read_cris_hdf5_rdr('//flounder/DATA3/data/NPP/CrIS/RCRIS-RNSCA/2012/02/10/RCRIS-RNSCA_npp_d20120210_t0004528_e0005248_b01484_c20120210020044585016_noaa_ops.h5')
y=DATA.idata
figure(1)
plot(real(squeeze(y.MWIT(:,2,2))))
plot(real(squeeze(y.SWSP(:,2,2))))
[DATA,META]=read_cris_hdf5_rdr('//flounder/DATA3/data/NPP/CrIS/RCRIS-RNSCA/2012/02/22/RCRIS-RNSCA_npp_d20120222_t2140443_e2141163_b01667_c20120222233640862049_noaa_ops.h5')
y=DATA.idata
figure(2)
plot(real(squeeze(y.MWIT(:,2,2))))
plot(real(squeeze(y.SWSP(:,2,2))))
[DATA,META]=read_cris_hdf5_rdr('//flounder/DATA3/data/NPP/CrIS/RCRIS-RNSCA/2012/02/23/RCRIS-RNSCA_npp_d20120223_t0616254_e0616574_b01672_c20120223081223875982_noaa_ops.h5')
y=DATA.idata
figure(3)
plot(real(squeeze(y.MWIT(:,2,2))))
plot(real(squeeze(y.SWSP(:,2,2))))
