#!/bin/bash
echo "actualizando sistema...."
if [ "$(whoami)" == "root" ]; then
    exit 1
fi
ruta=$(pwd)
pacman -Syu --noconfirm
sudo pacman -S --noconfirm sudo pacman -S libconfig-devel dbus-devel libev-devel libepoxy-devel pcre2-devel pixman-devel xorgproto libx11-devel libxcb-devel libxcb-composite-devel libxcb-damage-devel libxcb-glx-devel libxcb-image-devel libxcb-present-devel libxcb-randr-devel libxcb-render-devel libxcb-render-util-devel libxcb-shape-devel libxcb-xfixes-devel xcb-util-devel mesa-devel meson ninja uthash
sudo pacman -S --noconfirm base-devel git vim xcb-util xcb-util-wm xcb-util-keysyms xcb-util-xrm libxcb xorg-xrandr alsa-lib libxinerama
sudo pacman -S --noconfirm bspwm kitty polybar rofi

mkdir ~/.config/{bspwm,sxhkd}
mkdir -p ~/.config/bspwm/scripts
cp $ruta/bspwm_resize ~/.config/bspwm/scripts || chmod +x bspwm_resize


mkdir ~/repos
cd ~/repos || git clone https://aur.archlinux.org/yay.git
cd yay || makepkg -si --noconfirm

cd ~/repos || git clone https://github.com/baskerville/bspwm.git
cd ~/repos/bspwm || make ; sudo make install
git clone https://github.com/baskerville/sxhkd.git
cd ~/repos/sxhkd || make ;sudo make install

#instalacion de picom
cd ~/repos || git clone https://github.com/yshui/picom
cd picom  || meson setup --buildtype=release build  || ninja -C build
ninja -C build install
