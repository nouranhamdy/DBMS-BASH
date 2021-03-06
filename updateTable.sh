#!/bin/bash
clear
typeset -i n=0
typeset -i j=1
typeset -i k=0
typeset -i matches=0
typeset -i cont=1
read -p "enter table name: " tblName
while [[ $cont -eq 1 ]]
do
if [[ -f $dbPATH/$tblName ]]
then
	echo "update $tblName using:"
    awk -F: 'BEGIN{i=1;str=""}{if (NR==2){while(i<=NF){str=i") "$i;print str;i++;}}}' $dbPATH/$tblName
	#awk -F: 'BEGIN{printf "enter key to search with: ";getline key<"-";printf "enter value: ";getline keyVal<"-";printf "enter key to update: ";getline updatedCol<"-";printf "enter new value to insert: ";getline newVal<"-";} (NR==1){updatedColDatatype=$updatedCol} gsub($updatedCol, newVal){if($key==keyVal) {str=$0}}(updatedColDatatype="text") {print str}' $dbPATH/$tblName 
	n=`awk -F: '{if(NR==1){print NF}}' $dbPATH/$tblName`
	typeset newRecord=""
    typeset oldRecord=""
	read -p "enter key to search with: " key
	if [ $key -le $n ]
	then
		read -p "enter value: " keyVal
		matches=`cut -d: -f$key $dbPATH/$tblName | grep -c "$keyVal"` 
		if [ $matches -ne 0 ]
		then  
			read -p "enter key to update: " updatedCol
			updatedColDatatype=`cut -d: -f$updatedCol $dbPATH/$tblName | head -1`
			if [[ $updatedColDatatype = serial ]]
			then
				echo "Can't Update serial key"
			else
				if [ $updatedCol -le $n  ]
				then
					read -p "enter new value to insert: " newVal
					if [[ $updatedColDatatype = int && $newVal != "" && $newVal != +([0-9]) ]]
					then
						echo ""
						echo "ERROR: Integer Value Expected"
						echo ""		
					elif [[ $updatedCol -eq 1 && $newVal = "" ]]
					then
						echo ""
						echo "ERROR: Primary Key Cannot Be NULL"
						echo ""
					else
						PKmatch=`cut -d: -f1 $dbPATH/$tblName | grep "$newVal" | wc -l`
						if [ $updatedCol -eq 1 -a $PKmatch -ne 0 ] 
						then
							echo "Duplicate entry ($newVal) for key ($tblName.PRIMARY)"
						else	
							#input validation
							oldRecord=$(awk -F: -v key=$key -v keyVal="$keyVal" 'BEGIN{FS=":";RS="\n";OFS=":";ORS="|"}{if($key==keyVal) {print $0}}' $dbPATH/$tblName)
							newRecord=$(awk -F: -v key=$key -v keyVal="$keyVal" -v updatedCol=$updatedCol -v newVal="$newVal" 'BEGIN{FS=":";RS="\n";OFS=":";ORS="|"; }gsub($updatedCol, newVal , $updatedCol){if($key==keyVal) {print $0}}gsub("NULL", newVal , $updatedCol){if($key==keyVal) {print $0}}' $dbPATH/$tblName)
							#echo $newVal
							#awk -F: -v key=$key -v keyVal=$keyVal -v updatedCol=$updatedCol -v newVal="$newVal" -v path=$dbPATH/$tblName 'BEGIN{OFS=":";} gsub($updatedCol, newVal, $updatedCol){if($key==keyVal){print $0 >> path }}' $dbPATH/$tblName
							IFS='|'; arrOLD=($oldRecord); unset IFS;
							IFS='|'; arrNEW=($newRecord); unset IFS;
							j=${#arrOLD[@]}
							while [[ $k -lt $j && $newRecord != "" ]]
							do
								sed -i "s/${arrOLD[$k]}/${arrNEW[$k]}/g" $dbPATH/$tblName 
								k=$k+1
							done	
							echo "Rows matched: $matches  Changed: $j "
						fi	
					fi	
				else
					echo ""
					echo "invalid Key"
					echo ""
				fi
			fi	
		else
			echo ""
			echo "No Matched records"
			echo ""
		fi	
	else
	    echo ""
		echo "invalid Key"
		echo ""

	fi	
else 
	echo ""
	echo "No such Table"
	echo ""
fi
select x in "Update" "Back"  
do
	case $x in
		"Update") cont=1 break;;
		"Back") source ./connectToDB.sh 1;
        esac
done
done




