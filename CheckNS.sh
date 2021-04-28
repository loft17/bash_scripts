	!/bin/bash

	#----------------------------------------------------------------------------------------------------------------
	#                                                                                                            Info
	#----------------------------------------------------------------------------------------------------------------
	# name: Revision_DNS_NS
	# version: 2021.04.26
	# autor: Jose Luis Romera
	#----------------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------------------------------------------------------------
	#                                                                                                       Variables
	#----------------------------------------------------------------------------------------------------------------

	FOLDER=$(pwd)
	LISTADO="litado.txt"

	#setup colors
	cyan='\e[0;36m'
	green='\033[92m'
	red='\e[1;31m'
	yellow='\e[0;33m'
	orange='\e[38;5;166m'
	NoColor='\033[0m' # No Color

	#----------------------------------------------------------------------------------------------------------------
	#                                                                                                       Funciones
	#----------------------------------------------------------------------------------------------------------------
	rm $FOLDER/list_* -f


	cat $FOLDER/$LISTADO | while read ZONE; do
			REGNS=`dig NS +short $ZONE | awk "NR==1{print $1}"`

			# NOMINALIA
			if [[ $REGNS == *XXXX* ]]
			   then
					echo -e "$NoColor" "$ZONE: " "$green" "$REGNS"
					echo "$ZONE: $REGNS" >> $FOLDER/list_XXX.txt
					
			# MERCURIO
			elif [[ $REGNS == *XXX* ]]
			   then
					echo -e "$NoColor" "$ZONE: " "$red" "$REGNS"
					echo "$ZONE: $REGNS" >> $FOLDER/list_XXXX.txt
					
			# VACIO
			elif [[ -z "$REGNS" ]]
			   then
					echo -e "$NoColor" "$ZONE: " "$orange" "no tiene ns"
					echo "$ZONE: $REGNS" >> $FOLDER/list_SinNS.txt
					
			# OTRO NS
			else
					echo -e "$NoColor" "$ZONE: " "$yellow" "$REGNS"
					echo "$ZONE: $REGNS" >> $FOLDER/list_otro.txt
			fi
	done
