import("stdfaust.lib");

//Param

Low_HNumber = nentry("h:Harmonics/v:Type/[0]Low Harmonics Num",0,0,2,1);
High_HNumber = nentry("h:Harmonics/v:Type/[1]High Harmonics Num",0,0,2,1);

L_Factor  = hslider("h:Harmonics/[0]Low Harmonics[style:knob]",2,1,2,0.125) : si.smoo; 
H_Factor = hslider("h:Harmonics/[1]High Harmonics[style:knob]",2,1,2,0.125) : si.smoo;
Main_Gain = hslider("h:Harmonics/[2]Main Gain[style:knob]", .5,0,1,0.01) : si.smoo;

_interpolation1 = nentry("v:Lfo's/Curve lfo 1",0,0,1,1);
_interpolation2 = nentry("v:Lfo's/Curve lfo 2",0,0,1,1);

lfo1_freq = hslider("v:Lfo's/h:Lfo 1/[0]lfo 1[style:knob]",2,0.1,20,0.1) : si.smoo;
xp_1 = hslider("v:Lfo's/h:Lfo 1/[1]Lfo1 Point X[style:knob]",0.5,0.01,0.99,0.01) : si.smoo;
yp_1 = hslider("v:Lfo's/h:Lfo 1/[2]Lfo1 Point Y[style:knob]",0.5,0.01,0.99,0.01) : si.smoo;
assg1_lfo1 = checkbox("v:Lfo's/h:Lfo 1/[3]Ratio1");
assg2_lfo1 = checkbox("v:Lfo's/h:Lfo 1/[4]Phase1");
assg3_lfo1 = checkbox("v:Lfo's/h:Lfo 1/[5]Gain1");

lfo2_freq = hslider("v:Lfo's/h:Lfo 2/[0]lfo 2[style:knob]",2,0.1,20,0.1) : si.smoo;
xp_2 = hslider("v:Lfo's/h:Lfo 2/[1]Lfo2 Point X[style:knob]",0.5,0.01,0.99,0.01) : si.smoo;
yp_2 = hslider("v:Lfo's/h:Lfo 2/[2]Lfo2 Point Y[style:knob]",0.5,0.01,0.99,0.01) : si.smoo;
assg1_lfo2 = checkbox("v:Lfo's/h:Lfo 2/[3]Ratio2");
assg2_lfo2 = checkbox("v:Lfo's/h:Lfo 2/[4]Phase2");
assg3_lfo2 = checkbox("v:Lfo's/h:Lfo 2/[5]Gain2");

//Delays
minDelay = ma.SR/1000;
maxDelay = ma.SR*2;

//Function to get values
f_window(el_ratio) = minDelay * 50 * el_ratio;
f_modfreq(el_ratio) = abs(1.0 - el_ratio) * ma.SR / f_window(el_ratio);
phaser1(modfreq) = os.phasor(1.0, modfreq);
f_second_phase(phase) = ma.frac(phase + 0.5);
phase_normalizer(el_ratio, phase) = ba.if(el_ratio >= 1.0, 1.0 - phase, phase);
crossfader(phase) = sin(ma.PI * phase) ^ 2;

//Pitch shift function
pitchShift(ratio, lfo1, lfo2, lfo3) =
    _ <: fixed * (ratio == 1.0), shifted * (ratio != 1.0) :> _
with {
    _ratio = ratio * lfo1;
    window = f_window(_ratio);
    modfreq = f_modfreq(_ratio)*lfo2;

    _p1 = phaser1(modfreq);
    _p2 = f_second_phase(_p1);
    p1 = phase_normalizer(_ratio,_p1);
    p2 = phase_normalizer(_ratio,_p2);

    d1 = minDelay + window * p1;
    d2 = minDelay + window * p2;
    w1 = crossfader(_p1);
    w2 = crossfader(_p2);

    fixed = de.fdelay(maxDelay, minDelay);
    shifted = (de.fdelay(maxDelay, d1) * w1),
              (de.fdelay(maxDelay, d2) * w2)
               :> *(lfo3);
};

//lfo tempo
lfo_tempo(freq) = (+(freq / ma.SR) : ma.frac) ~ _;

//Wave types
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

wave(t,xp,yp, curve) = linear_wave(t, xp, yp), curve_wave(t, xp, yp) : ba.selectn(2, curve);

lfo_1 = wave(lfo_tempo(lfo1_freq), xp_1,yp_1, _interpolation1);
lfo_2 = wave(lfo_tempo(lfo2_freq), xp_2,yp_2, _interpolation2);

Lfo_checker(box, lfo) = ba.if(box == 1, lfo, 1);

L1_ratio = 1/L_Factor;
L2_ratio = 1/(L_Factor*2);
H1_ratio = H_Factor;
H2_ratio = H_Factor*2;

L_harmonic1 = pitchShift(L1_ratio, 
    Lfo_checker(assg1_lfo1, lfo_1), Lfo_checker(assg2_lfo1, lfo_1), Lfo_checker(assg3_lfo1, lfo_1));
L_harmonic2 = pitchShift(L2_ratio, 
    Lfo_checker(assg1_lfo2, lfo_2), Lfo_checker(assg2_lfo2, lfo_2), Lfo_checker(assg3_lfo2, lfo_2));
H_harmonic1 = pitchShift(H1_ratio, 
    Lfo_checker(assg1_lfo1, lfo_1), Lfo_checker(assg2_lfo1, lfo_1), Lfo_checker(assg3_lfo1, lfo_1));
H_harmonic2 = pitchShift(H2_ratio, 
    Lfo_checker(assg1_lfo2, lfo_2), Lfo_checker(assg2_lfo2, lfo_2), Lfo_checker(assg3_lfo2, lfo_2));

L_process(choice) = 
    _ <: (L_harmonic1 : *(choice >= 1) : si.smoo), 
         (L_harmonic2 : *(choice == 2))
         :> _;
        

H_process(choice) =
    _ <: (H_harmonic1 : *(choice >= 1) : si.smoo),
         (H_harmonic2 : *(choice == 2))
      :> _;

dry_gate = (Low_HNumber == 0) * (High_HNumber == 0);

The_process = _ <: *(dry_gate), L_process(Low_HNumber), H_process(High_HNumber) :> _;

process = par(i, 2, The_process*Main_Gain) <: _, _ : effects;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);