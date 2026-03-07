% Project 2: Space Weather Report
% Part 1 (Everybody)
close all;
clear;
clc;

% comments where i was figuring out data:

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

% project start:

% August 15, 2003
targetDate = datetime(2003, 8, 15);
% disp(['Generating Space Weather Report for: ', datestr(targetDate)]);

% Define common X-axis limits for all plots (1 full day)
x_limits = [targetDate, targetDate + days(1)];

%% 1. STATE OF THE SUN (Sunspots, 10.7 cm flux)
% Load NOAA DSD
dsd = readmatrix('2003_DSD.txt', 'NumHeaderLines', 11);
idx_dsd = find(dsd(:,1) == 2003 & dsd(:,2) == 8 & dsd(:,3) == 15);

f107 = dsd(idx_dsd, 4); % F10.7 flux 
ssn  = dsd(idx_dsd, 5); % Sunspot number 

%% 2. INTERPLANETARY MEDIUM (Solar wind, particle flux, IMF)
% Load OMNIWeb Data (Columns: Yr, DOY, Hr, Min, Bz, Speed, Density)
omni = readmatrix('omni_min_yRB3fnSiPA.lst.txt');

% Convert Yr/DOY/Hr/Min into MATLAB datetime
time_omni = datetime(omni(:,1), 1, 1) + days(omni(:,2) - 1) + ...
            hours(omni(:,3)) + minutes(omni(:,4));

imf_bz  = omni(:, 5);
sw_spd  = omni(:, 6);
sw_dens = omni(:, 7); % Proton density (particle flux surrogate)

% Clean OMNI fill values (999.99, 9999.99, etc.)
imf_bz(imf_bz > 9000) = NaN;
sw_spd(sw_spd > 90000) = NaN;
sw_dens(sw_dens > 900) = NaN;

%% 3. EARTH'S MAGNETOSPHERE (K/A index, magnetometer data)
% Load NOAA DGD (Kp Index)
dgd = readmatrix('2003_DGD.txt', 'NumHeaderLines', 13);
idx_dgd = find(dgd(:,1) == 2003 & dgd(:,2) == 8 & dgd(:,3) == 15);

kp_indices = dgd(idx_dgd, 23:30);
time_kp = targetDate + hours(0:3:21); 

% Load GOES12 Magnetometer
opts = detectImportOptions('GOES12_K0_MAG_3014472.csv', 'CommentStyle', '#');
goes_data = readtable('GOES12_K0_MAG_3014472.csv', opts);

time_goes = datetime(goes_data{:, 1}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''');
goes_hp   = goes_data{:, 2};

% Clean GOES fill values 
goes_hp(goes_hp < -9000) = NaN;

%% ========
% PLOTTING
% =========
