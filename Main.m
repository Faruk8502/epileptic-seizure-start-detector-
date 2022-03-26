Fs=256;
T=1/Fs;
load('Start_moment.mat');
t0=T1(1,1);
dt=15;
t=0:T:2*dt;
EEG=readmatrix('chb03_01_data.txt');
EEG1=EEG((t0-dt)*Fs:(t0+dt)*Fs,2);
plot(t,EEG1);

%% 
P=8;
l=2;
N=l*Fs/2;
n=N+P+1;
SEM=0;
Th=1000;
window=0;
x=zeros(1,length(EEG1));
% Построение нового опорного окна

while n<length(EEG1)-N
n=n+1;

if window==0
window=1;    
AR=ar(EEG1(n-N-P:n+N),P);
% Расчет ошибки предсказания_____
for i=n-N:n+N    
   for k=1:P+1
   s(k)=(AR.A(k)*EEG1(i-k));
   end
   e(i)=sum(s);
end
%Рассчет АКФ для ошибки предсказания
clear s
for m=1:P+1
   for k=-N:N-(m-1)
     s(k+N+1)=e(n+k)*e(n+k+(m-1)); 
   end
   fi(n,m)=1/(2*N+1)*sum(s);
   a=0
end


else
% Расчет ошибки предсказания_____
for i=n-N:n+N    
   for k=1:P+1
   s(k)=(AR.A(k)*EEG1(i-k));
   end
   e(i)=sum(s);
end
% Рассчет АКФ_____________________
   for m=1:P+1
      fi(n,m)=fi(n-1,m)+e(n+N-1)*e(n+N-(m-1))-e(n-N-1)*e(n-N-1-(m-1));
   end
end
a=1
n
clear s
%Рассчет МСО
for k=1:P+1
   s(k)=(fi(n,k)/fi(n,1))^2;
end
SEM(n)=(fi(N+P+1,1)/fi(n,1)-1)^2+2*sum(s);
x(n)=0;
if SEM(n)>Th
   n=n+1; 
   x(n)=1000;
   window=0;
end
end