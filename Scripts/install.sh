#!/bin/bash
#|---/ /+--------------------------+---/ /|#
#|--/ /-| Main installation script |--/ /-|#
#|-/ /--| Prasanth Rangan          |-/ /--|#
#|/ /---+--------------------------+/ /---|#

cat <<"EOF"

-----------------------------------------------------------------
        .                                                     
       / \         _       _  _                  _     _      
      /^  \      _| |_    | || |_  _ _ __ _ _ __| |___| |_ ___
     /  _  \    |_   _|   | __ | || | '_ \ '_/ _` / _ \  _(_-<
    /  | | ~\     |_|     |_||_|\_, | .__/_| \__,_\___/\__/__/
   /.-'   '-.\                  |__/|_|                       

-----------------------------------------------------------------

EOF


#--------------------------------#
# import variables and functions #
#--------------------------------#
scrDir=$(dirname "$(realpath "$0")")
source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi


#------------------#
# evaluate options #
#------------------#
flg_Install=0
flg_Restore=0
flg_Service=0

while getopts idrs RunStep ; do
    case $RunStep in
    i)  flg_Install=1 ;;
    d)  flg_Install=1 ; export use_default="--noconfirm" ;;
    r)  flg_Restore=1 ;;
    s)  flg_Service=1 ;;
    *)  echo "...valid options are..."
        echo "i : [i]nstall hyprland without configs"
        echo "d : install hyprland [d]efaults without configs --noconfirm"
        echo "r : [r]estore config files"
        echo "s : enable system [s]ervices"
        exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
    flg_Service=1
fi


#--------------------#
# pre-install script #
#--------------------#
if [ ${flg_Install} -eq 1 ] && [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"
                _         _       _ _ 
 ___ ___ ___   |_|___ ___| |_ ___| | |
| . |  _| -_|  | |   |_ -|  _| .'| | |
|  _|_| |___|  |_|_|_|___|_| |__,|_|_|
|_|                                   

EOF

    "${scrDir}/install_pre.sh"
fi


#------------#
# installing #
#------------#
if [ ${flg_Install} -eq 1 ] ; then
    cat <<"EOF"

 _         _       _ _ _         
|_|___ ___| |_ ___| | |_|___ ___ 
| |   |_ -|  _| .'| | | |   | . |
|_|_|_|___|_| |__,|_|_|_|_|_|_  |
                            |___|

EOF

    #----------------------#
    # prepare package list #
    #----------------------#
    shift $((OPTIND - 1))
    cust_pkg=$1
    cp "${scrDir}/custom_hypr.lst" "${scrDir}/install_pkg.lst"

       if [ -f "${cust_pkg}" ] && [ ! -z "${cust_pkg}" ] ; then
       cat "${cust_pkg}" >> "${scrDir}/install_pkg.lst"
    fi

    #--------------------------------#
    # add nvidia drivers to the list #
    #--------------------------------#
    if nvidia_detect ; then
        cat /usr/lib/modules/*/pkgbase | while read krnl; do
            echo "${krnl}-headers" >> "${scrDir}/install_pkg.lst"
        done
        IFS=$' ' read -r -d '' -a nvga < <(lspci -k | grep -E "(VGA|3D)" | grep -i nvidia | awk -F ':' '{print $NF}' | tr -d '[]()' && printf '\0')
        for nvcode in "${nvga[@]}"; do
           awk -F '|' -v nvc="${nvcode}" '{if ($3 == nvc) {split(FILENAME,driver,"/"); print driver[length(driver)],"\nnvidia-utils"}}' "${scrDir}"/.nvidia/nvidia*dkms >> "${scrDir}/install_pkg.lst"
        done
            fi

    echo -e "\033[0;32m[GPU]\033[0m detected // $dGPU"

    #----------------#
    # get user prefs #
    #----------------#
    if ! chk_list "aurhlpr" "${aurList[@]}" ; then
        echo -e "Available aur helpers:\n[1] yay\n[2] paru"
        prompt_timer 30 "Enter option number"

        case "${promptIn}" in
        1) export getAur="yay" ;;
        2) export getAur="paru" ;;
        *) echo -e "...Invalid option selected..." ; exit 1 ;;
        esac
    fi

    if ! chk_list "myShell" "${shlList[@]}" ; then
        echo -e "Select shell:\n[1] zsh\n[2] fish"
        prompt_timer 30 "Enter option number"

        case "${promptIn}" in
        1) export myShell="zsh" ;;
        2) export myShell="fish" ;;
        *) echo -e "...Invalid option selected..." ; exit 1 ;;
        esac
        echo "${myShell}" >> "${scrDir}/install_pkg.lst"
    fi

    #--------------------------------#
    # install packages from the list #
    #--------------------------------#
    "${scrDir}/install_pkg.sh" "${scrDir}/install_pkg.lst"
    rm "${scrDir}/install_pkg.lst"

fi


#---------------------------#
# restore my custom configs #
#---------------------------#
if [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"

             _           _         
 ___ ___ ___| |_ ___ ___|_|___ ___ 
|  _| -_|_ -|  _| . |  _| |   | . |
|_| |___|___|_| |___|_| |_|_|_|_  |
                              |___|

EOF

   "${scrDir}/restore_fnt.sh"
   "${scrDir}/restore_cfg.sh"
fi


#---------------------#
# post-install script #
#---------------------#
if [ ${flg_Install} -eq 1 ] && [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"

             _      _         _       _ _ 
 ___ ___ ___| |_   |_|___ ___| |_ ___| | |
| . | . |_ -|  _|  | |   |_ -|  _| .'| | |
|  _|___|___|_|    |_|_|_|___|_| |__,|_|_|
|_|                                       

EOF

    "${scrDir}/install_pst.sh"
fi


