import("stdfaust.lib");

declare options "[midi:on][nvoices:-6]";
freq = hslider("freq",200,50,12000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");

att = nentry("Env att",0.2,0.001,12,0.01); //, vslider("Env att_",0.2,0.001,12,0.01);
dec = nentry("Env dec",0.2,0.001,12,0.01); //, vslider("Env dec_",0.2,0.001,12,0.01);
sus = nentry("Env sus",0.8,0,1,0.01); //, vslider("Env sus_",0.8,0,1,0.01);
rel = nentry("Env rel",0.2,0.001,12,0.01); //, vslider("Env rel_",0.2,0.001,12,0.01);
_adsr = en.adsr(att,dec,sus,rel,gate)*gain;


freq_ratio1 = nentry("freq ratio 1",0.50,0.001,3.000,0.010);
freq1 = freq*freq_ratio1;
harm_ratio1 = nentry("harm ratio 1",0.020,0.001,3.000,0.010);
gain1 = hslider("gain 1",0.1,0,1,0.01) : si.smoo;

freq_ratio2 = nentry("freq ratio 2",0.50,0.001,3.000,0.010);
freq2 = freq*freq_ratio2;
harm_ratio2 = nentry("harm ratio 2",0.020,0.001,3.000,0.010);
gain2 = hslider("gain 2",0.1,0,1,0.01) : si.smoo;

freq_ratio3 = nentry("freq ratio 3",0.50,0.001,3.000,0.010);
freq3 = freq*freq_ratio3;
harm_ratio3 = nentry("harm ratio 3",0.020,0.001,3.000,0.010);
gain3 = hslider("gain 3",0.1,0,1,0.01) : si.smoo;

freq_ratio4 = nentry("freq ratio 4",0.50,0.001,3.000,0.010);
freq4 = freq*freq_ratio4;
harm_ratio4 = nentry("harm ratio 4",0.020,0.001,3.000,0.010);
gain4 = hslider("gain 4",0.1,0,1,0.01) : si.smoo;

proc1 = par(i,4,os.saw3(freq1*(i+1)+(i*freq1*harm_ratio1))) :> /(4)*gain1;
proc2 = par(i,4,os.saw3(freq2*(i+1)+(i*freq2*harm_ratio2))) :> /(4)*gain2;
proc3 = par(i,4,os.saw3(freq3*(i+1)+(i*freq3*harm_ratio3))) :> /(4)*gain3;
proc4 = par(i,4,os.saw3(freq4*(i+1)+(i*freq4*harm_ratio4))) :> /(4)*gain4;

filter_Q = hslider("Filter Q",60,0,20000,1) : si.smoo;
filter_TN = hslider("Filter TN",0.1,0,1,0.01) : si.smoo;


process = proc1 , proc2 , proc3 , proc4 :> /(4)*_adsr : fi.lptN(filter_Q,filter_TN);