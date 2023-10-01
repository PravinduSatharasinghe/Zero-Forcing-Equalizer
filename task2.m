close all; clc;
%Defining the system Parameters
number_of_bits_transmitted = 10^3; % Number of Bits Transmitted
sampling_frequency = 10; % sampling frequency in Hz
SNR_dB = 10; %SNR value
NoisePower = 1./(10.^(0.1*SNR_dB)); % Noise Power (Eb = 1 in BPSK)
time = -sampling_frequency:1/sampling_frequency:sampling_frequency; % Time Array

%% Generating the impulse train representing BPSK Signal
% Mapping 0 -> -1 and 1 -> 1 (0 phase and 180 phase)
BPSKSignal = 2*(rand(1,number_of_bits_transmitted)>0.5)-1;
t = 0:1/sampling_frequency:99/sampling_frequency;
stem(t, BPSKSignal(1:100)); xlabel('Time'); ylabel('Amplitude');
title('Impulse Train representing BPSK');
axis([0 10 -1.2 1.2]); grid on;

%% Upsampling the transmit sequence without noise affection
Upsampling_BPSK = [BPSKSignal;zeros(sampling_frequency-1,length(BPSKSignal))]; %Upsampling the BPSK to match the sampling frequency
BPSK_U = Upsampling_BPSK(:).';
figure;
stem(t, BPSK_U(1:100)); xlabel('Time'); ylabel('Amplitude');
title('Impulse Train Representing Upsampled BPSK');
axis([0 10 -1.2 1.2]); grid on;

%% pulse shaping filter with sinc impulse response 
sinc_numerator = sin(pi*time); % numerator of the sinc function
sinc_denominator = (pi*time); % denominator of the sinc function
sinc_denominatorZero = find(abs(sinc_denominator) < 10^-10); % Finding the t=0 position
sinc_pulse_shaping_filter = sinc_numerator./sinc_denominator;
sinc_pulse_shaping_filter(sinc_denominatorZero) = 1; % Defining the t=0 value
figure;
plot(time, sinc_pulse_shaping_filter);
title('Defined Sinc Pulse shape');
xlabel('Time'); ylabel('Amplitude');
axis([-sampling_frequency sampling_frequency -0.5 1.2]); grid on

convolved_transmitsignal = conv(BPSK_U, sinc_pulse_shaping_filter);
convolved_transmitsignal = convolved_transmitsignal(1:10000);
convolved_transmitsignal_reshape = reshape(convolved_transmitsignal, sampling_frequency*2, number_of_bits_transmitted*sampling_frequency/20).';

transmit_signal_sinc = convolved_transmitsignal(1,100:999);
tt=(-0.1:0.1:89.8);
plot(tt,transmit_signal_sinc);
title('Transmit signal after convolved with sinc pulse');

figure;
plot(0:1/sampling_frequency:1.99, real(convolved_transmitsignal_reshape).', 'b');
title('Eye diagram of the Transmit Signal');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -2.4 2.2]);
grid on

%% pulse shaping filter with raised cosine impulse response (gamma = 0.5)
roll_off_factor = 0.5;
raised_cosine_numerator = cos(roll_off_factor*pi*time);
raised_cosine_denominator = (1 - (2 * roll_off_factor * time).^2);
raised_cosine_denominatorZero = abs(raised_cosine_denominator)<10^-10;
raised_cosine_impulse_response = raised_cosine_numerator./raised_cosine_denominator;
raised_cosine_impulse_response(raised_cosine_denominatorZero) = pi/4;
RC_gamma5 = sinc_pulse_shaping_filter.*raised_cosine_impulse_response; % Getting the complete raised cosine pulse
figure;
plot(time, RC_gamma5);
title('Raised Cosine Pulse Shape with gamma = 0.5');
xlabel('Time'); ylabel('Amplitude');
axis([-sampling_frequency sampling_frequency -0.5 1.2]); grid on

Conv_RCgamma5 = conv(BPSK_U,RC_gamma5);
Conv_RCgamma5 = Conv_RCgamma5(1:10000);
Conv_RCgamma5_reshape = reshape(Conv_RCgamma5,sampling_frequency*2,number_of_bits_transmitted*sampling_frequency/20).';

transmit_signal_RCgamma5 = Conv_RCgamma5(1,100:999);
tt=(-0.1:0.1:89.8);
plot(tt,transmit_signal_RCgamma5);
title('Transmit Signal with gamma = 0.5');

