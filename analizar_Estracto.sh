#!/bin/bash

# Función para manejar Ctrl+C
ctrl_c (){
   echo -e "\n\n[!] Saliendo..."
   tput cnorm && exit 1 
}

# Ejecutar el trap solo una vez para atrapar la señal INT (Ctrl+C)
trap ctrl_c INT

# Variables de entrada
machine="salida.pdf"
positivo=""
negativo=""

# Filtrado y procesamiento de la fecha en una función separada
ExtractoPdf (){
   # Filtrado de datos del archivo PDF para obtener las líneas desde el 07/01/2026
   machineName=$(pdftotext -layout "$machine" - | sed 's/−/-/g; s/,//g' | awk '/WEB\/MOV\/KSC|ATM\/POS/ {if(NF > 0) print $0}' | awk '/07\/01\/2026/,0')

   # Si se necesitan más condiciones, ajustarlas aquí antes de procesar el contenido
   pdfExtr=$(echo "$machineName" | sed 's/−/-/g; s/,//g' | awk '/WEB\/MOV\/KSC|ATM\/POS/ {for(i=1;i<=NF;i++){if ($i ~ /^[+-][0-9]+\.[0-9]{2}$/ && $i != "+0.00" && $i != "-0.00") print $i }}')

   # Separar los valores positivos y negativos
   positivos="$(awk '/^\+/' <<< "$pdfExtr")"
   negativos="$(awk '/^-/' <<< "$pdfExtr")"
   
   # Sumar los negativos
   suma_negativos=$(awk '{sum += $1} END{printf "%.2f", sum}' <<< "$negativos")
   
   # Mostrar los resultados
   echo "POSITIVOS:"
   echo "$positivos"
   suma_positivos=$(awk '{sum += $1} END{printf "%.2f", sum}' <<< "$positivos")
   echo "Suma positivos: $suma_positivos"

   echo
   echo "NEGATIVOS:"
   echo "$negativos"
   echo "Suma negativos: $suma_negativos" 
  echo -e "$machineName" | wc -l
 }

# Llamar la función principal
ExtractoPdf
echo -e "$machine" | wc -l
