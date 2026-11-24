import("stdfaust.lib");
/*
re = library("reverbs.lib");
os = library("oscillators.lib");
ba = library("basics.lib");
ma = library("maths.lib");
no = library("noises.lib");
*/

_gate = button("gate");
_adsr = en.adsr(.01,.6,0,.4,_gate);
_reverb = nentry("What Reverb",0,0,2,1);

MAXDELAY = 4096;
ND_1 = 4;
NB_1 = 3;

ND_2 = 8;
NB_2 = 6;
BBSO = 1;
_delay(ND) = par(i, ND, hslider("Delay %i [unit:Hz][style:knob]", ba.take(i+1, (149,211,263,293)), 1, MAXDELAY-1, 1));
_freqs(NB) = par(i, NB-1, hslider("Freq %i [unit:s][style:knob]", ba.take(i+1, (800, 4000)), 20, 20000, 1));
_durs(NB) = par(i,NB, hslider("dur %i [unit:s][style:knob]", ba.take(i+1, (1.5,2.0,2.5)), 0.1, 10, 0.01));
loopgainmax = hslider("loop gain max[style:knob]", 0.8,0,1,0.01);
nonl = hslider("nonl[style:knob]", 0, 0, 1, 0.01);

// input = (os.osc(220), os.osc(330), os.osc(440), os.osc(550)) : par(i, 4, *(_adsr));
fdnrev0_test1 = re.fdnrev0(MAXDELAY, _delay(ND_1), BBSO, _freqs(NB_1), _durs(NB_1), loopgainmax, nonl);

fdnrev0_test2 = re.fdnrev0(MAXDELAY, _delay(ND_2), BBSO, _freqs(NB_2), _durs(NB_2), loopgainmax, nonl);


/*
fdnrev0_slider_test = (os.tosc(220), os.tosc(330), os.tosc(440), os.tosc(550)) <: 
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (hslider("fdnrev0:f1", 800, 50, 5000, 1), 
  hslider("fdnrev0:f2", 4000, 100, 10000, 1)), (hslider("fdnrev0:t60high", 1.5, 0.1, 10, 0.01), 
  hslider("fdnrev0:t60mid", 2.0, 0.1, 10, 0.01), hslider("fdnrev0:t60low", 2.5, 0.1, 10, 0.01)), 
  hslider("fdnrev0:loopgainmax", 0.8, 0, 1, 0.01), hslider("fdnrev0:nonl", 0.0, 0, 0.999, 0.001));

fdnrev0_modulated_test = par(i, 4, no.noises(4, i)) <: 
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (800, 4000), (1.5, 0.5*pow(10, tri), 2.5), 0.8, 0.0) with { 
    P = int(ma.SR/10); tri = 1 - abs(2*ba.period(P)/P - 1); };

fdnrev0_jump_test = par(i, 4, no.noises(4, i)) <: 
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (800, 4000), (1.5, 0.5*pow(10, sq), 2.5), 0.8, 0.0) with { 
    P = int(ma.SR/10); sq = ba.period(2*P) < P; };

fdnrev0_nonl_test = no.multinoise(4) :
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (800, 4000), (1.5, 2.0, 2.5), 0.8, 0.2);

fdnrev0_nonl_slider_test = no.multinoise(4) :
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (800, 4000), (1.5, 2.0, 2.5), 0.8, 
  hslider("fdnrev0:nonl", 0.2, -0.999, 0.999, 0.001));

fdnrev0_nonl_modulated_test = no.multinoise(4) : 
  re.fdnrev0(4096, (149, 211, 263, 293), 1, (800, 4000), (1.5, 2.0, 2.5), 0.8, 0.4*tri - 0.2) with { 
    P = int(ma.SR/10); tri = 1 - abs(2*ba.period(P)/P - 1); };
*/

dry = input : par(i, 2, *(_reverb == 0));
wet = fdnrev0_test1,fdnrev0_test2 : par(i,4,*(_reverb == 1)), par(i,4,*(_reverb == 2));

process = _, _ <: (dry,wet) :> _, _ : effects;
master = hslider("[1]Master", 0.5,0,1,0.01) : si.smoo;
effects = co.limiter_1176_R4_stereo : *(master), *(master);
