#!/bin/bash
echo "actualizando sistema...."
if [ "$(whoami)" == "root" ]; then
    exit 1
fi
main(){
    clear
    echo "[+] iniciando menu..."
    sleep 1
    echo "1 -> Actualizar sistema e instalar requisitos"
    sleep 1
    echo -e "\n2 -> Instalar bspwm y sxhkd"
    sleep 1
    echo -e "\n3 -> Instalar configuración bspwm"
    sleep 1
    echo -e "\n4 -> Instalar polybar"
    sleep 1
    echo -e "\n5 -> Instalar todo"
    sleep 1
    echo -e "\n6 -> Salir"

    read -p $'\n-->> ' option

    case $option in
        1) req ;;
        2) bspwm ;;
        3) conf; polybar ;;  # Ejecuta dos funciones
        4) kitty ;;
        5) req; bspwm; conf; polybar ;;
        6) exit 0 ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
}
ruta=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
actualizacion(){
    echo "[+] Instalando requerimientos..."
    sudo pacman  -S --noconfirm sudo pacman -S libconfig-devel dbus-devel libev-devel libepoxy-devel pcre2-devel pixman-devel xorgproto libx11-devel libxcb-devel libxcb-composite-devel libxcb-damage-devel libxcb-glx-devel libxcb-image-devel libxcb-present-devel libxcb-randr-devel libxcb-render-devel libxcb-render-util-devel libxcb-shape-devel libxcb-xfixes-devel xcb-util-devel mesa-devel meson ninja uthash
    sudo pacman  -S --noconfirm base-devel git vim xcb-util xcb-util-wm xcb-util-keysyms xcb-util-xrm libxcb xorg-xrandr alsa-lib libxinerama
    sudo pacman -S --noconfirm bspwm kitty polybar rofi meson cmake libev uthash libepoxy pkgconf xorg-server xorg-xinit glfw-x11
    sudo pacman -S --noconfirm 7zip zsh neofetch
    sleep 2
    echo "[+] Requetimientos instalados correctamente"
}

bspwm(){
    mkdir -p ~/repos ~/.config/bspwm/scripts ~/.config/sxhkd ~/.config/polybar /usr/local/share/fonts
    cd ~/repos && git clone https://github.com/baskerville/bspwm.git
    cd ~/repos/bspwm && make && sudo make install
    cd ~/repos && git clone https://github.com/baskerville/sxhkd.git
    cd ~/repos/sxhkd && make && sudo make install
    cd ~/repos && git clone https://github.com/yshui/picom
    cd ~/repos/picom  && meson setup --buildtype=release build  && ninja -C build
    ninja -C build install
}
confBspwm(){
    cp $ruta/bspwmrc ~/.config/bspwm/
    cp $ruta/sxhkdrc ~/.config/sxhkd/
    cp $ruta/bspwm_resize ~/.config/bspwm/scripts/
    chmod +x ~/.config/bspwm/scripts/bspwm_resize
}
polybar() {
    # Definir rutas
    local fuente_zip="$ruta/recursos/Hack.zip"
    local destino_fuentes="/usr/local/share/fonts"

    # Verificar si existe el archivo ZIP
    if [ ! -f "$fuente_zip" ]; then
        echo "Error: El archivo $fuente_zip no existe"
        return 1
    fi

    # Verificar si 7z está instalado
    if ! command -v 7z &> /dev/null; then
        echo "Error: 7-Zip no está instalado. Instala con: sudo pacman -S p7zip"
        return 1
    fi

    # Copiar (en lugar de mover) y descomprimir
    sudo cp "$fuente_zip" "$destino_fuentes" && \
    sudo 7z x -o"$destino_fuentes" "$destino_fuentes/Hack.zip" && \
    sudo rm "$destino_fuentes/Hack.zip"

    # Actualizar caché de fuentes
    sudo fc-cache -f -v

    echo "[+] Fuentes Hack instaladas correctamente!"
    #configuracion de la kitty

}

kitty(){
    local fuente_zip="$ruta/recursos/kitty.txz"
    local destino_fuentes="/opt/kitty"
    sudo cp "$fuente_zip" "$destino_fuentes" && \
    sudo 7z x -o"$destino_fuentes" "$destino_fuentes/kitty.txz"  && \
    sudo rm -rf "$destino_fuentes/kitty.txz"
    sudo tar -xf "$destino_fuentes/kitty.tar"
}
main