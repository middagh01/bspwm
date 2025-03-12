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
        #5) req; bspwm; conf; polybar ;;
        5) picom ;;
        7) zsh ;;
        6) exit 0 ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
}
ruta=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
req(){
    echo "[+] Instalando requerimientos..."
    sudo pacman  -S --noconfirm sudo pacman -S libconfig-devel dbus-devel libev-devel libepoxy-devel pcre2-devel pixman-devel xorgproto libx11-devel libxcb-devel libxcb-composite-devel libxcb-damage-devel libxcb-glx-devel libxcb-image-devel libxcb-present-devel libxcb-randr-devel libxcb-render-devel libxcb-render-util-devel libxcb-shape-devel libxcb-xfixes-devel xcb-util-devel mesa-devel meson ninja uthash
    sudo pacman  -S --noconfirm base-devel git vim xcb-util xcb-util-wm xcb-util-keysyms xcb-util-xrm libxcb xorg-xrandr alsa-lib libxinerama
    sudo pacman -S --noconfirm bspwm kitty polybar rofi meson cmake libev uthash libepoxy pkgconf xorg-server xorg-xinit glfw-x11
    sudo pacman -S --noconfirm 7zip zsh neofetch imagemagick bat feh firefox zsh-autocomplete zsh-autosuggestions zsh-zyntax-highlighting brightnessctl    
    sleep 2
    echo "[+] Requetimientos instalados correctamente"
}

bspwm(){
    mkdir -p ~/repos ~/.config/bspwm/scripts ~/.config/sxhkd ~/.config/polybar ~/.config/picom
    sudo mkdir -p /usr/local/share/fonts
    sudo mkdir -p /opt/image /root/.config/kitty
    sudo mkdir -p /usr/share/fonts/truetype/
    cd ~/repos && git clone https://github.com/baskerville/bspwm.git
    cd ~/repos/bspwm && make && sudo make install
    cd ~/repos && git clone https://github.com/baskerville/sxhkd.git
    cd ~/repos/sxhkd && make && sudo make install
    cd ~/repos && git clone https://github.com/yshui/picom
    cd ~/repos/picom  && meson setup --buildtype=release build  && ninja -C build
    ninja -C build install
}
conf(){
    cp "$ruta/bspwmrc" "$HOME/.config/bspwm/"
    cp "$ruta/sxhkdrc" "$HOME/.config/sxhkd/"
    cp "$ruta/bspwm_resize" "$HOME/.config/bspwm/scripts/"
    chmod +x ~/.config/bspwm/scripts/bspwm_resize
    chmod +x ~/.config/bspwm/bspwmrc
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

kitty() {
    #configuracion de polybar
    local repo_polybar="$HOME/repos/blue-sky/polybar"
    local config_polybar="$HOME/.config/polybar"
    cd ~/repos && git clone https://github.com/VaughnValle/blue-sky.git

    if [ -d "$repo_polybar" ]; then
        echo "Copiando configuración desde el repositorio..."
        mkdir -p "$config_polybar"
        cp -r "$repo_polybar"/* "$config_polybar"
    else
        echo "Error: Repositorio no encontrado en $repo_polybar"
        exit 1
    fi

    # 1. Definir rutas
    local fuente_txz="$ruta/kitty/kitty.txz"
    local destino="/opt/kitty"
    local fonds="$HOME/repos/blue-sky/polybar/"
    local fondsfin="/usr/share/fonts/truetype/"

    local img="$ruta/recursos/fondo.jpg"
    local imagefin="/opt/image/"
    #sudo cp "$img" "$imagefin"
    sudo cp -r "$fonds"/* "$fondsfin"

    if [ ! -f "$img" ]; then
    echo "Error: La imagen no existe en $img"
    exit 1
    fi

    # Copiar la imagen a /opt/image/
    echo "Copiando la imagen desde $img a $imagefin"
    sudo cp "$img" "$imagefin"

    echo "Imagen copiada correctamente a $imagefin"


    sudo mkdir -p "$destino" || return 1
    echo "Descomprimiendo kitty.txz..."
    if ! sudo tar -xJf "$fuente_txz" -C "$destino"; then
        echo "[-] Error en la extracción"
        return 1
    fi
    echo "[+] Instalación completada en $destino"
    echo "Versión instalada: $($destino/bin/kitty --version)"
    sudo pacman -Rns kitty --noconfirm
    mv "$ruta/kitty/color.ini" "$HOME/.config/kitty/"
    mv "$ruta/kitty/kitty.conf" "$HOME/.config/kitty/"
    sudo mv "$HOME/.config/kitty/*" "/root/.config/kitty/"
    sudo fc-cache -f -v
}
picom (){
    local rutai="$ruta/recursos/picom.conf"
    local rutaf="$HOME/.config/picom/"
    cp "$rutai" "$rutaf"
}
zsh(){
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo "source $HOME/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
    rm -r "$HOME/.zshrc"
    local zshi="$ruta/recursos/.zshrc"
    local zshf="$HOME/"
    cp "$zshi" "$zshf"
    ln -s -f "$HOME/.zshrc" ".zshrc"
}

main