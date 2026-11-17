import("stdfaust.lib");

osc1 = os.osc(440);
gain1 = hslider("[%0]gain[style:knob]",0.5,0,1,0.1)
lfo1 = os.lf_imptrain(nentry("lfo",5,0,20,0.1));

process = osc1*lfo1*gain1 <: _, _,;