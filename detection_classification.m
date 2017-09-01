close all;
clear all;

%%Loading in the files
load MAp;
load MHp;
load butterfilter186;
load butterfilterosc;

%%Sampling rate
leng = 900000; %length of data
samp_rate = 15000;
samp_time = leng/samp_rate;

%%Before pre-processing plots
t = [0:1/samp_rate:samp_time-1/samp_rate];
figure();
plot(t, MAp(1,:));

%%Pre-processing using buttersworth filter
MAp_filt = filter(Hd,MAp(1,:));

figure();
plot(t, MAp_filt);
xlabel('');

%%Taking a particular part of the data
test1 = MAp_filt(6.06*10e4:6.09*10e4);
figure();
plot([0:length(test1)-1],test1);

% %%Yule Power Spectrum
Y_filt = fft(test1);
[pxx,f] = pyulear(test1, 64, freq, 15000);

figure();
plot(f,pxx);
xlim([0 1000]);

%%Yule Power Spectrum of different segments
%Baseline
baseline = MAp_filt(0.25*10e4:0.3*10e4);
freq = 0:samp_rate/length(baseline):7500; %frequency axis
[pxx_base,f_base] = pyulear(baseline, 64, freq, 15000);

%Oscillatory
osc = MAp_filt(2.25*10e4:2.3*10e4);
figure();
plot(osc);
[pxx_osc, f_osc] = pyulear(osc, 64, freq, 15000);

%Spiking
spik = MAp_filt(7*10e4:7.05*10e4);
[pxx_spik, f_spik] = pyulear(spik, 64, freq, 15000);
figure();
plot(f_base, pxx_base, f_osc, pxx_osc, f_spik, pxx_spik);
legend('Baseline PSD', 'Oscillatory PSD', 'Spiking PSD');
xlim([0 1000]);

%Baseline autocorrelation
[autocor, lags] = xcorr(baseline, 0.4*15000, 'coeff');
figure();
plot(lags/15000, autocor);
xlabel('Lag (seconds)');
ylabel('Autocorrelation');
auto_filt = filter(Hd_osc,autocor);
figure();
plot(lags/15000, auto_filt);
[pks, locs] = findpeaks(auto_filt);
hold on;
scatter(locs/15000-length(lags)/30000, pks, 'o');
[pxx_auto_b, f_auto_b] = pyulear(autocor, 64, freq, 15000);

%Spiking autocorrelation
[autocor, lags] = xcorr(spik, 0.4*15000, 'coeff');
figure();
plot(lags/15000, autocor);
xlabel('Lag (seconds)');
ylabel('Autocorrelation');
hold on;
scatter(locs/15000-length(lags)/30000, pks, 'o');
[pxx_auto_s, f_auto_s] = pyulear(autocor, 64, freq, 15000);

%Oscillation autocorrelation
[autocor, lags] = xcorr(osc, 0.4*15000, 'coeff');
figure();
plot(lags/15000, autocor);
xlabel('Lag (seconds)');
ylabel('Autocorrelation');
hold on;
scatter(locs/15000-length(lags)/30000, pks, 'o');
[pxx_auto_o, f_auto_o] = pyulear(autocor, 64, freq, 15000);

%plotting autocorrelation
figure();
plot(f_auto_o, pxx_auto_o, f_auto_b, pxx_auto_b, f_auto_s, pxx_auto_s);
legend('Oscillatory', 'Baseline', 'Spiking')
xlim([0 500]);
[ipks, iloc] = findpeaks(pxx_auto_o,'MinPeakProminence',1);

% %%Classification
% %bin based calc
figure();
bin_length = 0.05*10e4; %1/3 of a second based on 15000Hz sampling rate
ifreq = 0:samp_rate/bin_length:7500; %frequency axis
for i = 1:bin_length:length(t)-bin_length
    sample = MAp_filt(i:i+bin_length);
    [autocor, lags] = xcorr(sample, 0.4*15000, 'coeff');
    try
    [ipxx_auto, if_auto] = pyulear(autocor, 64, freq, 15000);
    [ipks, iloc] = findpeaks(ipxx_auto,'MinPeakProminence',1);
        for i = 1:1:length(iloc)
            iloc(i) = if_auto(iloc(i));
        end
    catch
    end
       scatter(ipks, iloc, 'o');
       hold on;
end
