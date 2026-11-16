import("stdfaust.lib");

declare options "[midi:on][nvoices:6]";
/*freq = hslider("freq",60,36,96,1) : midikey2hz 
with {
    midikey2hz(mk) = 440.0*pow(2.0, (mk-69.0)/12.0); 
}; 
gate = button("gate");
gain = hslider("Main Gain",0.1,0,1,0.01);*/
freq = hslider("freq",200,50,12000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");

att = hslider("[%0]Env att[style:knob]",0.2,0.001,12,0.01); //, vslider("Env att_",0.2,0.001,12,0.01);
dec = hslider("[%0]Env dec[style:knob]",0.2,0.001,12,0.01); //, vslider("Env dec_",0.2,0.001,12,0.01);
sus = hslider("[%0]Env sus[style:knob]",0.8,0,1,0.01); //, vslider("Env sus_",0.8,0,1,0.01);
rel = hslider("[%0]Env rel[style:knob]",0.2,0.001,12,0.01); //, vslider("Env rel_",0.2,0.001,12,0.01);
_adsr = hgroup("Envelope",en.adsr(att,dec,sus,rel,gate))*gain;

main_gain = hslider("Main Gain",0.5,0,1,0.01);
freq_ratio1 = nentry("freq ratio 1",0.50,0.001,3.000,0.010);
freq1 = freq*freq_ratio1;
harm_ratio1 = nentry("harm ratio 1",0.020,0.001,3.000,0.010);
gain1 = hslider("[%0]gain 1[style:knob]",0.1,0,1,0.01) : si.smoo;

freq_ratio2 = nentry("freq ratio 2",0.50,0.001,3.000,0.010);
freq2 = freq*freq_ratio2;
harm_ratio2 = nentry("harm ratio 2",0.020,0.001,3.000,0.010);
gain2 = hslider("[%0]gain 2[style:knob]",0.1,0,1,0.01) : si.smoo;

freq_ratio3 = nentry("freq ratio 3",0.50,0.001,3.000,0.010);
freq3 = freq*freq_ratio3;
harm_ratio3 = nentry("harm ratio 3",0.020,0.001,3.000,0.010);
gain3 = hslider("[%0]gain 3[style:knob]",0.1,0,1,0.01) : si.smoo;

freq_ratio4 = nentry("freq ratio 4",0.50,0.001,3.000,0.010);
freq4 = freq*freq_ratio4;
harm_ratio4 = nentry("harm ratio 4",0.020,0.001,3.000,0.010);
gain4 = hslider("[%0]gain 4[style:knob]",0.1,0,1,0.01) : si.smoo;

proc1 = hgroup("s1",
    vgroup("1", par(i,4,os.saw3(freq1*(i+1)+(i*freq1*harm_ratio1))) :> /(4)*gain1),
    vgroup("2", par(i,4,os.saw3(freq2*(i+1)+(i*freq2*harm_ratio2))) :> /(4)*gain2)
);
proc2 = hgroup("s2",
    vgroup("3", par(i,4,os.saw3(freq3*(i+1)+(i*freq3*harm_ratio3))) :> /(4)*gain3),
    vgroup("4", par(i,4,os.saw3(freq4*(i+1)+(i*freq4*harm_ratio4))) :> /(4)*gain4)
);

filter_Q = hslider("[%0]Filter Q[style:knob]",60,0,20000,1) : si.smoo;
filter_TN = hslider("[%0]Filter TN[style:knob]",0.1,0,1,0.01) : si.smoo;

process = proc1 , proc2 :> /(4)*_adsr*main_gain : hgroup("Filter",fi.lptN(filter_Q,filter_TN));