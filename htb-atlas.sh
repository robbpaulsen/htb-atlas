#!/usr/bin/env bash

# Colours
rc="\e[0;31\033[1m"
gc="\e[0;32m\033[1m"
yc="\e[0;33m\033[1m"
bc="\e[0;34m\033[1m"
pc="\e[0;35m\033[1m"
tc="\e[0;36m\033[1m"
grayc="\e[0;37m\033[1m"
ec="\033[0m\e[0m"

# Banner de AsciiArt, herramienta disponible en `https://manytools.org/hacker-tools/ascii-banner`
function banner() {
	echo ""
	echo ""
	echo -e "${tc}██╗  ██╗████████╗██████╗        █████╗ ████████╗██╗      █████╗ ███████╗${ec}"
	echo -e "${tc}██║  ██║╚══██╔══╝██╔══██╗      ██╔══██╗╚══██╔══╝██║     ██╔══██╗██╔════╝${ec}"
	echo -e "${tc}███████║   ██║   ██████╔╝█████╗███████║   ██║   ██║     ███████║███████╗${ec}"
	echo -e "${tc}██╔══██║   ██║   ██╔══██╗╚════╝██╔══██║   ██║   ██║     ██╔══██║╚════██║${ec}"
	echo -e "${tc}██║  ██║   ██║   ██████╔╝      ██║  ██║   ██║   ███████╗██║  ██║███████║${ec}"
	echo -e "${tc}╚═╝  ╚═╝   ╚═╝   ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝${ec}"
	echo ""
	echo ""
}

# Llamada a la propia funcion
banner

# Tiempo de espera entre banner y solicitud del usuario
sleep 2

# Limpiar la pantalla
clear

###################################################################################################
###################################################################################################
## Area de Variables
###################################################################################################
###################################################################################################
mainUrl="https://htbmachines.github.io/bundle.js"

###################################################################################################
###################################################################################################
## Area de funciones
###################################################################################################
###################################################################################################
# Declarando Ctrl + c para salir y/o interrumpir el script
function ctrl_c() {
	echo -e "\n\n${tc}[!] Saliendo...${ec}\n"
	exit 1 # Se declara con el valor de "1" la salida o interrupcion ya que fue forzado
	# de igual manerqa este valor podria se otro con el cual el programador lo
	# identifique, pero la convencion usada es que para estos casos se declare
	# con el valor de "1"
}
trap ctrl_c INT

function helpPanel() {
	echo -e "\n${yc}[+]${ec}${grayc} Uso:${ec}"
	echo -e "\t${pc}u)${ec}${grayc} Buscar Actualizaciones ...${ec}"
	echo -e "\t${pc}m)${ec}${grayc} Buscar por nombre de maquina${ec}"
	echo -e "\t${pc}i)${ec}${grayc} Buscar por Ip de la Maquina${ec}"
	echo -e "\t${pc}y)${ec}${grayc} Buscar enlace de resolucion de youtube para la maquina${ec}"
	echo -e "\t${pc}d)${ec}${grayc} Buscar Maquinas por dificultad${ec}"
	echo -e "\t${pc}o)${ec}${grayc} Buscar Maquinas por tipo de Sistema Operativo${ec}"
	echo -e "\t${pc}s)${ec}${grayc} Buscar Maquinas por Skill${ec}"
	echo -e "\t${pc}h)${ec}${grayc} Mostrar este panel de ayuda${ec}"
}

function searchMachine() {
	machineName="$1"

	machineNameChkr="$(/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta|activeDirectory:" | tr -d '"' | tr -d ',' | sed 's/^*//')"

	if [ "$machineNameChkr" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Listando las propiedades de la maquina${ec}${bc} $machineName${ec}:\n"
		/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^*//'
	else
		echo -e "\n${yc}[!]${ec}${grayc} La maquina proporcionada no existe, intentarlo de nuevo${ec}\n"
	fi
}

function updateFiles() {
	if [ ! -f bundle.js ]; then
		echo -e "\n${yc}[+]${ec}${grayc} No existe la base de datos, empieza la descarga ....${ec}\n"
		curl -s "$mainUrl" >bundle.js
		js-beautify bundle.js |
			sponge bundle.js
		echo -e "\n${gc}[+]${ec}${grayc} Todos los archivos se han descargad${ec}\n"
	else
		curl -s "$mainUrl" >temp.js &&
			js-beautify temp.js | sponge temp.js

		evalb="$(md5sum bundle.js | awk '{ print $1 }')"
		evalt="$(md5sum temp.js | awk '{ print $1 }')"

		if [ "$evalb" == "$evalt" ]; then
			echo -e "\n${yc}[!]${ec}${grayc} No hay actualizaciones nuevas${ec}\n"
		else
			echo -e "\n${yc}[+]${ec}${grayc} Hay actualizaciones pendientes${ec}\n"
			rm -rf bundle.js && mv temp.js bundle.js
		fi
	fi
}

function searchIp() {
	ipAddress="$1"
	ipChkr="$(/bin/cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

	if [ "$ipChkr" ]; then
		echo -e "\n${yc}[!]${ec}${grayc} La maquina correspondiente a la IP${ec}${bc} $ipAddress${ec}${gc} es${ec}${pc} $ipChkr${ec}\n"
	else
		echo -e "\n${yc}[!]${ec}${grayc} La IP proporcionada no existe, intentarlo de nuevo${ec}\n"
	fi
}

