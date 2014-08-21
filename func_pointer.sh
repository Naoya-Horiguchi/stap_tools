#
# For example if you like to use a kernel internal function func()
# which is declared as
#
#   unsigned long kfunc(int a, struct str *ptr);
#
# , you should call like this:
#   
#   define_kernel_internal_function "unsigned long kfunc(int a, struct str *ptr)"
#
# Then the kenrel function will be available as _stp_kfunc().
#
define_kernel_internal_function() {
    local template="$1"
    local fname=$(echo "$1" | ruby -ne 'puts $_.gsub(/.*?(\w+)\(.*/, "\\1")')

    local left=$(echo $template | sed -e "s/\($fname\)/(*_stp_\1)/")
    local right=$(echo $template | sed -e "s/\($fname\)/(*)/")
    echo "%{ static $left = ($right)0x$(getsymaddr $fname); %}"
}