figure;
plot(0:1/sampling_frequency:1.99, Conv_RCgamma5_reshape.','b');
title('Eye diagram with gamma = 0.5');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -2.5 2.5]);
grid on

%% pulse shaping filter with raised cosine impulse response (gamma = 1)
roll_off_factor = 1;
raised_cosine_numerator = cos(roll_off_factor * pi * time);
raised_cosine_denominator = (1-(2 * roll_off_factor * time).^2);
raised_cosine_denominatorZero = find(abs(raised_cosine_denominator)<10^-20);
raised_cosine_impulse_response = raised_cosine_numerator./raised_cosine_denominator;
raised_cosine_impulse_response(raised_cosine_denominatorZero) = pi/4;
RC_gamma1 = sinc_pulse_shaping_filter.*raised_cosine_impulse_response; % Getting the complete raised cosine pulse
figure;
plot(time, RC_gamma1);
title('Raised Cosine Pulse shape with gamma = 1');
xlabel('Time'); ylabel('Amplitude');
axis([-sampling_frequency sampling_frequency -0.5 1.2]); grid on

Conv_RCgamma1 = conv(BPSK_U,RC_gamma1);
Conv_RCgamma1 = Conv_RCgamma1(1:10000);
Conv_RCgamma1_reshape = reshape(Conv_RCgamma1,sampling_frequency*2,number_of_bits_transmitted*sampling_frequency/20).';

transmit_signal_RCgamma1 = Conv_RCgamma1(1,100:999);
tt=(-0.1:0.1:89.8);
plot(tt,transmit_signal_RCgamma1);
title('Transmit Signal with gamma = 1');

figure;
plot(0:1/sampling_frequency:1.99, Conv_RCgamma1_reshape.','b');
title('Eye diagram with alpha =1');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -1.5 1.5 ]);
grid on

%% Noise Array Generation based on SNR = 10dB
Noise1D = normrnd (0 , sqrt(NoisePower/2), [1, number_of_bits_transmitted]);
AWGN_TX = BPSKSignal + Noise1D;
figure;
stem(t, AWGN_TX(1:100)); xlabel('Time'); ylabel('Amplitude');
title('Impulse Train representing BPSK with noise');
axis([0 10 -1.5 1.5]); grid on;


%% upsampling the transmit sequence with Noise
Upsampled_Transmitter_with_AWGN_Noise = [AWGN_TX;zeros(sampling_frequency-1,length(BPSKSignal))];
AWGNTx_U = Upsampled_Transmitter_with_AWGN_Noise(:);
figure;
stem(t, AWGNTx_U(1:100)); xlabel('Time'); ylabel('Amplitude');
title('Impulse Train Upsampled BPSK with noise');
axis([0 10 -1.5 1.5]); grid on;

%% sinc pulse shaping with noise
convolved_signal = conv(AWGNTx_U,sinc_pulse_shaping_filter);
convolved_signal = convolved_signal(1:10000);
convolved_signal_reshape = reshape(convolved_signal, sampling_frequency*2, number_of_bits_transmitted*sampling_frequency/20).';
figure;
plot(0:1/sampling_frequency:1.99, convolved_signal_reshape.', 'b');
title('Eye diagram with sinc pulse');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -2.4 2.2]);
grid on

%% raised cosine pulse shaping with noise (gamma = 0.5)
Conv_RC5noise = conv(AWGNTx_U,RC_gamma5);
Conv_RC5noise = Conv_RC5noise(1:10000);
Conv_RC5noise_reshape = reshape(Conv_RC5noise,sampling_frequency*2,number_of_bits_transmitted*sampling_frequency/20).';
figure;
plot(0:1/sampling_frequency:1.99, Conv_RC5noise_reshape.', 'b');
title('Eye diagram with gamma = 0.5 noisy');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -2.4 2.2]);
grid on

%% raised cosine pulse shaping with noise (gamma = 1)
Conv_R1noise = conv(AWGNTx_U,RC_gamma1);
Conv_R1noise = Conv_R1noise(1:10000);
Conv_R1noise_reshape = reshape(Conv_R1noise,sampling_frequency*2,number_of_bits_transmitted*sampling_frequency/20).';
figure;
plot(0:1/sampling_frequency:1.99, Conv_R1noise_reshape.', 'b');
title('Eye diagram with gamma = 1.0 noisy');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -2.4 2.2]);
grid on