function getYoutubeLink() {
	youtubeLink="$(/bin/cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta|activeDirectory:" | tr -d '"' | tr -d ',' | sed 's/^*//' | grep youtube | awk 'NF{print $NF}')"

	if [ "$youtubeLink" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} El tutorial para esta maquina esta en el siguiente enlace:${ec}${bc} "${youtubeLink}"${ec}\n"

	else
		echo -e "\n${yc}[!] No existe un enlace de youtube para la Maquina proporcionada${ec}\n"

	fi
}

function getMachinesDifficulty() {
	difficulty="$1"
	resultsChk="$(/bin/cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$resultsChk" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Estos son las maquinas con la dificultad:${ec}${tc} "${difficulty}"${ec}\n"
		/bin/cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${yc}[!]${ec} La dificultad mencionada no existe, intentalo de nuevo${ec}\n"
	fi
}

function getOsType() {
	os="$1"
	osChk="$(/bin/cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$osChk" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Estos son las maquinas con sistme operativo:${ec}${tc} "{$os}"${ec}\n"
		/bin/cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${yc}[!] No existe maquina con ese sistema operativo${ec}\n"
	fi
}

function getOsDifficultyMachine() {
	difficulty="$1"
	os="$2"
	chkResults="$(/bin/cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$chkResults" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Inicia busqueda por la dificultad${ec}${gc} "${difficulty}"${ec}${grayc} y sistema operativo${ec}${bc} "${os}"${ec}${grayc}, resultados:${ec}\n"
		/bin/cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${yc}[!] No existes maquinas con ese sistema y/o dificultad${ec}\n"
	fi
}

function getSkills() {
	skills="$1"
	chkResults="$(/bin/cat bundle.js | grep "skills:" -B 6 | grep "${skills}" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$chkResults" ]; then
		echo -e "\n${yc}[+]${ec}${grayc} Generando resultados de las maquinas con el${ec}${tc} skill${ec}${grayc} mencionados${ec}\n"
		/bin/cat bundle.js | grep "skills:" -B 6 | grep "$skills" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${yc}[!] No se encontraron maquinas con los skill mencionados${ec}\n"
	fi
}

###################################################################################################
###################################################################################################
## Area de indicador
###################################################################################################
###################################################################################################
# Indicadores, declaramos o mas le asignamos un valor de 0
# al indicador inicial ya que a lenguaje de maquina
# el valor inicial siempre es 0.
declare -i parameter_counter=0

## Indicador para combinacion de busquedas
#
declare -i combinacion_difficulty=0
declare -i combinacion_os=0

###################################################################################################
###################################################################################################
## Area de panel
###################################################################################################
###################################################################################################
while getopts "m:ui:y:d:o:s:h" arg; do # en la implementacion de loops while en conjunto con "getopts"/"getopt"
	# se declaran los switches u objetos del panel que se este elaborando
	# entre "" y si el objeto o elemento aparte se valdra de un argumento que
	# se le tenga que pasar por el usuario este elemento debe de ser seguido por
	# ":" , en este caso tenemos "m:h" que a nivel ejecucion se traduce al usuario
	# a esto "-m <el argumento>" y "-h" que por convencion hace referencia a "help"
	case $arg in
	[m]*) # como forma de prevencion declaramos dentro de '[]' el objeto o flag "m"
		# asi el mismo valor se auto compara y se evitan ejecuciones o comportamiento
		# inesperado por parte del script
		machineName="$OPTARG"
		((parameter_counter += 1))
		;;
	[u]*)
		((parameter_counter += 2))
		;;
	[i]*)
		ipAddress="$OPTARG"
		((parameter_counter += 3))
		;;
	[y]*)
		machineName="$OPTARG"
		((parameter_counter += 4))
		;;
	[d]*)
		difficulty="$OPTARG"
		((combinacion_difficulty = 1))
		((parameter_counter += 5))
		;;
	[o]*)
		os="$OPTARG"
		((combinacion_os = 1))
		((parameter_counter += 6))
		;;
	[s]*)
		skills="$OPTARG"
		((parameter_counter += 7))
		;;
	[h]*) ;;
	esac
done

###################################################################################################
###################################################################################################
## Area main script
###################################################################################################
###################################################################################################
# Por cada objeto que se declare/genere/cree en el area del while loop por consecuencia tendra un
# papel o juego en la llogica de toma de decision del script por lo cual primero se genera el objeto
# del panel , despues se pasa a declarar la logica de la toma de desicion y esta se ayudara con
# el uso de una funcion que debemos de generar/crear en el area de funciones, en tonces el workflow
# es el siguiente:
#
# 1) Generar el objeto del panel en area del panel y asignarle un valor del indicador, por cada objeto
# del panel nuevo se le suma un indiccador
# 2) Generar la logica de toma de desicion en el Area  del main script
# 3) Generarl al fuincion la cual sera la herramienta con la que el main script tome una accion.
#

if [ $parameter_counter -eq 1 ]; then
	searchMachine "$machineName"
elif [ "$parameter_counter" -eq 2 ]; then
	updateFiles
elif [ "$parameter_counter" -eq 3 ]; then
	searchIp "$ipAddress"
elif [ "$parameter_counter" -eq 4 ]; then
	getYoutubeLink "$machineName"
elif [ "$parameter_counter" -eq 5 ]; then
	getMachinesDifficulty "$difficulty"
elif [ "$parameter_counter" -eq 6 ]; then
	getOsType "$os"
elif [ "$combinacion_difficulty" -eq 1 ] && [ "$combinacion_os" -eq 1 ]; then
	getOsDifficultyMachine "$difficulty" "$os"
elif [ "$parameter_counter" -eq 7 ]; then
	getSkills "$skills"
else
	helpPanel
fi
