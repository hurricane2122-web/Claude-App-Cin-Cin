import wave, struct, math

def generate_cincin(filename):
    framerate = 44100
    duration = 1.5
    nframes = int(framerate * duration)

    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(framerate)

        frames = []
        for i in range(nframes):
            t = i / framerate

            if t < 0.01:
                env = t / 0.01
            else:
                env = math.exp(-2.5 * (t - 0.01))

            sample = (
                0.5 * math.sin(2 * math.pi * 1047 * t) +
                0.25 * math.sin(2 * math.pi * 2094 * t) +
                0.15 * math.sin(2 * math.pi * 3136 * t) +
                0.10 * math.sin(2 * math.pi * 4186 * t)
            )

            val = int(sample * env * 16000)
            val = max(-32767, min(32767, val))
            frames.append(struct.pack('<h', val))

        f.writeframes(b''.join(frames))

generate_cincin('assets/sounds/cincin.wav')
print("cincin.wav generato!")
