# Настройка временной шкалы_______________________
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
#__________________________________________________

# Чтение EDF файла_________________________________
using EDF
const DATADIR = joinpath(@__DIR__, "chb01_03.edf")
edf = EDF.read(DATADIR)
edf_channel = edf.signals[1]
EEG = edf_channel.samples[1:512]
EEG1=EEG[(t0-dt)*Fs+1:(t0+dt)*Fs,1];
#plot(t,EEG1);
EEG2 = Vector{Float64}(undef, length(EEG))
for i in 1:length(EEG)
    EEGi = Float64(EEG[i])
    EEG2[i] = EEGi
end
#__________________________________________________

using StateSpaceModels
using  Dates

# Инициализация переменных__________________________
P=4
l=1
N=Int64(l*Fs/32)
n=N+P+1
SEM= Vector{Float64}(undef,length(EEG))
SEM = fill(0.0, length(EEG))
Th=20
# Th2=300;
window=0
a= Vector{Float64}(undef, P)
s= Vector{Float64}(undef, P)
s = fill(0.0, P)
g= Vector{Float64}(undef, 2*N+P+1)
g = fill(0.0, 2*N+P+1)
fi= Matrix{Float64}(undef, length(EEG), P)
fi = fill(0.0, length(EEG), P)
e= Vector{Float64}(undef, length(EEG))
e = fill(0.0, length(EEG))
f=0
#____________________________________________________

# МСО________________________________________________
while n<length(EEG)
    n=n+1;
    if window==0
       # Построение нового опорного окна 
        f=n;
        window=1;
        model = SARIMA(EEG2, order = (P,0,1))
        fit!(model)
        # Расчет ошибки предсказания_____
        for k in 2:P
            a[k]=model.hyperparameters_auxiliary.ar_poly[k];
        end
        e=error1(a,EEG2,n,N,P);
        #Рассчет АКФ для ошибки предсказания
        fi = AKFErr1(e,n,N,P);
        return model
    else
        # Расчет ошибки предсказания_____
        for k in 1:P
            a[k]=model.hyperparameters_auxiliary.ar_poly[k];
        end
        e=error1(a,EEG2,n,N,P);
        # Рассчет АКФ_____________________
        fi = AKFErr1(e,n,N,P);
    end

    s = fill(0.0, 4)
    # Рассчет МСО
    for k in 2:P
        s[k]=(fi[n,k]/fi[n,2])^2;
    end

    SEM[n]=(fi[f,2]/fi[n,2]-1)^2+2*sum(s);
    
    if SEM[n]>Th && SEM[n-1]<Th
        window=0;
    end
    
    return model
end
#_________________________________________________

function AKFErr2(e,n,N,P)
    for m in 2:P
        fi[n,m]=fi[n-1,m]+e[n+N-1]*e[n+N-(m-1)]-e[n-N-1]*e[n-N-1-(m-1)];
    end
    return fi
end

function AKFErr1(e,n,N,P)
    s = fill(0.0, 4)
    for m in 2:P
        for k in -N:N-(m-1)
            g[k+N+1]=e[n+k]*e[n+k+(m-1)];
        end
        fi[n,m]=1/(2*N+1)*sum(g);
    end
    return fi
end

using PlotlyJS
plot(e)
p1=[plot(SEM[1:512])  plot(EEG2)]

function error1(a,EEG2,n,N,P)
    for i in n-N:n+N    
       for k in 2:P
            s[k]=a[k]*EEG2[i-k]
       end
       e[i]=sum(s);
     # if abs(e(i))>=Th2
     #     e(i)=sign(e(i))*Th2;
     # end
    end
    return e
end

#
    # @show typeof(f)
    # @show typeof(n)
    # @show fi[f,2]
    # @show fi[n,2]
