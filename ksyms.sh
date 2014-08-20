getsymaddr() { grep " $1$" /proc/kallsyms | cut -f1 -d' '; }

NODE_DATA_ADDR=0x$(getsymaddr node_data)
HSTATES_ADDR=0x$(getsymaddr hstates)
MEMBLOCK_ADDR=0x$(getsymaddr memblock)
MAXPFN_ADDR=0x$(getsymaddr max_pfn)
