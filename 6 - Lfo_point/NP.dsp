import("stdfaust.lib");

lfo_freq = hslider("[%0]lfo[style:knob]",2,0.1,20,0.1);

xp = hslider("[%0]Point X[style:knob]",0.5,0.01,0.99,0.01);
yp = hslider("[%0]Point Y[style:knob]",0.5,0.01,0.99,0.01);

phase = (+(lfo_freq / ma.SR)) ~ _;
t = phase - floor(phase);

wave(t, xp, yp) =
    ba.if(
        t <= xp,
        (t/xp)*yp,
        ((1-t)/(1-xp))*yp
    );

osc1 = os.osc(440);
gain1 = hslider("[%0]gain[style:knob]",0.5,0,1,0.1) : si.smoo;
lfo1 = os.lf_triangle(lfo_freq) : si.smoo;

lfo_amp = (wave(t,xp,yp) + 1) * 0.5;

process = osc1*gain1*lfo_amp <: _, _;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);