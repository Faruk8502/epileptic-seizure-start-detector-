load('Start_moment.mat');
t0=T1(1,1);
dt=15;
t=0:T:2*dt;
EEG=readmatrix('chb03_01_data.txt');
EEG1=EEG((t0-dt)*Fs:(t0+dt)*Fs,2);
% plot(t,EEG1);
% hold on
% for i=1:17
%    y(i)=200;
%    s(i)=segments(i,2)/256;
% end
% bar(s,y,0.01,'r')
N=7681;
ncs=floor(N/14);
nov=floor(ncs/2);
nfft = 2^nextpow2(ncs);
spectrogram(EEG1,hamming(ncs),nov,nfft,Fs,'yaxis');