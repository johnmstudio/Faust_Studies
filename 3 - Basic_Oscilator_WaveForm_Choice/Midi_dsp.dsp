declare name "MyProgram";
declare author "MySelf";
declare copyright "MyCompany";
declare version "1.00";
declare license "BSD"; 
declare options "[midi:on][nvoices:6]";

import("stdfaust.lib");

// Root Parameters [HIDE]
freq = hslider("freq",200,50,12000,0.01);
_gain = hslider("the gain",0.5,0,1,0.01);
gate = button("gate");


// Envelope Parameters
att = hslider("[%0]Attack[style:knob]",0.2,0.001,12,0.01);
dec = hslider("[%0]Decay[style:knob]",0.2,0.001,12,0.01);
sus = hslider("[%0]Sustain[style:knob]",0.8,0.001,1,0.01);
rel = hslider("[%0]Release[style:knob]",0.2,0.001,12,0.01);
_envelope = hgroup("Envelope", en.adsr(att,dec,sus,rel,gate))* (_gain : si.smoo);

// waveforms
sin_osc = os.osc(freq);
saw_osc = os.saw2(freq);
square_osc = os.square(freq);
triangle_osc = os.triangle(freq);
_waveform = nentry("Waveform[style:menu{'Sine':0;'Sawtooth':1;'Square':2;'Triangle':3}]",
 0, 0, 3, 1);

// Oscilator
oscillator = sin_osc, saw_osc, square_osc, triangle_osc <: ba.selectn(4, _waveform);

process = oscillator*_envelope*_gain <: _, _;
master = hslider("[1]Master", 0.5, 0, 1, 0.01) : si.smoo;
effect = co.limiter_1176_R4_stereo : *(master), *(master);