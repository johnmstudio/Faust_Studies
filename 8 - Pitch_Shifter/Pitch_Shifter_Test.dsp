import("stdfaust.lib");

// Controles
ratio = hslider("Ratio", 1.0, 0.25, 4.0, 0.01) : si.smoo;
minDelay = hslider("Valor delay mínimo", 48.0, 32.0, 64.0, 8.0);

// Configurações
window = minDelay * 50 * ratio;
maxDelay = ma.SR * 2;

// Velocidade do ciclo de leitura
modFreq = abs(1.0 - ratio) * ma.SR / window;

// Fases dos dois cabeçotes
phase = os.phasor(1.0, modFreq);
phase2 = ma.frac(phase + 0.5);

// Posições normalizadas
p1 = ba.if(ratio >= 1.0, 1.0 - phase, phase);
p2 = ba.if(ratio >= 1.0, 1.0 - phase2, phase2);

// Tempos de delay em samples
d1 = minDelay + window * p1;
d2 = minDelay + window * p2;

// Crossfade
w1 = sin(ma.PI * phase) ^ 2;
w2 = sin(ma.PI * phase2) ^ 2;

// Pitch Shifter
pitchShift(x) =
    ba.if(ratio == 1.0, fixed, shifted)
with {
    fixed = x : de.fdelay(maxDelay, minDelay);

    shifted = y1 * w1 + y2 * w2;

    y1 = x : de.fdelay(maxDelay, d1);
    y2 = x : de.fdelay(maxDelay, d2);
};

// Entrada estéreo
process = pitchShift, pitchShift;