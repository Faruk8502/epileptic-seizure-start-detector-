Fs=256;
T=1/Fs;
#using XLSX
#T1 = XLSX.openxlsx("Моменты начала.xlsx", mode="w") do xf
#    sheet = xf[1]
#   sheet["B1", dim=1] = collect(1:3)
#end
T1 = 1
t0=T1[1,1];
dt=1;
t=0:T:2*dt|> collect;

using EDF
const DATADIR = joinpath(@__DIR__, "chb01_03.edf")
edf = EDF.read(DATADIR)
edf_channel = edf.signals[1]
EEG = edf_channel.samples[1:512]
EEG1=EEG[(t0-dt)*Fs+1:(t0+dt)*Fs,1];
plot(t,EEG1);

EEG2 = Vector{Float64}(undef, length(EEG))
for i in 1:length(EEG)
EEGi = Float64(EEG[i])
EEG2[i] = EEGi
end

using StateSpaceModels
using  Dates
model = SARIMA(EEG2, order = (4,0,1))
fit!(model)
results(model)


P=4
l=1
N=Int64(l*Fs/2)
n=N+P+1
SEM=0
Th=20
# Th2=300;
window=0
a= Vector{Float64}(undef, P)
s= Vector{Float64}(undef, P)
fi= Matrix{Float64}(undef, length(EEG), P)
e= Vector{Float64}(undef, length(EEG))
f=0
while n<length(EEG)-N
    n=n+1;
    if window==0
       # Построение нового опорного окна 
        f=n;
        window=1;
        model = SARIMA(EEG2, order = (P,0,1))
        fit!(model)
        # Расчет ошибки предсказания_____
        for k in 2:P
            a[k-1]=model.hyperparameters_auxiliary.ar_poly[k-1];
        end
        e=error1(a,EEG2,n,N,P);
        #Рассчет АКФ для ошибки предсказания
        s = 0
        for m in 2:P
            for k in -N:N-(m-1)
                s[k+N+1]=e[n+k]*e[n+k+(m-1)];
            end
            fi[n,m]=1/[2*N+1]*sum(s);
        end
    else
        # Расчет ошибки предсказания_____
        for k in 2:P
            a[k-1]=model.hyperparameters_auxiliary.ar_poly[k-1];
        end
        e=error1(a,EEG2,n,N,P);
        # Рассчет АКФ_____________________
        for m in 2:P
            fi[n,m]=fi[n-1,m]+e[n+N-1]*e[n+N-(m-1)]-e[n-N-1]*e[n-N-1-(m-1)];
        end
    end

    s = 0
    # Рассчет МСО
    for k in 2:P
        s[k]=(fi[n,k]/fi[n,2])^2;
    end
    SEM[n]=(fi[f,2]/fi[n,2]-1)^2+2*sum(s);
    if SEM[n]>Th && SEM[n-1]<Th
        window=0;
    end
end


function error1(a,EEG2,n,N,P)
    for i in n-N:n+N    
       for k in 2:P
            s[k]=a[k]*EEG2[i-k]
       end
       ei=sum(s);
     # if abs(e(i))>=Th2
     #     e(i)=sign(e(i))*Th2;
     # end
    end
    return e
end
