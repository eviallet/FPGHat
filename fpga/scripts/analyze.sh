files=$(python -c "import os; print(' '.join([x for x in os.listdir() if x.endswith('.vhd') and '_tb' not in x and x != 'top.vhd'] + ['top.vhd']))")
ghdl -a --workdir=build/work $files top.vhd