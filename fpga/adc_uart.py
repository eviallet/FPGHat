from serial import Serial

ser = Serial('/dev/ttyUSB1', baudrate=115200)

full_scale = 3.3
n = 10
lsb = full_scale/(2**n)

while True:
    if ser.in_waiting > 0:
        rcv = ser.read(1)[0]
        bits = (f'{rcv:08b}')
        volts = lsb * int(bits, base=2) * 4
        print(f'{bits = } - {volts = :.3f}')

