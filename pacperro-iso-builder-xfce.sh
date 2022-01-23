#!/usr/bin/bash

set -ex
#### Chroot qovluğu yaradaq
mkdir chroot || true

#### For debian
debootstrap --no-check-gpg --no-merged-usr --exclude=usrmerge --arch=amd64 testing chroot https://deb.debian.org/debian
echo "deb https://deb.debian.org/debian testing main contrib non-free" > chroot/etc/apt/sources.list

#### Şifrə
pass="9200"
echo -e "$pass\n$pass\n" | chroot chroot passwd

#### Fix apt & bind
#### apt sandbox user root
echo "APT::Sandbox::User root;" > chroot/etc/apt/apt.conf.d/99sandboxroot
for i in dev dev/pts proc sys; do mount -o bind /$i chroot/$i; done
chroot chroot apt-get install gnupg -y

#### Live açılış üçün lazımlı paketlər
chroot chroot apt-get dist-upgrade -y
chroot chroot apt-get install grub-pc-bin grub-efi-ia32-bin grub-efi -y
chroot chroot apt-get install live-config live-boot -y

#### Configure system
cat > chroot/etc/apt/apt.conf.d/01norecommend << EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

#### liquorix kernel
curl https://liquorix.net/liquorix-keyring.gpg | chroot chroot apt-key add -
echo "deb http://liquorix.net/debian testing main" > chroot/etc/apt/sources.list.d/liquorix.list
chroot chroot apt-get update -y
chroot chroot apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y

#### xorg & desktop
chroot chroot apt-get install xserver-xorg xinit -y

#### XFCE masaüstünü quraşdıraq
chroot chroot apt-get install xfce4 -y

#### Lightdm pəncərə idarəcisini quraşdıraq
chroot chroot apt-get install lightdm lightdm-gtk-greeter -y

#### Usefull stuff
chroot chroot apt-get install network-manager-gnome pavucontrol xterm -y

#### Programlar quraşdıraq
chroot chroot apt-get install mousepad -y
chroot chroot apt-get install pulseaudio -y
chroot chroot apt-get install gvfs-backends -y
chroot chroot apt-get install libmtp9 -y
chroot chroot apt-get install mtp-tools -y
chroot chroot apt-get install xfce4-xkb-plugin -y
chroot chroot apt-get install firefox-esr -y
chroot chroot apt-get install engrampa -y
chroot chroot apt-get install firefox-esr -y
chroot chroot apt-get install unzip -y
chroot chroot apt-get install zip -y
chroot chroot apt-get install make -y
chroot chroot apt-get install gettext -y
chroot chroot apt-get install xfce4-screenshooter -y
chroot chroot apt-get install xfce4-battery-plugin -y
chroot chroot apt-get install catfish -y
chroot chroot apt-get install lightdm-gtk-greeter-settings -y
chroot chroot apt-get install git -y
chroot chroot apt-get install pip -y
chroot chroot apt-get install gjs -y
chroot chroot apt-get install vokoscreen -y
chroot chroot apt-get install xfce4-whiskermenu-plugin -y
chroot chroot apt-get install xfce4-terminal -y
chroot chroot apt-get install mate-calc -y
chroot chroot apt-get install gnome-disk-utility -y
chroot chroot apt-get install gnome-pie -y
chroot chroot apt-get install bleachbit -y
chroot chroot apt-get install mugshot -y
chroot chroot apt-get install gnome-software -y
chroot chroot apt-get install blueman -y
chroot chroot apt-get install xfce4-statusnotifier-plugin -y
chroot chroot apt-get install ristretto -y

#### Datanı təmizləyək
chroot chroot apt-get clean
rm -f chroot/root/.bash_history
rm -rf chroot/var/lib/apt/lists/*
find chroot/var/log/ -type f | xargs rm -f

#### Squashfs yaradaq
mkdir -p pacperro/boot || true
while umount -lf -R chroot/{dev,dev/pts,proc,sys} 2>/dev/null ; do true; done
mksquashfs chroot filesystem.squashfs -comp gzip -wildcards
mkdir -p pacperro/live || true
ln -s live pacperro/casper || true
mv filesystem.squashfs pacperro/live/filesystem.squashfs

#### Kernel və initramfs'ı kopyalayaq
cp -pf chroot/boot/initrd.img-* pacperro/boot/initrd.img
cp -pf chroot/boot/vmlinuz-* pacperro/boot/vmlinuz

#### grub.cfg faylını yazdıraq
mkdir -p pacperro/boot/grub/
echo 'menuentry "PacPERRO Debian Xfce" --class pacperro {' > pacperro/boot/grub/grub.cfg
echo '    linux /boot/vmlinuz boot=live live-config --' >> pacperro/boot/grub/grub.cfg
echo '    initrd /boot/initrd.img' >> pacperro/boot/grub/grub.cfg
echo '}' >> pacperro/boot/grub/grub.cfg

#### Iso faylını yaradaq
grub-mkrescue pacperro -o PacPERRO-Debian-Xfce.iso


echo """

Proses Bitmişdir

"""
