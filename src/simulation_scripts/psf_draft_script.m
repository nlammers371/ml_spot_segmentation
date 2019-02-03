% psf = simulate_locus_psf(varargin)

%%Define parameters
close all;
psf_sampling = 0.5e-6;%focal plane sampling in meters
lambda = 0.6328e-6;%wavelength in meters
N = 256;
aperture_diameter = 0.0254;%meters; 1 inch
focal_length = 5*aperture_diameter;%meters
RMS_SA = 0.25;%RMS spherical aberration content in waves
%%Calculate pupil plane sampling
delta_fx = 1/(psf_sampling*N);
x_pupil = (-fix(N/2):fix((N-1)/2)) * delta_fx * lambda * focal_length;
[X_pupil,Y_pupil] = meshgrid(x_pupil);
R_pupil = sqrt(X_pupil.^2 + Y_pupil.^2);
R_norm = R_pupil/(aperture_diameter/2);%Pupil normalized to aperture diameter
assert(max(R_norm(:))>=sqrt(2),'Sampling is not sufficient to reconstruct the entire wavefront.');
%%Create wavefront
W = RMS_SA * sqrt(5) * (6*R_norm.^4 - 6*R_norm.^2 + 1);%Spherical Aberration wavefront
W(R_norm>1) = 0;
E = exp(1i*2*pi*W);%Complex amplitude
E(R_norm>1) = 0;%Impose aperture size
figure;imagesc(angle(E)/(2*pi));colorbar;title('Wavefront Phase (waves)');
%%Create point-spread function
psf = abs(fftshift(fft2(ifftshift(E)))).^2;
psf = psf/sum(psf(:));%Normalize to unity energy
x_psf = (-fix(N/2):fix((N-1)/2)) * psf_sampling;
figure;imagesc(x_psf*1e6,x_psf*1e6,psf);
title(sprintf('PSF with %.4f waves RMS of Spherical Aberration', RMS_SA));
xlabel(sprintf('Position (\\mum)'));
ylabel(sprintf('Position (\\mum)'));