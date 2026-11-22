import("stdfaust.lib");

//Param
L_Factor = hslider("[%0]Low Harmonics[style:knob]",2,1,2,0.125) : si.smoo;
H_Factor = hslider("[%0]High Harmonics[style:knob]",2,1,2,0.125) : si.smoo;
Main_Gain = hslider("[%0]Main Gain[style:knob]", .5,0,1,0.01) : si.smoo;

f_window(ratio) = minDelay * 50 * ratio;
minDelay = ma.SR/100;
maxDelay = ma.SR*2;

f_modfreq(ratio) = abs(1.0 - ratio) * ma.SR / window(ratio);

phaser1(modfreq) = os.phasor(1.0, modfreq);
f_second_phase(phase) = ma.frac(phase + 0.5);

phase_normalizer(phase) = ba.if(ratio >= 1.0, 1.0 - phase, phase);
crossfader(phase) = sin(ma.PI * phase) ^ 2;

pitchShift(x, ratio, lfo1, lfo2, lfo3) =
    ba.if(ratio == 1.0, fixed, shifted)
with {
    fixed = x : de.fdelay(maxDelay, minDelay);

    ratio = ratio*lfo1;
    window = f_window(ratio);
    modfreq = f_modfreq(ratio)*lfo2;

    _p1 = phaser1(modfreq);
    _p2 = f_second_phase(_p1);
    p1 = phase_normalizer(_p1);
    p2 = phase_normalizer(_p2);

    d1 = minDelay + window * p1;
    d2 = minDelay + window * p2;
    w1 = crossfader(phase);
    w2 = f_second_phase(w2);

    shifted = (y1 * w1 + y2 * w2)*lfo3;

    y1 = x : de.fdelay(maxDelay, d1);
    y2 = x : de.fdelay(maxDelay, d2);
};

//Param
lfo1_freq = hslider("[%0]lfo[style:knob]",2,0.1,20,0.1);
lfo2_freq = hslider("[%0]lfo[style:knob]",2,0.1,20,0.1);
lfo3_freq = hslider("[%0]lfo[style:knob]",2,0.1,20,0.1);

1_xp = hslider("[%0]Lfo1 Point X[style:knob]",0.5,0.01,0.99,0.01);
1_yp = hslider("[%0]Lfo1 Point Y[style:knob]",0.5,0.01,0.99,0.01);

2_xp = hslider("[%0]Lfo2 Point X[style:knob]",0.5,0.01,0.99,0.01);
2_yp = hslider("[%0]Lfo2 Point Y[style:knob]",0.5,0.01,0.99,0.01);

lfo_tempo(freq) = phase - floor(phase) with{
    (phase = +(freq / ma.SR)) ~ _;
}

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
wave(t,xp,yp) = linear_wave(t, xp, yp), curve_wave(t, xp, yp) : ba.selectn(2, _interpolation);

assg1_lfo1 = checkbox("Ratio");
assg2_lfo1 = checkbox("Phase");
assg3_lfo1 = checkbox("Gain");
assg1_lfo2 = checkbox("Ratio");
assg2_lfo2 = checkbox("Phase");
assg3_lfo2 = checkbox("Gain");

Lfo_checker(box, lfo) = ba.if(box == true, lfo, 1);

Low_HNumber = nentry("Low Harmonics",0,0,2,1 );
High_HNumber = nentry("High Harmonics",0,0,2,1 );

group_1 = hgroup("Harmonics",
    vgroup("Type", Low_HNumber, High_HNumber), L_Factor, H_Factor, Main_Gain
);
group_2 = vgroup("LFO's",
    hgroup("Lfo 1", 1_xp,1_yp,assg1_lfo1,assg1_lfo2,assg1_lfo3),
    hgroup("Lfo 2", 2_xp,2_yp,assg2_lfo1,assg2_lfo2,assg2_lfo3),
);

L1_ratio = L_Factor;
L2_ratio = L1_ratio*2;
H1_ratio = H_Factor;
H2_ratio = L2_ratio*2;

L_harmonic1 = pitchShift(_,L1_ratio, 
    Lfo_checker(assg1_lfo1), Lfo_checker(assg1_lfo2), Lfo_checker(assg1_lfo3));
L_harmonic2 = pitchShift(_,L2_ratio, 
    Lfo_checker(assg2_lfo1), Lfo_checker(assg2_lfo2), Lfo_checker(assg2_lfo3));
H_harmonic1 = pitchShift(_,H1_ratio, 
    Lfo_checker(assg1_lfo1), Lfo_checker(assg1_lfo2), Lfo_checker(assg1_lfo3));
H_harmonic2 = pitchShift(_,H2_ratio, 
    Lfo_checker(assg2_lfo1), Lfo_checker(assg2_lfo2), Lfo_checker(assg2_lfo3));

L_process(choice) = 
    ba.if(choice == 0, _,
         ba.if(choice == 1, L_harmonic1, 
            ( _ <: L_harmonic1, L_harmonic2) :> _
        )
    );
H_process(choice) = 
    ba.if(choice == 0, _,
         ba.if(choice == 1, H_harmonic1, 
            ( _ <: H_harmonic1, L_harmonic2) :> _
        )
    );

The_process = L_process(Low_HNumber), H_process(High_HNumber) :> _;

process = The_process, The_process;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);

