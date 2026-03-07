% Project 2: Space Weather Report
% Part 2 (6970 only)
close all;
clear;
clc;

% Historical D-RAP Model Run Re-creation for 08/15/2003
% (Polar Cap Absorption Algorithm using GOES EPS)
% =========================================================================

%% 1. Load Historical GOES-10 EPS Data (D-RAP Input)

% Read the entire file as raw text and split it line by line
raw_text = fileread('GOES10_EPS.csv');
all_lines = splitlines(raw_text);

% Keep only the lines that actually start with '2003' 
% (ignores all headers, footers, and column titles)
data_lines = all_lines(startsWith(all_lines, '2003'));

% Preallocate arrays for speed
num_pts = length(data_lines);
time_str = strings(num_pts, 1);
proton_flux = zeros(num_pts, 1);

% Extract the time string and proton flux number from each line
for i = 1:num_pts
    cols = split(data_lines(i), ',');
    time_str(i) = cols(1);
    proton_flux(i) = str2double(cols(2));
end

% Safely convert the clean extracted strings into datetimes
time_eps = datetime(time_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''');

% Clean fill values (NASA uses negatives like -1.0e31 for missing data)
proton_flux(proton_flux < 0) = NaN;

%% 2. D-RAP Model Logic: Calculate 10 MHz Polar Cap Absorption (PCA)
% The NOAA D-RAP model uses this relationship for daytime 
% Polar Cap Absorption (PCA) at 30 MHz during Solar Radiation Storms:
% A_30MHz (dB) = 0.115 * sqrt( J(E>10MeV) )
%
% HF absorption scales inversely with the square of the frequency (1/f^2).
% To find the absorption at 10 MHz, we multiply by (30/10)^2 = 9.
% Threshold: NOAA defines an S1 radiation storm when >10 MeV flux exceeds 10 pfu.

absorption_10MHz = zeros(length(proton_flux), 1);

for i = 1:length(proton_flux)
    if proton_flux(i) >= 10 % Only calculate if above the S1 storm threshold
        absorption_10MHz(i) = 9 * (0.115 * sqrt(proton_flux(i)));
    else
        absorption_10MHz(i) = 0; % Background baseline
    end
end

%% 3. Plotting the Historical Model Run
fig2 = figure('Name', 'Part 2: D-RAP Model Run (PCA)', 'Units', 'inches', ...
              'Position', [1.5, 1.5, 6.5, 5], 'Color', 'w');

% --- Panel A: Historical >10 MeV Proton Flux ---
ax1 = subplot(2,1,1);
semilogy(time_eps, proton_flux, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
ylabel('Flux (pfu)', 'Color', 'k');
title('GOES-10 Energetic Proton Flux (> 10 MeV)', 'Color', 'k');
grid on; 
set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Add NOAA Solar Radiation Storm (S-Scale) Thresholds
yline(10, 'r--', 'S1 (Minor)', 'LabelHorizontalAlignment', 'left');
yline(100, 'r--', 'S2 (Moderate)', 'LabelHorizontalAlignment', 'left');

% Force y-axis limits to capture background and storm levels
ylim([max(0.1, min(proton_flux)*0.5), max(1000, max(proton_flux)*2)]);
xlim([min(time_eps) max(time_eps)]);

% --- Panel B: Modeled D-RAP Polar Cap Absorption ---
ax2 = subplot(2,1,2);
plot(time_eps, absorption_10MHz, 'k', 'LineWidth', 1.5);
ylabel('Absorption (dB)', 'Color', 'k');
xlabel('Time (UTC)', 'Color', 'k');
title('Modeled D-RAP Polar Cap Absorption at 10 MHz', 'Color', 'k');
grid on; 
set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

ylim([-1 10]);
xlim([min(time_eps) max(time_eps)]);

%% 4. Text Output to easily interpret data for the report
fprintf('\n==================================================\n');
fprintf(' PART 2: HISTORICAL D-RAP MODEL ANALYSIS (PCA)\n');
fprintf('==================================================\n');
fprintf('Max >10 MeV Proton Flux: %1.2f pfu\n', max(proton_flux));
fprintf('Max Modeled 10 MHz PCA:  %1.1f dB\n', max(absorption_10MHz));

if max(proton_flux) < 10
    fprintf('\nModel Conclusion: The historical proton flux remained below the S1\n');
    fprintf('storm threshold (10 pfu) all day. The D-RAP model yields 0 dB of\n');
    fprintf('anomalous Polar Cap Absorption. This supports the Part 1 assessment,\n');
    fprintf('confirming that high-latitude/trans-polar HF radio propagation was\n');
    fprintf('completely undisturbed by solar energetic particles.\n');
end
fprintf('==================================================\n');