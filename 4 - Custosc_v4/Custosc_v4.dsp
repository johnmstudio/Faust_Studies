import("stdfaust.lib");

declare options "[midi:on][nvoices:6]";

// [HIDE] Root Parameters
freq = hslider("freq",200,50,12000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");

// Envelopes
att = hslider("[%0]Env att[style:knob]",0.2,0.001,12,0.01);
dec = hslider("[%0]Env dec[style:knob]",0.2,0.001,12,0.01);
sus = hslider("[%0]Env sus[style:knob]",0.8,0,1,0.01);
rel = hslider("[%0]Env rel[style:knob]",0.2,0.001,12,0.01);
_adsr = hgroup("Envelope",en.adsr(att,dec,sus,rel,gate))*gain;

main_gain = hslider("[%0]Main Gain[style:knob]",0.5,0,1,0.01);

// First Oscilator Parameters
freq_ratio1 = hslider("[%0]freq ratio 1[style:knob]",1,0.01,12,0.01);
freq1 = freq*freq_ratio1;
harm_ratio1 = hslider("[%0]harm ratio 1[style:knob]",1,0.01,6,0.01);
gain1 = hslider("[%0]gain 1[style:knob]",0.1,0,1,0.01);

// Second Oscilator Parameters
freq_ratio2 = hslider("[%0]freq ratio 2[style:knob]",1,0.01,12,0.01);
freq2 = freq*freq_ratio2;
harm_ratio2 = hslider("[%0]harm ratio 2[style:knob]",1,0.01,6,0.01);
gain2 = hslider("[%0]gain 2[style:knob]",0.1,0,1,0.01);

// Third Oscilator Parameters
freq_ratio3 = hslider("[%0]freq ratio 3[style:knob]",1,0.01,12,0.01);
freq3 = freq*freq_ratio3;
harm_ratio3 = hslider("[%0]harm ratio 3[style:knob]",1,0.01,6,0.01);
gain3 = hslider("[%0]gain 3[style:knob]",0.1,0,1,0.01);

// Fourth Oscilator Parameters
freq_ratio4 = hslider("[%0]freq ratio 4[style:knob]",1,0.01,12,0.01);
freq4 = freq*freq_ratio4;
harm_ratio4 = hslider("[%0]harm ratio 4[style:knob]",1,0.01,6,0.01);
gain4 = hslider("[%0]gain 4[style:knob]",0.1,0,1,0.01);

// Waveforms Algorythm
_waveform = nentry("Waveform[style:menu{'Sine':0;'Sawtooth':1;'Square':2;'Triangle':3}]",
    0,0,3,1);
harmonics(osc, f, hr) = par(i,4,osc(f*(i+1)+(i*f*hr*1))) :> _;
wave(wf, f, hr) = harmonics(os.oscsin, f, hr),
                  harmonics(os.sawtooth, f, hr),
                  harmonics(os.square, f, hr),
                  harmonics(os.triangle, f, hr) : ba.selectn(4,wf) : /(4);

wave_1 = wave(_waveform, freq1, harm_ratio1)*gain1;
wave_2 = wave(_waveform, freq2, harm_ratio2)*gain2;
wave_3 = wave(_waveform, freq3, harm_ratio3)*gain3;
wave_4 = wave(_waveform, freq4, harm_ratio4)*gain4;


// Grouping
grouping = vgroup("s1",
hgroup("1",wave_1),
hgroup("2",wave_2),
hgroup("3",wave_3),
hgroup("4",wave_4)
);

// Filters
filter_Q = hslider("[%0]Filter Q[style:knob]",60,0,20000,1) : si.smoo;
filter_TN = hslider("[%0]Filter TN[style:knob]",0.1,0,1,0.01) : si.smoo;

// Process
// process = wave_1 , wave_2 , wave_3 , wave_4 :> /(4)*_adsr*main_gain : /(4)*hgroup("Filter",fi.lptN(filter_Q,filter_TN)) :> _, _;
process = grouping :> /(4)*_adsr*main_gain :> hgroup("Filter",fi.lptN(filter_Q,filter_TN)) <: _, _;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);