#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
main_url="https://htbmachines.github.io/bundle.js"

ctrl_c (){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}
trap ctrl_c INT
helpPanel (){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Busca Por Nombre De Maquina ${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar u actualizar ${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por direccion IP ${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar el Panel de ayuda ${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Mostrar dificultad de la maquina ${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener Link YouTube ${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Mostrar sistema operativo ${endColour}"
}
searchMachine (){
  machineName="$1"
  machineName_checker = "$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
 
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listado de maquinas ${endColour}"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La maquina no existe ${endColour}"
  fi
}
updateFiles (){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando Archivos ${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descarga Finalizada ${endColour}"
    tput cnorm
  else
    tput civis
    curl -s $main_url > bundle_temp.js 
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo "[+] No hay actualizaciones"
      rm bundle_temp.js 
    else
      echo "[+] Hay actualizaciones"
      rm bundle.js && mv bundle_temp.js bundle.js
    fi
    tput cnorm
  fi
}
searchIP (){
  ipAddress="$1"
  machineName="$(cat bundle.js | awk "/name: \"Epsilon\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la Ip :${endColour}${blueColour} $ipAddress${endColour}${grayColour} es ${endColour} ${purpleColour} $machineName ${endColour}\n"
}
getYouTubeLink() {
  machineName="$1"

  youtubelink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" \
    | grep -vE "id:|sku:|resuelta" \
    | tr -d '"' \
    | tr -d ',' \
    | sed 's/^ *//' \
    | grep youtube \
    | awk 'NF{print $NF}')"

  if [ "$youtubelink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El link del tutorial es :${endColour}${blueColour} $youtubelink ${endColour}\n"
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe ${endColour}\n"
  fi
}

getmachinesdifficulty (){
  difficulty="$1"
  result_checker="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$result_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando dificultad de maquina ${endColour}${blueColour} $difficulty ${endColour}\n"

    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] la dificultad indicada no existe ${endColour}"
  fi
}
osmachine (){
  os="$1"
  os_result="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$os_result" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando sistema operativo ${endColour}${blueColour} $os ${endColour}"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else 
    echo -e "\n${redColour}[!] el sistema operativo indicado no existe${endColour}"
  fi 
}
declare -i parameter_counter=0
while getopts "m:ui:y:d:o:h" arg; do 
  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    o) os="$OPTARG"; let parameter_counter+=6;;
    h) ;;
  esac
done
if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYouTubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getmachinesdifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  osmachine $os
else
  helpPanel
fi 

