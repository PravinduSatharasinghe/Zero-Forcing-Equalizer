%Task 3  Designing a zero-forcing (ZF) equalizer for a 3-tap multipath channel

sequenceLength = 10^6; % Length of the binary sequence
ebN0dB = 0:10; % multiple Eb/N0 values
tapCount = 4;
errorCount = zeros(tapCount, length(ebN0dB)); % Initialize error count

for n_i = 1:length(ebN0dB)
    
    % Transmitter
    Ik = rand(1, sequenceLength) > 0.5; % Generating a random binary sequence
    ak = 2 * Ik - 1; % BPSK modulation 0 -> -1; 1 -> +1
    
    % Channel model, multipath channel
    nTap = 3;
    channelImpulseResponse = [0.3 0.9 0.4];
    
    channelOutput = conv(ak, channelImpulseResponse);
    noise = 1/sqrt(2) * (randn(1, sequenceLength + length(channelImpulseResponse) - 1) + 1j * randn(1, sequenceLength + length(channelImpulseResponse) - 1)); % White Gaussian noise, 0dB variance
    
    % Noise addition
    y = channelOutput + 10^(-ebN0dB(n_i) / 20) * noise; % Additive white Gaussian noise
    
    for kk = 1:tapCount
        chaImpulseResponseLen = length(channelImpulseResponse);
        hM = toeplitz([channelImpulseResponse(2:end), zeros(1, 2 * kk + 1 - chaImpulseResponseLen + 1)], [channelImpulseResponse(2:-1:1), zeros(1, 2 * kk + 1 - chaImpulseResponseLen + 1)]);
        
        d = zeros(1, 2 * kk + 1);
        d(kk + 1) = 1;
        
        c = inv(hM) * d.';
        
        % Matched filter
        filteredSignal = conv(y, c);
        filteredSignal = filteredSignal(kk + 2:end);
        filteredSignal = conv(filteredSignal, ones(1, 1)); % Convolution
        sampledSignal = filteredSignal(1:1:sequenceLength); % Sampling at time T
        
        % Receiver - hard decision decoding
        decodedSequence = real(sampledSignal) > 0;
        
        % Counting the errors
        errorCount(kk, n_i) = sum(Ik ~= decodedSequence);
    end
end

simulatedBER = errorCount / sequenceLength; % Simulated BER
theoryBer = 0.5 * erfc(sqrt(10.^(ebN0dB / 10))); % Theoretical BER

%% Plot
close all
figure
semilogy(ebN0dB, simulatedBER(1,:), 'bs-'), 'Linewidth', 2;
hold on
semilogy(ebN0dB, simulatedBER(2,:), 'gd-'), 'Linewidth', 2;
semilogy(ebN0dB, simulatedBER(3,:), 'ks-'), 'Linewidth', 2;
semilogy(ebN0dB, simulatedBER(4,:), 'mx-'), 'Linewidth', 2;
semilogy(ebN0dB, theoryBer, 'ro-'), 'Linewidth',2;
axis([0 10 10^-3 0.5])
grid on

%legend('sim-3tap', 'sim-5tap', 'sim-7tap', 'sim-9tap');
legend('sim-3tap', 'sim-5tap', 'sim-7tap', 'sim-9tap','AWGN Channel');
xlabel('Eb/No, dB');
ylabel('Bit Error Rate');
title('Bit error probability curve for BPSK in ISI with ZF equalizer');
