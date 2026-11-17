import("stdfaust.lib");

osc1 = os.osc(440);
gain1 = hslider("[%0]gain[style:knob]",0.5,0,1,0.1) : si.smoo;
lfo_freq = nentry("lfo",5,0,20,0.1);
lfo1 = os.lf_triangle(lfo_freq) : si.smoo;

lfo_amp = (lfo1 + 1) * 0.5;

process = osc1*gain1*lfo_amp <: _, _;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);