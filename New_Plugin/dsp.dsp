declare name "MyProgram";
declare author "MySelf";
declare copyright "MyCompany";
declare version "1.00";
declare license "BSD"; 

import("stdfaust.lib");



sin_osc = os.osc(440);
saw_osc = os.saw2(440);
square_osc = os.square(440);
triangle_osc = os.triangle(440);
gain = hslider("gain",0.5,0,1,0.01) : si.smoo;
_waveform = nentry("Waveform[style:menu{'Sine':0;'Sawtooth':1;'Square':2;'Triangle':3}]",
 0, 0, 3, 1);

oscillator = sin_osc, saw_osc, square_osc, triangle_osc : ba.selectn(4, _waveform);

process = oscillator * gain <: _, _;