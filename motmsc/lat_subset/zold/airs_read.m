
function d1 = airs_quick(afile);

  d1.Latitude  = hdfread(afile, 'Latitude');
  d1.Longitude = hdfread(afile, 'Longitude');
  d1.Time      = hdfread(afile, 'Time');
  d1.scanang   = hdfread(afile, 'scanang');
  d1.radiances = hdfread(afile, 'radiances');

  d1.DayNightFlag   = hdfread(afile, 'DayNightFlag');
  d1.start_year     = hdfread(afile, 'start_year');
  d1.start_month    = hdfread(afile, 'start_month');
  d1.start_day      = hdfread(afile, 'start_day');
  d1.granule_number = hdfread(afile, 'granule_number');

