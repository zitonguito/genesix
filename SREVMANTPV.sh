
##################################################################################
# Shell    :                                                                     #
# Objetivo : Detectar de forma rapida y sencilla todos los MANTPV que no estan po#
#             leados en PSI, o que no son del dia de hoy                         #
# Fecha    : Enero 2009                                                          #  
# Autor    : Sistemas de Inventarios   Paul Alberto Cid/Max Dominguiez           #
# Log      :                                                                     #
# Parametros         :                                                           #
# Archivos Generados : correctos.txt, no_poleados.txt, otra_fecha, los_de_AyB.txt#
# Forma de Ejecucion : desde el prompt, su uso es esporadico, no afecta permormance del equiipo. OK: OK::                                                          #
# Subprocesos        : Ninguno                                                   #
# Area Solicitante   : Sistemas                                                  #
# Observaciones      : Ninguno                                                   #
##################################################################################

cd $HOME 2>/dev/null
#**********************************************************************
# Inicio de funcion principal
principal()
{
fech=`date +%u`
fecha=`date +%m-%d`
fech_mtpv_dld=`date +%d%m`
normal=`tput rmso`
negritas=`tput smso`
fila_msj=`expr 17`
columna_msj=`expr 1`
coulmna=`expr 5`
fila=`expr 3`
tiendasFila=`expr 0`
G_PRESENTA.sh "REVISION DEL MANTPV" "monitor.sh"
echo "LA FECHA CORRESPONDIENTE DE VALIDACION ES: $fecha " >date.txt
rm -f no_llego_dir_d_psi.txt 2>/dev/null
rm -f no_poleados.txt        2>/dev/null
rm -f trae_S_PSI_ADDR        2>/dev/null
rm -f correctos.txt          2>/dev/null
rm -f no_hay_S_PSI_ADDR.txt  2>/dev/null
rm -f los_de_AyB.txt         2>/dev/null
rm -f cuerpo.txt             2>/dev/null
rm -f otra_fecha.txt         2>/dev/null
rm -f falta_pasar.txt        2>/dev/null
rm -f genesix_out.txt        2>/dev/null
rm -f ip_psi_lista_dos.txt   2>/dev/null

cat /home/lista2 /remoto2/sistemas/mesa02/lista_externa_mantpv>lista_dos
for i in `cat lista_dos|grep -v sin_psi`
  do
    descrip=`echo $i|cut -f6 -d "|"`
	tienda=`echo $i|cut -f4 -d "|"`
    #echo $descrip                             # echo de validacion 
    v_ip=`echo $i|cut -f2 -d "|"`
    ping -q -c 2 $v_ip 1>/dev/null 2>&1

    if [[ $? -eq 0 ]];then
         #echo Si contesta la ip de genesix    # echo de validacion  
         home=`echo $i|cut -f3 -d "|"`
         echo "open ${v_ip}" > trae_S_PSI_ADDR
         echo "user genesix Logn3680 " >> trae_S_PSI_ADDR
         echo "cd ${home}/gen/load.d " >> trae_S_PSI_ADDR
         echo "get S_PSI_ADDR.txt S_PSI_ADDR.${descrip}${fech}">>trae_S_PSI_ADDR
         echo "dir mantpv.$fech_mtpv_dld " >> trae_S_PSI_ADDR
         echo "bye" >> trae_S_PSI_ADDR
         ftp -n  < trae_S_PSI_ADDR > fech_mtpv_dld.txt 2>&1

        if [[ -f fech_mtpv_dld.txt ]];then
            #echo "se va a validar la existencia del mantpv del dia de hoy en $dload "
            grep mantpv.$fech_mtpv_dld fech_mtpv_dld.txt  >/dev/null  2>&1
     
           if [[ $? -eq 0  ]];then
               #echo "si hay mantpv"
          
               if [[ -f S_PSI_ADDR.${descrip}${fech} ]];then
                   #echo Como si contesta la ip de Genesix, ya se trajo el archivo ADDR  para conectarse a PSI  
                   cat S_PSI_ADDR.${descrip}${fech}|while read line
                      do
                         psi_ip=`echo $line|awk '{print $2}'` 
                         ping -q -c 2 $psi_ip 1>/dev/null 2>&1

                         if [[ $? -eq 0 ]];then
                             #echo si contesta la ip de PSI que viene en el ADDR  
                             user=`echo $line|awk '{print $4}'`
                             pass=`echo $line|awk '{print $6}'`
                             echo "open ${psi_ip}" > trae_dir
                             echo "user $user $pass" >> trae_dir
                             echo "cd store/s_0" >> trae_dir
                             echo "dir MANTPV" >> trae_dir
                             echo "bye" >> trae_dir
                             ftp -n<trae_dir>$HOME/dir.${descrip}${psi_ip}${fech}
                        
                             if [[ -e dir.${descrip}${psi_ip}${fech} ]];then
                                 #echo "ya llego el archivo dir.${descrip}${psi_ip}${fech} de ${descrip}" 
                                 tamanio=`cat dir.${descrip}${psi_ip}${fech}|awk '{print $1}'` 
                                 creacion=`cat dir.${descrip}${psi_ip}${fech}|awk '{print $3}'|cut -c-5`
    
                                 if [ $tamanio -eq 0 ] && [ "$creacion" = "$fecha" ];then
									 tput cup $fila_msj $columna_msj					
									 tput cup $fila $coulmna
									 echo $tienda
									 coulmna=$(($coulmna + 5))
									 tiendasFila=$(($tiendasFila +1))
									 if [ $tiendasFila -eq 14 ]; then
										 fila=$(($fila + 1))
										 tiendasFila=`expr 0`	
										 coulmna=`expr 5`
									 fi					
									 tput cup $fila_msj 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 1)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 2)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 3)) 1
									 echo "                                                                                     "			
									 tput cup $(($fila_msj + 4)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 1)) $columna_msj
									 echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
									 tput cup $(($fila_msj + 2)) $columna_msj					
									 echo "El MANTPV de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` SI esta poleado"
									 tput cup $(($fila_msj + 3)) $columna_msj
									 echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"		
                                     echo "El MANTPV de la tienda $descrip (${psi_ip}) SI esta poleado" >> correctos.txt
                                  else
                                     tput cup $fila_msj $columna_msj					
									 tput cup $fila $coulmna
									 echo ${negritas}${tienda}${normal}
									 coulmna=$(($coulmna + 5))
									 tiendasFila=$(($tiendasFila +1))
									 if [ $tiendasFila -eq 14 ]; then
										 fila=$(($fila + 1))
										 tiendasFila=`expr 0`	
										 coulmna=`expr 5`
									 fi					
									 tput cup $fila_msj 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 1)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 2)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 3)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 4)) 1
									 echo "                                                                                     "								
									 tput cup $(($fila_msj + 1)) $columna_msj
									 echo "***************************************************************************"
									 tput cup $(($fila_msj + 2)) $columna_msj					
									 echo "##          El profile de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO esta poleado" 
									 tput cup $(($fila_msj + 3)) $columna_msj
									 echo "Hay PROBLEMAS con el MANTPV !!!"
									 tput cup $(($fila_msj + 4)) $columna_msj
									 echo "***************************************************************************"
									 echo "El MANTPV de tienda $descrip (${psi_ip}) NO esta poleado" >> no_poleados.txt
                                     cat dir.${descrip}${psi_ip}${fech} >> no_poleados.txt 
                                 fi

                                # if [[ "$creacion" = "$fecha" ]];then
								#	  tput cup $fila_msj $columna_msj					
								#	  tput cup $fila $coulmna
								#	  echo $tienda
								#	  coulmna=$(($coulmna + 5))
								#	  tiendasFila=$(($tiendasFila +1))
								#	  if [ $tiendasFila -eq 14 ]; then
								#	 	 fila=$(($fila + 1))
								#	 	 tiendasFila=`expr 0`	
								#	 	 coulmna=`expr 5`
								#	  fi					
								#	  tput cup $fila_msj 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 1)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 2)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 3)) 1
								#	  echo "                                                                                     "			
								#	  tput cup $(($fila_msj + 4)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 1)) $columna_msj
								#	  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
								#	  tput cup $(($fila_msj + 2)) $columna_msj					
								#	  echo "El profile de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` esta CORRECTO"
								#	  tput cup $(($fila_msj + 3)) $columna_msj
								#	  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"		
                                #      echo "El MANTPV de la tienda $descrip (${psi_ip}) es de hoy" >> correctos.txt
                                #  else
								#	  tput cup $fila_msj $columna_msj					
								#	  tput cup $fila $coulmna
								#	  echo ${negritas}${tienda}${normal}
								#	  coulmna=$(($coulmna + 5))
								#	  tiendasFila=$(($tiendasFila +1))
								#	  if [ $tiendasFila -eq 14 ]; then
								#	 	 fila=$(($fila + 1))
								#	 	 tiendasFila=`expr 0`	
								#	 	 coulmna=`expr 5`
								#	  fi					
								#	  tput cup $fila_msj 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 1)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 2)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 3)) 1
								#	  echo "                                                                                     "
								#	  tput cup $(($fila_msj + 4)) 1
								#	  echo "                                                                                     "								
								#	  tput cup $(($fila_msj + 1)) $columna_msj
								#	  echo "***************************************************************************"
								#	  tput cup $(($fila_msj + 2)) $columna_msj					
								#	  echo "##          El MANTPV de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO es de hoy" 
								#	  tput cup $(($fila_msj + 3)) $columna_msj
								#	  echo "El profile esta INCORRECTO !!!"
								#	  tput cup $(($fila_msj + 4)) $columna_msj
								#	  echo "***************************************************************************"
                                #      echo "El MANTPV de la tienda $descrip (${psi_ip}) NO es de hoy" >> otra_fecha.txt
                                #      cat dir.${descrip}${psi_ip}${fech}|tee -a otra_fecha.txt
                                # fi

                               else   # Este else es de el caso de que no existe el archivo dir.$descrip
									 tput cup $fila_msj $columna_msj					
									 tput cup $fila $coulmna
									 echo ${negritas}${tienda}${normal}
									 coulmna=$(($coulmna + 5))
									 tiendasFila=$(($tiendasFila +1))
									 if [ $tiendasFila -eq 14 ]; then
										 fila=$(($fila + 1))
										 tiendasFila=`expr 0`	
										 coulmna=`expr 5`
									 fi					
									 tput cup $fila_msj 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 1)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 2)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 3)) 1
									 echo "                                                                                     "
									 tput cup $(($fila_msj + 4)) 1
									 echo "                                                                                     "								
									 tput cup $(($fila_msj + 1)) $columna_msj
									 echo "***************************************************************************"
									 tput cup $(($fila_msj + 2)) $columna_msj					
									 echo "## No llego el archivo dir.${descrip}${psi_ip}${fech} de `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2`Validar personalmente el estatus de este servidor" 
									 tput cup $(($fila_msj + 3)) $columna_msj
									 echo "Hay PROBLEMAS con el MANTPV !!!"
									 tput cup $(($fila_msj + 4)) $columna_msj
									 echo "***************************************************************************"
								   echo "no llego el archivo dir.${descrip}${psi_ip}${fech} de ${descrip} Validar personalmente el estatus de este servidor " >> no_llego_dir_d_psi.txt
                             fi       # Se cierra el if de la validacion del archivo dir.,,,,
                         fi              # Se cierra el if de la validacion del ping a la ip de psi 
                      done               # Se cierra el while del cat al archivo S_PSI_ADDR.txt
                  else                  # Este else es del caso en que no se encuentre el archivo S_PSI_ADDR.txt
                      echo "No fue posible traer el archivo S_PSI_ADDR.txt de $descrip , Validar personalmente este caso" >> no_hay_S_PSI_ADDR.txt
               fi                # Se cierra el if de la validacion de la existencia del archivo S_PSI_ADDR.txt de la tienda
         else
			 tput cup $fila_msj $columna_msj					
			 tput cup $fila $coulmna
			 echo ${negritas}${tienda}${normal}
			 coulmna=$(($coulmna + 5))
			 tiendasFila=$(($tiendasFila +1))
			 if [ $tiendasFila -eq 14 ]; then
			 	 fila=$(($fila + 1))
			 	 tiendasFila=`expr 0`	
			 	 coulmna=`expr 5`
			 fi					
			 tput cup $fila_msj 1
			 echo "                                                                                     "
			 tput cup $(($fila_msj + 1)) 1
			 echo "                                                                                     "
			 tput cup $(($fila_msj + 2)) 1
			 echo "                                                                                     "
			 tput cup $(($fila_msj + 3)) 1
			 echo "                                                                                     "
			 tput cup $(($fila_msj + 4)) 1
			 echo "                                                                                     "								
			 tput cup $(($fila_msj + 1)) $columna_msj
			 echo "***************************************************************************"
			 tput cup $(($fila_msj + 2)) $columna_msj					
			 echo "##  El MANTPV de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO se ha pasado a PSI" 
			 tput cup $(($fila_msj + 3)) $columna_msj
			 echo "El MANTPV no ha pasado !!!"
			 tput cup $(($fila_msj + 4)) $columna_msj
			 echo "***************************************************************************"
             echo "No hemos pasado el archivo de $descrip " >> falta_pasar.txt
      fi       # validacion del grep al mantpv de dload
    fi           # Se termian la validacion del la existencia del archivo en donde viene la fecha

  else                       # Este else es para el caso en que no se conteste el ping al servidor genesix

     #echo "pesitos i es $i ---------------------echo de validacion     -------------    "
     #echo " pesitos descrip es $descrip  "
	 tput cup $fila_msj $columna_msj					
	 tput cup $fila $coulmna
	 echo ${negritas}${tienda}${normal}
	 coulmna=$(($coulmna + 5))
	 tiendasFila=$(($tiendasFila +1))
	 if [ $tiendasFila -eq 14 ]; then
	 	 fila=$(($fila + 1))
	 	 tiendasFila=`expr 0`	
	 	 coulmna=`expr 5`
	 fi					
	 tput cup $fila_msj 1
	 echo "                                                                                     "
	 tput cup $(($fila_msj + 1)) 1
	 echo "                                                                                     "
	 tput cup $(($fila_msj + 2)) 1
	 echo "                                                                                     "
	 tput cup $(($fila_msj + 3)) 1
	 echo "                                                                                     "
	 tput cup $(($fila_msj + 4)) 1
	 echo "                                                                                     "								
	 tput cup $(($fila_msj + 1)) $columna_msj
	 echo "***************************************************************************"
	 tput cup $(($fila_msj + 2)) $columna_msj					
	 echo "##  La Unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO RESPONDE" 
	 tput cup $(($fila_msj + 3)) $columna_msj
	 echo "NO HAY CONEXION CON EL SERVIDOR !!!"
	 tput cup $(($fila_msj + 4)) $columna_msj
	 echo "***************************************************************************"
     echo "No hay conexion con el servidor Genesix $descrip, " >> genesix_out.txt
     psi_ip_lista_dos=`echo $i|cut -f9 -d "|"`
     ping -q -c 2 $psi_ip_lista_dos 1>/dev/null 2>&1 
     if [[ $? -eq 0 ]]
        then
           echo "open ${psi_ip_lista_dos}" > trae_dir
           echo "user PSIUSER PSIPSWD" >> trae_dir
           echo "cd store/s_0" >> trae_dir
           echo "dir MANTPV" >> trae_dir
           echo "bye" >> trae_dir
           ftp -n  < trae_dir > dir.${descrip}${psi_ip_lista_dos}${fech}
           if [[ -e dir.${descrip}${psi_ip_lista_dos}${fech} ]];then
                 tamanio=`cat dir.${descrip}${psi_ip_lista_dos}${fech}|awk '{print $1}'`
                 creacion=`cat dir.${descrip}${psi_ip_lista_dos}${fech}|awk '{print $3}'|cut -c-5`

                 if [[ $tamanio -eq 0 ]];then
                        echo "El archivo MANTPV de la tienda $descrip (${psi_ip_lista_dos} SI esta poleado" >> correctos.txt
                     else
					 tput cup $fila_msj $columna_msj					
						tput cup $fila $coulmna
						echo ${negritas}${tienda}${normal}
						coulmna=$(($coulmna + 5))
						tiendasFila=$(($tiendasFila +1))
						if [ $tiendasFila -eq 14 ]; then
							fila=$(($fila + 1))
							tiendasFila=`expr 0`	
							coulmna=`expr 5`
						fi					
						tput cup $fila_msj 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 1)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 2)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 3)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 4)) 1
						echo "                                                                                     "								
						tput cup $(($fila_msj + 1)) $columna_msj
						echo "***************************************************************************"
						tput cup $(($fila_msj + 2)) $columna_msj					
						echo "##  El MANTPV de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO esta poleado" 
						tput cup $(($fila_msj + 3)) $columna_msj
						echo "El PROBLEMAS con el MANTPV !!!"
						tput cup $(($fila_msj + 4)) $columna_msj
						echo "***************************************************************************"
                        echo "El archivo MANTPV de la tienda $descrip (${psi_ip_lista_dos}) NO esta poleado" >> no_poleados.txt
                 fi
                 if [[ "$creacion" = "$fecha" ]];then
                        echo "El  MANTPV de la tienda $descrip (${psi_ip_lista_dos})es de hoy" >> correctos.txt
                     else
						tput cup $fila_msj $columna_msj					
						tput cup $fila $coulmna
						echo ${negritas}${tienda}${normal}
						coulmna=$(($coulmna + 5))
						tiendasFila=$(($tiendasFila +1))
						if [ $tiendasFila -eq 14 ]; then
							fila=$(($fila + 1))
							tiendasFila=`expr 0`	
							coulmna=`expr 5`
						fi					
						tput cup $fila_msj 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 1)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 2)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 3)) 1
						echo "                                                                                     "
						tput cup $(($fila_msj + 4)) 1
						echo "                                                                                     "								
						tput cup $(($fila_msj + 1)) $columna_msj
						echo "***************************************************************************"
						tput cup $(($fila_msj + 2)) $columna_msj					
						echo "##          El MANTPV de la unidad `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO es de hoy" > edo_profile.txt
						tput cup $(($fila_msj + 3)) $columna_msj
						echo "El PROBLEMAS con el MANTPV !!!"
						tput cup $(($fila_msj + 4)) $columna_msj
						echo "***************************************************************************"
                        echo "El  MANTPV de la tienda $descrip (${psi_ip_lista_dos}) NO es de hoy"|tee -a otra_fecha.txt
                 fi
                 if [[ $descrip = "UNIVERSIDAD" || $descrip = "SATELITE" || $descrip = "PERISUR" || $descrip = "SANTA_FE" || $descrip = "TEPIC" ]]
                     then
                       echo "En  $descrip solo se valido el MANTPV de $psi_ip_lista_dos falta validar en los demas equipos"|tee -a los_de_AyB.txt
                 fi             # Se cierra el if de la validacion de las tindas grandes y falta agregar a los de bicky


                    else   # Este else es de el caso de que no existe el archivo dir.$descrip
                             echo "no llego el archivo dir.${descrip}${psi_ip}${fech} de ${descrip} Validar personalmente el status de la tienda " >> no_llego_dir_d_psi.txt
              fi     # Se cierra el if del archivo dir.,,,,
     else       # Este else es del if del ping a la ip de lista_2
		tput cup $fila_msj $columna_msj					
		tput cup $fila $coulmna
		echo ${negritas}${tienda}${normal}
		coulmna=$(($coulmna + 5))
		tiendasFila=$(($tiendasFila +1))
		if [ $tiendasFila -eq 14 ]; then
			fila=$(($fila + 1))
			tiendasFila=`expr 0`	
			coulmna=`expr 5`
		fi					
		tput cup $fila_msj 1
		echo "                                                                                     "
		tput cup $(($fila_msj + 1)) 1
		echo "                                                                                     "
		tput cup $(($fila_msj + 2)) 1
		echo "                                                                                     "
		tput cup $(($fila_msj + 3)) 1
		echo "                                                                                     "
		tput cup $(($fila_msj + 4)) 1
		echo "                                                                                     "								
		tput cup $(($fila_msj + 1)) $columna_msj
		echo "***************************************************************************"
		tput cup $(($fila_msj + 2)) $columna_msj					
		echo "##          Servidor de PSI de  `grep $tienda lista_nombres| cut -d \"|\" -f1` -  `grep $tienda lista_nombres| cut -d \"|\" -f2` NO contesta" > edo_profile.txt
		tput cup $(($fila_msj + 3)) $columna_msj
		echo "PSI NO CONTESTA"
		tput cup $(($fila_msj + 4)) $columna_msj
		echo "***************************************************************************"
        echo "La maquina de psi  $psi_ip_lista_dos de $descrip no contesta " |tee -a ip_psi_lista_dos.txt
   fi                        # Se cierra el if de la validacion del ping a la ip de lista_dos 
