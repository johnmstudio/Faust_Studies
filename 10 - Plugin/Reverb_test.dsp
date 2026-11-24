import("stdfaust.lib");

_reverb = nentry("What Reverb",0,0,2,1);

MAXDELAY = 4096;
ND_1 = 4;
NB_1 = 3;

ND_2 = 8;
NB_2 = 6;

BBSO = 1;
_delay(ND, vals) = par(i, ND, hslider("Delay %i [style:knob]", ba.take(i+1, vals), 1, MAXDELAY-1, 1));
_freqs(NB, vals) = par(i, NB-1, hslider("Freq %i [unit:Hz][style:knob]", ba.take(i+1, vals), 20, 20000, 1));
_durs(NB, vals) = par(i,NB, hslider("dur %i [unit:s][style:knob]", ba.take(i+1, vals), 0.1, 10, 0.01));

loopgainmax = hslider("loop gain max[style:knob]", 0.8,0,1,0.01);
nonl = hslider("nonl[style:knob]", 0, 0, 1, 0.01);

del_vals_1 = (149, 211, 263, 293);
freq_vals_1 = (800, 4000);
durs_vals_1 = (2,2.5,3);
del_vals_2 = ((149, 211, 263, 293, 353, 427, 553, 647));
freq_vals_2 = (200, 800, 4000, 6000, 9000);
durs_vals_2 = (1.5,2,2.5,3,3,3.5);

fdnrev0_test1 = hgroup("Reverb1", re.fdnrev0(MAXDELAY, _delay(ND_1, del_vals_1), 
                BBSO, _freqs(NB_1, freq_vals_1), _durs(NB_1, durs_vals_1), loopgainmax, nonl));

fdnrev0_test2 = hgroup("Reverb2", re.fdnrev0(MAXDELAY, _delay(ND_2, del_vals_2), 
                BBSO, _freqs(NB_2, freq_vals_2), _durs(NB_2, durs_vals_2), loopgainmax, nonl));

dry = par(i, 2, *(_reverb == 0));
rev1 = si.bus(2) <: fdnrev0_test1 : par(i, ND_1, *(_reverb == 1));
rev2 = si.bus(2) <: fdnrev0_test2 : par(i, ND_2, *(_reverb == 2));

process = _, _ <: (dry, rev1, rev2) :> _, _ : effects;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);