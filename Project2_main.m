% Project 2: Space Weather Report
% Part 1 (Everybody)
close all;
clear;
clc;

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
%  PLOTTING
%  ========

% Create figure to take up a full page in latex
% also force light mode because my matlab is in dark mode
fig = figure('Name', 'Space Weather Report: 08/15/2003', ...
             'Units', 'inches', 'Position', [1, 1, 6.5, 9], 'Color', 'w');

% --- Subplot 1: State of the Sun ---
ax1 = subplot(5,1,1);
yyaxis left
plot(x_limits, [f107 f107], '-', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
ylabel('F10.7 (sfu)');
ylim([0, max(200, f107*1.5)]); 

yyaxis right
plot(x_limits, [ssn ssn], '-', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 2);
ylabel('Sunspot #');
ylim([0, max(200, ssn*1.5)]);

title('1) State of the Sun: F10.7 Flux & Sunspot Number', 'Color', 'k');
xlim(x_limits);
grid on;
set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% --- Subplot 2: Interplanetary Medium (Solar Wind & Particle Flux) ---
ax3 = subplot(5,1,2);
yyaxis left
plot(time_omni, sw_spd, 'b', 'LineWidth', 1.2);
ylabel('Speed (km/s)');

yyaxis right
plot(time_omni, sw_dens, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.2);
ylabel('Density (n/cc)');

title('2) Interplanetary Medium: Solar Wind & Particle Flux', 'Color', 'k');
xlim(x_limits);
grid on;
set(ax3, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% --- Subplot 3: Interplanetary Medium (IMF) ---
ax2 = subplot(5,1,3);
plot(time_omni, imf_bz, 'r', 'LineWidth', 1.2);
yline(0, 'k--', 'LineWidth', 1); 
ylabel('IMF B_z (nT)');
title('2) Interplanetary Medium: Magnetic Field', 'Color', 'k');
xlim(x_limits);
grid on;
set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');



% --- Subplot 4: Earth's Magnetosphere (K/A Index) ---
ax5 = subplot(5,1,4);
bar(time_kp, kp_indices, 'FaceColor', [0.2 0.6 0.5], 'BarWidth', 1);
ylabel('Kp Index');
xlabel('Time (UTC)');
ylim([0 9]);
yline(5, 'r--', 'G1 Storm Threshold');
title('3) Earth''s Magnetosphere: Planetary K/A Index', 'Color', 'k');
xlim(x_limits);
grid on;
set(ax5, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% --- Subplot 5: Earth's Magnetosphere (Magnetometer) ---
ax4 = subplot(5,1,5);
plot(time_goes, goes_hp, 'k', 'LineWidth', 1.2);
ylabel('GOES H_p (nT)');
title('3) Earth''s Magnetosphere: GOES-12 Magnetometer', 'Color', 'k');
xlim(x_limits);
grid on;
set(ax4, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

%% Command Window Output for easy interpreting
fprintf('\n==================================================\n');
fprintf(' SPACE WEATHER SUMMARY: %s\n', datestr(targetDate));
fprintf('==================================================\n\n');

fprintf('1) STATE OF THE SUN\n');
fprintf('   - 10.7 cm Radio Flux: %d sfu\n', f107);
fprintf('   - Sunspot Number:     %d\n\n', ssn);

fprintf('2) INTERPLANETARY MEDIUM\n');
fprintf('   - Max Solar Wind Speed: %.1f km/s\n', max(sw_spd));
fprintf('   - Min IMF Bz:           %.1f nT\n\n', min(imf_bz));

fprintf('3) EARTH''S MAGNETOSPHERE\n');
fprintf('   - Maximum Kp Index:     %d\n', max(kp_indices));

if max(kp_indices) >= 5
    fprintf('   - Condition: Geomagnetic Storming Present\n');
else
    fprintf('   - Condition: Quiet to Active (No major storming)\n');
end
fprintf('==================================================\n');