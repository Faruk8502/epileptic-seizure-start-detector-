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
P=60;
l=2;
N=l*Fs/2;
n=N+P+1;
SEM=0;
Th=20;
% Th2=300;
window=0;
x=zeros(1,length(EEG1));
% Построение нового опорного окна

while n<length(EEG1)-N
n=n+1;

if window==0
f=n;
window=1;  
AR=ar(EEG1(n-N-P:n+N),P);
% Расчет ошибки предсказания_____   
 for k=2:P
  a(k)=AR.A(k);
 end
   e=error1(a,EEG1,n,N,P);
%Рассчет АКФ для ошибки предсказания
clear s
for m=2:P
   for k=-N:N-(m-1)
     s(k+N+1)=e(n+k)*e(n+k+(m-1)); 
   end
   fi(n,m)=1/(2*N+1)*sum(s);
end


else
% Расчет ошибки предсказания_____
   for k=2:P
   a(k)=AR.A(k);
   end
   e=error1(a,EEG1,n,N,P);
% Рассчет АКФ_____________________
   for m=2:P
      fi(n,m)=fi(n-1,m)+e(n+N-1)*e(n+N-(m-1))-e(n-N-1)*e(n-N-1-(m-1));
   end
end
n
clear s
%Рассчет МСО
for k=2:P
   s(k)=(fi(n,k)/fi(n,2))^2;
end
SEM(n)=(fi(f,2)/fi(n,2)-1)^2+2*sum(s);
if SEM(n)>Th && SEM(n-1)<Th
   window=0;
end
end
%%
X0=100;
Y0=90;
H0=670;
W0=1200;
figure('Position',[X0,Y0,W0,H0]);

dx=250;
dy=200;
w1=1000;
h=300;

x1=50;
y1=380;

hAxes1=axes('Units','pixels','Position',[x1,y1,w1,h]);
hAxes2=axes('Units','pixels','Position',[x1,y1-H0/2,w1,h]);

m=0;
for i=1:length(EEG1)-N
    if SEM(i)==Th
        m=1;
        x(i)=1;     
    else
        x(i)=0;
    end
    if SEM(i)==Th && m==1
        m=0;
    end  
end
Limit=Th;
XLimit(1)=0;
XLimit(2)=2*dt-T;
YLimit(1:2)=Limit;
line(XLimit,YLimit);
Jmax=100;
k=0;
j=Jmax;
for i=1:length(EEG1)-N
   j=j+1;
   if (SEM(i)>Limit)&&(j>Jmax)
       k=k+1;
       x(k)=i;
       j=0;
   end
end
axes(hAxes2)
plot(t,EEG1)
hold on
YLimits=get(hAxes2,'YLim');
for i=1:k
   XLimits(1:2)=x(i)*T;
   HLine=line(XLimits,YLimits);
   set(HLine,'LineStyle','--');
end
% hold on
% plot(t(1:7425),SEM)
axes(hAxes1)
plot(t,EEG1)
tit
hold on
for i=1:length(segments2)
   d(i)=200; 
end
bar(segments2,d,0.01)
hold on
bar(segments2,-d*2,0.01)
