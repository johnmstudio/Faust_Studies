import("stdfaust.lib");

btn = button("gate");
_adsr = en.adsr(0.05,1,0.8,0,btn);

process = os.osc(440)*_adsr <: _, @(22050) : _, _;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);