fi                           # Se cierra el if de la validacion del ping al Servidor Genesix
done                         # Se cierra el for del cat a lista_2 

#Creacion del Cuerpo del correo
echo "#################################################################################################">  cuerpo.txt
echo "##                                                                                             ##">> cuerpo.txt
echo "##                                                                                             ##">> cuerpo.txt
echo "##                       S I S T E M A    D E     I N V E N T A R I O S                        ##">> cuerpo.txt
echo "##                                                                                             ##">> cuerpo.txt
echo "##                                                                                             ##">> cuerpo.txt
echo "#################################################################################################">> cuerpo.txt
echo "" >> cuerpo.txt
echo "" >> cuerpo.txt
echo "                        REPORTE DE ARCHIVOS PENDIENTES DE POLEAR EN PSI" >> cuerpo.txt
echo "" >> cuerpo.txt
echo "" >> cuerpo.txt

if [[ -f no_poleados.txt || -f otra_fecha.txt || -f no_hay_S_PSI_ADDR.txt || -f los_de_AyB.txt || -f falta_pasar.txt || -f genesix_out.txt || -f ip_psi_lista_dos.txt ]]
     then
       if [[ -f no_poleados.txt ]];then
           cuenta_no_poleados=`cat no_poleados.txt|grep -v $fecha|wc -l`
           echo "Total de Archivos Pendientes de Polear: $cuenta_no_poleados " >> cuerpo.txt
           echo "" >> cuerpo.txt
           cat no_poleados.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f otra_fecha.txt ]];then
           ayer=`date --date='1 day ago' +%m-%d`
           cuenta_otra_fecha=`cat otra_fecha.txt|grep -v $ayer|wc -l`
           echo "Total de Archivos MANTPV que no son de hoy $cuenta_otra_fecha " >> cuerpo.txt
           cat otra_fecha.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f no_hay_S_PSI_ADDR.txt ]];then
           cuenta_no_hay_S_PSI_ADDR=`cat no_hay_S_PSI_ADDR.txt|wc -l`
           echo "En $cuenta_no_hay_S_PSI_ADDR Servidores Genesix no fue posible checar el archivo S_PSI_ADDR (Validar personalmente el poleo)" >> cuerpo.txt
           cat no_hay_S_PSI_ADDR.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f los_de_AyB.txt ]];then
           cuenta_los_de_AyB=`cat otra_fecha.txt|wc -l`
           echo "Nota: No fue posible conectarse al sevidor Genesix para obtener sus respectivas direcciones ip, por lo que en las siguientes tiendas solo se valido el servidore secundario, checar personalmente los demas servidores de psi. " >> cuerpo.txt
           cat los_de_AyB.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f falta_pasar.txt ]];then
           dia=`date +%a`
