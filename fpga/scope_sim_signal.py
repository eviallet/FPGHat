import math
import random

sample_count = 10
adc_count = 2
adc_data_bits = 10
adc_fs = 3.3

adc_noise_offset = 0.5
adc_noise_max_peak = 0.2

sim_end_rad = math.pi / 2


def gen_adc_val(adc, i):
    if adc == 0:
        return math.sin((i * sim_end_rad)/sample_count) * adc_fs
    else:
        return adc_noise_offset + random.random() * adc_noise_max_peak

for sample in range(sample_count+1):
    for adc in range(adc_count):
        val = gen_adc_val(adc, sample)
        lsb = (val / 3.3) * (2**adc_data_bits - 1)
        print(f'{int(lsb):0{adc_data_bits}b}', end = '' if adc == 0 else '\n')
