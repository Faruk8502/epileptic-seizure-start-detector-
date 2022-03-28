Fs=256;
T=1/Fs;
using XLSX
T1 = XLSX.openxlsx("Моменты начала.xlsx", mode="w") do xf
    sheet = xf[1]
    sheet["B1", dim=1] = collect(1:3)
end
t0=T1[1,1];
dt=15;
t=0:T:2*dt|> collect;
using EDF
const DATADIR = joinpath(@__DIR__, "chb01_03.edf")
edf = EDF.read(DATADIR)
edf_channel = edf.signals[1]
EEG = edf_channel.samples[1:250]
EEG1=EEG[(t0-dt)*Fs:(t0+dt)*Fs,2];
plot(t,EEG1);
