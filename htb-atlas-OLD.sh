#!/bin/bash

# Colours
gc="\e[1;32m\033[1m"
ec="\033[0m\e[0m"
rc="\e[1;31m\033[1m"
bc="\e[1;34m\033[1m"
yc="\e[1;33m\033[1m"
pc="\e[1;35m\033[1m"
tc="\e[1;36m\033[1m"
grayc="\e[1;37m\033[1m"

function ctrl_c() {
	echo -e "\n\n${yc}[!] Saliendo...\n${ec}"
	tput cnorm && exit 1
}

trap ctrl_c INT

echo -n "  ___ ___ _____________________
 /   |   \\__    ___/\______   \
/    ~    \ |    |    |    |  _/
\    Y    / |    |    |    |   \
 \___|_  /  |____|    |______  /
  \/                         \/"

mainUrl="https://htbmachines.github.io/bundle.js"

function helpPanel() {
	echo -e "\n${yc}[+]${ec}${grayc} Uso:${ec}"
	echo -e "\t${pc}u)${ec}${grayc} Descargar o Actualizar la base de datos${ec}"
	echo -e "\t${pc}m)${ec}${grayc} Buscar por un nombre de maquina${ec}"
	echo -e "\t${pc}d)${ec}${grayc} Buscar maquinas por Dificultad${ec}"
	echo -e "\t${pc}l)${ec}${grayc} Obtener link de resolucion de la Maquina${ec}"
	echo -e "\t${pc}h)${ec}${grayc} Mostrar este panel de ayuda${ec}"
}

function updateFiles() {
	if [[ ! -f bundle.js ]]; then
		tput civis
		echo -e "\n${gc}[+] Descargando archivos necesario\n${ec}"
		curl -s $mainUrl >bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${gc}[+] Todos los archivos se han Descargado\n${ec}"
		tput cnorm
	else
		tput civis
		echo -e "\n${yc}[+]${ec}${grayc} Comprobando si hay actualizacioneso\n${ec}"

		curl -s $mainUrl >temp.js
		js-beautify temp.js | sponge temp.js

		evalb="$(md5sum bundle.js | awk '{ print "$1" }')"
		evalt="$(md5sum temp.js | awk '{ print "$1" }')"

		if [[ "$evalb" == "$evalt" ]]; then
			echo -e "\n${pc}[+]${ec}${grayc} No hay Actualizaciones\n${ec}"
		else
			echo -e "\n${yc}[+]${ec}${grayc} Hay Actualizaciones\n${ec}"
			rm bundle.js && mv temp.js bundle.js

			echo -e "\n${gcc}[+]${ec}${grayc} La Base de datos se a actualizado\n${ec}"

		fi

		tput cnorm
	fi
}

function searchMachine() {
	machineName="$1"
	machineName_checker="$(/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//')"

	if [ "$machineName_checker" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Listando las propiedades de la maquina${ec}${bc} $machineName${ec}${grayc}:${ec}\n"
		/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//'
	else
		echo -e "\n${rc}[!] La Maquina proporcionada no existe ...${ec}\n"
	fi
}

function getYouTubeLink() {
	machineName="$1"
	youtubeLink="$(/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//' | grep youtube | awk 'NF{ print $NF }')"

	if [ "$youtubeLink" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} El tutorial para esta maquina se encuentra en el siguiente enlace:${ec}${pc} $youtubeLink${ec}\n"
	else
		echo -e "\n${rc}[!] La Maquina proporcionada no existe ...${ec}\n"
	fi
}

function getMachineDifficulty() {
	difficulty="$1"
	results_check="$(/bin/cat bundle.js | grep "dificultad: \"$difficulty"\" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$results_check" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Listando las maquinas de Dificultad${ec}${bc} $difficulty${ec}${grayc}:${ec}\n"
		/bin/cat bundle.js | grep "dificultad: \"$difficulty"\" -B 5 | grep name | awk NF'{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${rc}[!] No existe la dificultad mencionada ...${ec}\n"
	fi
}

# Indicadores
declare -i parameter_counter=0

while getopts "m:ul:d:h" arg; do
	case $arg in
	m)
		machineName="$OPTARG"
		((parameter_counter += 1))
		;;
	u)
		((arameter_counter += 2))
		;;
	l)
		machineName="$OPTARG"
		((parameter_counter += 3))
		;;
	d)
		difficulty="$OPTARG"
		((parameter_counter += 4))
		;;

	h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	getYouTubeLink "$machineName"
elif [ $parameter_counter -eq 4 ]; then
	getMachineDifficulty "$machineName"
else
	helpPanel
fi
