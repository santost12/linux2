#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root!"
  exit
fi

install_samba() {
    apt install samba smbclient -y
}

make_local_groups() {
    local g_counter=1
    while [ $g_counter -lt 6 ]; do
        groupadd group$g_counter
        ((g_counter++))
    done
}

make_local_users() {
    local u_counter=1
    while [ $u_counter -lt 13 ]; do
        useradd -m user$u_counter -G group1 -s /bin/false -p "password1234"
        ((u_counter++))
    done
}

add_users_to_g1() {
    local u_counter=1
    while [ $u_counter -lt 13 ]; do
        gpasswd -a user$u_counter group1
        ((u_counter++))
    done
}

add_users_to_other_groups() {
    # USER1
    gpasswd -a user1 group2
    gpasswd -a user1 group5

    # USER2
    gpasswd -a user2 group2
    gpasswd -a user2 group5

    # USER3
    gpasswd -a user3 group2

    # USER4
    gpasswd -a user4 group2

    # USER5
    gpasswd -a user5 group3
    gpasswd -a user5 group5

    # USER6
    gpasswd -a user6 group3
    gpasswd -a user6 group5

    # USER7
    gpasswd -a user7 group3

    # USER8
    gpasswd -a user8 group3

    # USER9
    gpasswd -a user9 group4
    gpasswd -a user9 group5

    # USER10
    gpasswd -a user10 group4
    gpasswd -a user10 group5

    # USER11
    gpasswd -a user11 group4

    # USER12
    gpasswd -a user12 group4
}

add_samba_users() {
    local u_counter=1
    while [ $u_counter -lt 13 ]; do
        smbpasswd -n -a user$u_counter
        ((u_counter++))
    done
}

samba_password() {
    local u_counter=1
    while [ $u_counter -lt 13 ]; do
        printf "password1234\npassword1234\n" | smbpasswd -s user$u_counter
        ((u_counter++))
    done
}

create_share_folders() {
    if [ ! -d /samba ]; then
        mkdir -p /samba/shares && mkdir /samba/shares/{share1,share2,share3,share4,share5}
    fi
}

download_smbconfig() {
    echo "I can download a samba config for you."
    echo "See: https://github.com/santost12/linux2/blob/main/smb.conf"
    read -p "Is this okay? (y/n) " confirmation
    
    if [ $confirmation != "y" ]; then
        exit
    fi
    
    apt install curl -y
    curl https://raw.githubusercontent.com/santost12/linux2/main/smb.conf > /etc/samba/smb.conf
}

install_samba
make_local_groups
make_local_users
add_users_to_g1
add_users_to_other_groups
add_samba_users
samba_password
create_share_folders
download_smbconfig
