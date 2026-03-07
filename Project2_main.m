% Project 2: Space Weather Report
% Part 1 (Everybody)
close all;
clear;
clc;

% figured out ftp, here is the solar data for my birthday (8/15/03)
% :Product: Daily Solar Data         2003_DSD.txt
% #
% #  Prepared by the U.S. Dept. of Commerce, NOAA, Space Environment Center.
% #  Please send comments and suggestions to sec.webmaster@noaa.gov
% #
% #                           2003 Daily Solar Data
% #
% #                         Sunspot       Stanford GOES8
% #           Radio  SESC     Area          Solar  X-Ray  ------ Flares ------
% #           Flux  Sunspot  10E-6   New     Mean  Bkgd    X-Ray      Optical
% #  Date     10.7cm Number  Hemis. Regions Field  Flux   C  M  X  S  1  2  3
% #---------------------------------------------------------------------------
% 2003 08 15  131     86      540      1    -999   B6.8   9  0  0  5  0  0  0

% K/A Index:
% 
% :Product: Daily Geomagnetic Data     2003_DGD.txt
% #
% #  Prepared by the U.S. Dept. of Commerce, NOAA, Space Environment Center.
% #  Please send comment and suggestions to sec.webmaster@noaa.gov
% #
% #                         2003 Daily Geomagnetic Data
% #
% #                Middle Latitude        High Latitude            Estimated
% #              - Fredericksburg -     ---- College ----      --- Planetary ---
% #  Date        A     K-indices        A     K-indices        A     K-indices
% #------------------------------------------------------------------------------
% 2003 08 15     9  2 2 2 2 2 3 2 3    12  3 3 3 1 2 4 2 2    14  3 2 3 2 3 4 4 3

% GOES data filename:
% GOES12_K0_MAG_3014472.csv