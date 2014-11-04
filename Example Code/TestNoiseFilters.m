%% Test Filtering for Image statistics.
clear all
close all 
clc

%% Create Noise Patches 
Nframes = 100;
NPixels = 128;
nmov = randn(NPixels,NPixels,Nframes);


%% Display 5 Raw Images
figure('Position',[100 100 1500 1000],'Color','w');
ncol = 5;
nrow = 3;
for i = 1:nrow
  1+(ncol*i-ncol)
  subplot(nrow,ncol,1+(ncol*i-ncol));
  imagesc(nmov(:,:,i)); colormap('bone')
  set(gca,'Box','off','XTick',[],'YTick',[])
end


%% Filter Image

  % Gaussian blur
  stddev = 10;
  kwidth = 3 * stddev;  
  kernel = fspecial('gaussian', kwidth, stddev);
  wb = waitbar(0);
  gmov = zeros(NPixels,NPixels,Nframes);
  for i = 1:Nframes 
    gmov(:,:,i) = conv2(nmov(:,:,i),kernel,'same')
    waitbar(i/100,wb);
  end
  