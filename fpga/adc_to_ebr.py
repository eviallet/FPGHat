import math

# ADC
full_scale = 3.3 # V
n = 10 # bits
lsb = full_scale / 2**n # 3.2 mV

# EBR
block_width = 64 # 64 hex chars
block_height = 16
ram_size = block_width * block_height * 4

# Segments
seg_length = 16 # 00xx . yyyy zzzz wwww
values_count = ram_size/seg_length

# Fill blocks
max_disp = math.ceil(full_scale*1000)
step = math.ceil(max_disp / values_count)

blocks = [['0000' for _ in range(int(block_width/4))] for _ in range(block_height)]
block_idx = 0
block_col = 0
for i in range (0, max_disp+step, step):
    as_str    = f'{i/1000:.3f}'
    int_part  = f'{int(as_str[0]):x}'
    # as_str[1] = .
    dec_part1 = f'{int(as_str[2]):x}'
    dec_part2 = f'{int(as_str[3]):x}'
    dec_part3 = f'{int(as_str[4]):x}'
    as_hex    = f'{int_part}{dec_part1}{dec_part2}{dec_part3}'
    print(f'{as_str} => {as_hex}')

    blocks[block_idx][block_col] = as_hex
    block_col += 1

    if block_col == block_width/4:
        block_col = 0
        block_idx += 1

blocks_used = block_idx + (0 if block_col == 0 else 1)
bits_used = block_width * 4 * block_idx + (block_height - block_col) * 4
print(f'{bits_used*100/ram_size:.1f}% of 1 block ram')
print(f'{step/1000} V displayed lsb, {math.floor(max_disp/step)} possible values')

# Blocks to vhdl
blocks_str = ''

for block_idx, block_row in enumerate(blocks):
    blocks_str += f'            INIT_{hex(block_idx)[-1].upper()} => X"'
    blocks_str += ''.join(block_row[::-1])
    blocks_str += '",\n'

print(blocks_str)

# with open("tmp.vhd", 'w') as file:
#     file.write(f"""
#     ram_inst : SB_RAM2048x2
#         generic map (
# {blocks_str}
#         )
#         port map (
#             RDATA => RDATA_c,
#             RADDR => RADDR_c,
#             RCLK => RCLK_c,
#             RCLKE => RCLKE_c,
#             RE => RE_c,
#             WADDR => open,
#             WCLK => open,
#             WCLKE => open,
#             WDATA => open,
#             WE => '0'
#     );  
# """)