#           if [[ $dia = Mon ]];then
 #                cat falta_pasar.txt|egrep -v "panama_9201|metrocentro_8002|elsalvador">falta_pasar.txt
  #         fi      
           cuenta_falta_pasar=`cat falta_pasar.txt|wc -l`
           echo "En $cuenta_falta_pasar Servidores Genesix no se ha pasado el MANTPV a PSI" >> cuerpo.txt
           cat falta_pasar.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f genesix_out.txt ]];then
           cuenta_genesix_out=`cat genesix_out.txt|wc -l`
           echo "En $cuenta_genesix_out Servidores Genesix no fue posible establecer conexion" >> cuerpo.txt
           cat genesix_out.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi
       if [[ -f ip_psi_lista_dos.txt ]];then
           cuenta_ip_psi_lista_dos=`cat ip_psi_lista_dos.txt|wc -l`
           echo "En $cuenta_ip_psi_lista_dos Servidores de Psi no fue posible establecer conexion" >> cuerpo.txt
           cat ip_psi_lista_dos.txt >> cuerpo.txt
           echo "" >> cuerpo.txt
           echo "" >> cuerpo.txt
       fi



   else
        echo "" >> cuerpo.txt
        echo "" >> cuerpo.txt
        echo "NO HAY NINGUN MANPTV PENDIENTE, TODO ESTA CORRECTO" >> cuerpo.txt
        echo "" >> cuerpo.txt
        echo "" >> cuerpo.txt
        echo "" >> cuerpo.txt
fi
echo "#################################################################################################">> cuerpo.txt

   sendmailmon 128.221.1.200 romeror@sanborns.com.mx romeror@sanborns.com.mx "VALIDACION DE MANTPVS EN PSI $fecha" $HOME/date.txt $HOME/cuerpo.txt text
rm S_PSI* dir.* date.txt
}

#-----------------------------------
#  Cuerpo principal del shell
#-----------------------------------

#hora=`date +%H%M`
#correcto=`grep 'NO HAY NINGUN MANPTV PENDIENTE, TODO ESTA CORRECTO' cuerpo.txt|wc -l`
#if [[ $hora = 1114 && $correcto -eq 1 ]]
#   then
#       echo "No fue necesario realizar nada por esta vez"    
#   else
#       principal
#fi
principal