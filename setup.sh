#!/bin/bash

set -xe

FINAL_STAGE=13
ASLR_ON="11"
FIRST_PASSWORD="bof1"
PASSWORDS_FILE="PASSWORDS"
if [[ $UID == 0 ]]; then
    SUDO=""
else
    SUDO="sudo "
fi

setting_ctf() {
    USER="bof$1"
    # set password
    echo "$USER:$2" | $SUDO chpasswd
    if [[ $1 != $FINAL_STAGE ]]; then
        PWN="bof$(($1 + 1))"
        BIN="/home/$USER/$USER"
        SRC="/home/$USER/$USER.c"
        $SUDO cp _$USER /home/$USER/$USER
        $SUDO cp _$USER.c /home/$USER/$USER.c
        $SUDO cp $USER.hint /home/$USER/$USER.hint
        $SUDO chown $PWN:$PWN $BIN
        $SUDO chmod 6555 $BIN
        $SUDO chown root:root $SRC
        $SUDO chmod 644 $SRC
        if [[ ! -f /tmp/gdbinit-gef.py ]]; then
            wget -O /tmp/gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
        fi
        $SUDO echo "source /tmp/gdbinit-gef.py" > /home/$USER/.gdbinit
        $SUDO chown $USER:$USER /home/$USER/.gdbinit
        if [[ -f ~/.tmux.conf ]]; then
            $SUDO cp ~/.tmux.conf /home/$USER/
            $SUDO chown $USER:$USER /home/$USER/.tmux.conf
        fi
        $SUDO cp aslr /home/$USER/.aslr
        $SUDO chown root:root /home/$USER/.aslr
        $SUDO chmod 4775 /home/$USER/.aslr
        if [[ $1 -lt ASLR_ON ]]; then
            echo "/home/$USER/.aslr 0 2>&1 > /dev/null" | $SUDO tee /home/$USER/.bashrc
        else
            echo "/home/$USER/.aslr 2 2>&1 > /dev/null" | $SUDO tee /home/$USER/.bashrc
        fi
        $SUDO echo "export LANG=en_US.UTF-8" >> /home/$USER/.bashrc
        if [[ $1 == 10 || $1 == 12 ]]; then
            POC="exp_$USER.py"
            $SUDO cp $POC /home/$USER
            $SUDO chown $USER:$USER /home/$USER/$POC
        fi
    else
        echo "R=\"\e[1;31m\"
C=\"\e[1;36m\"
E=\"\e[0m\"
echo -e \$R \"Congratulations!\"
echo -e \$C \"You solved all BOF CTFs.\" \$E
function pause(){
    read -p \"\$*\"
}
pause 'Press [Enter] to exit...'
exit" | $SUDO tee /home/$USER/.bashrc
    fi
}

cleanup(){
    make clean
    rm $PASSWORDS_FILE
    for ((i=1; i<=$FINAL_STAGE; i++)); do
        $SUDO userdel bof$i
        $SUDO rm -rf /home/bof$i
        rm -rf _bof$i.c
    done
}

compile() {
    distro=$(cat /etc/os-release | grep "^ID=" | cut -d\= -f2 | sed -e 's/"//g')
    case "$distro" in
    "ubuntu")
        $SUDO apt-get -y -qq install gcc-multilib
        ;;
    "arch")
        LIB32="lib32-gcc-libs"
        if ! pacman -Qi $LIB32>/dev/null; then
            $SUDO pacman -S --noconfirm $LIB32
        fi
        ;;
    esac
    if ! make; then
        echo "compile fail"
        exit 1
    fi
}

setup_ctf() {
    echo "PASSWORD LIST of ALL bof USERs" > $PASSWORDS_FILE
    for ((i=1; i<=$FINAL_STAGE; i++)); do
        if [[ $i == "1" ]]; then
            # The password of first level is "bof1"
            PASSWORD=$FIRST_PASSWORD
        else
            # create random password (The flag is password file.)
            PASSWORD=$(cat /dev/urandom | xxd -l 4 -p)
            PW_FILE="bof$i.pw"
            echo $PASSWORD > $PW_FILE
            $SUDO mv $PW_FILE /home/bof$((i - 1))
            FLAG=/home/bof$((i - 1))/$PW_FILE
            $SUDO chown root:bof$i $FLAG
            $SUDO chmod 440 $FLAG
        fi
        echo -e "bof$i\t$PASSWORD" >> $PASSWORDS_FILE
        # setting CTFs(adding user, copying files, setting authority)
        setting_ctf $i $PASSWORD
    done
}

main(){
    case "$1" in
    --remove)
        cleanup
        ;;
    *)
        #
        # Create users
        #
        for ((i=1; i<=$FINAL_STAGE; i++)); do
            $SUDO useradd -m -d /home/bof$i -s $(which bash) bof$i
            # Assign uid of created user to the source code
            if [[ $i != "1" ]]; then
                _UID=$(cat /etc/passwd | grep "bof$i:" | cut -d ':' -f3)
                if [[ $i != "11" ]]; then
                    sed 's/UID_BOF'$i'/'$_UID'/g' bof$((i - 1)).c > _bof$((i - 1)).c
                else
                    mv bof$((i - 1)).c _bof$((i - 1)).c
                fi
            fi
        done
        #
        # Compile
        #
        compile
        #
        # Create flag files (which contain password for next stage)
        #
        setup_ctf
    ;;
    esac
}

main $@
