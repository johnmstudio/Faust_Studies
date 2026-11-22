import("stdfaust.lib");

lfo_freq = hslider("[%0]lfo[style:knob]",2,0.1,20,0.1);

xp = hslider("[%0]Point X[style:knob]",0.5,0.01,0.99,0.01);
yp = hslider("[%0]Point Y[style:knob]",0.5,0.01,0.99,0.01);

phase = (+(lfo_freq / ma.SR)) ~ _;
t = phase - floor(phase);

linear_wave(t, xp, yp) =
    ba.if(
        t <= xp,
        (t/xp)*yp,
        ((1-t)/(1-xp))*yp
    );
curve_wave(t, xp, yp) =
    ba.if(
        t <= xp,
        yp*(1-cos(ma.PI*(t/xp))) / 2,
        yp-yp*(1-cos(ma.PI*((t-xp)/(1-xp)))) / 2
    );

_interpolation = nentry("[%0]Interpolation[style:menu{'Linear':0;'Curve':1}]",0,0,1,1);
wave = linear_wave(t, xp, yp), curve_wave(t, xp, yp) : ba.selectn(2, _interpolation);

osc_freq = hslider("[%0]osc freq[style:knob]", 440, 20, 16000, 1);
step = 1 + (osc_freq / 16000) * 99;
osc1 = os.osc(floor(osc_freq / step) * step);

gain1 = hslider("[%0]gain[style:knob]",0.5,0,1,0.1) : si.smoo;
// lfo1 = os.lf_triangle(lfo_freq) : si.smoo;

lfo_amp = wave;

process = osc1*gain1*lfo_amp <: _, _;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);