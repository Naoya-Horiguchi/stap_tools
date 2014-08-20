while read name type deref ; do
    [ "$name" == "#" ] && continue
    echo ""
    echo "function ${name}:long (val:long) %{"
    echo "    STAP_RETVALUE = (long)((struct ${type} *)STAP_ARG_val)${deref};"
    echo "%}"
done <<EOF
page_flag     page             ->flags
vma_flag      vm_area_struct   ->vm_flags
vma_start     vm_area_struct   ->vm_start
vma_next      vm_area_struct   ->vm_next
vma_prev      vm_area_struct   ->vm_prev
vma_end       vm_area_struct   ->vm_end
vma_file      vm_area_struct   ->vm_file
vma_mm        vm_area_struct   ->vm_mm
walk_vma      mm_walk          ->vma
walk_skip     mm_walk          ->skip
walk_private  mm_walk          ->private
file_pos      file             ->f_pos
file_mapping  file             ->f_mapping
pm_pos        pagemapread      ->pos
vmf_pgoff     vm_fault         ->pgoff
vmf_vaddr     vm_fault         ->virtual_address
vmf_page      vm_fault         ->page
as_flags      address_space    ->flags
page_mapping  page             ->mapping
page_index    page             ->index
kiocb_file    kiocb            ->ki_filp
siginfo_no    siginfo          ->si_signo
siginfo_err   siginfo          ->si_errno
siginfo_code  siginfo          ->si_code
regs_ip       pt_regs          ->ip
regs_cs       pt_regs          ->cs
inode_blkbits inode            ->i_blkbits
iov_base      iovec            ->iov_base
iov_len       iovec            ->iov_len
filename_name filename         ->name
dentry_inode  dentry           ->d_inode
inode_mapping inode            ->i_mapping
bio_bi_end_io bio              ->bi_end_io
pgdat_start   pglist_data      ->node_start_pfn
pgdat_present pglist_data      ->node_present_pages
pgdat_spanned pglist_data      ->node_spanned_pages
pgdat_nodeid  pglist_data      ->node_id
ptn_addr      page_to_node     ->addr
EOF
