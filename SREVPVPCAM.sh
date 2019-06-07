#!/bin/bash
###################################################################################
# Script   : SREVPVPCAM.sh                                                        #
# Objetivo : En caso de que el pvpcam correspondiente al dia no este correcto     #
#			 copiarlo desde el PVPCAM, en caso de existir algun problema con      #
#			 este ultimo, por ejemplo que no se hayan recibido edi, notificarlo   #
#			 por correo                                                           #
# Fecha    : 4 de Abril 2014                                                      #
# Autor    : Ruben Romero                                                         #
# Log      : NINGUNO                                                              #
# Parametros         : NINGUNO                                                    #
# Archivos Generados : NINGUNO                                                    #
# Forma de Ejecucion : desde la terminal o usando mlink                           #
# Subprocesos        : Ninguno                                                    #
# Area Solicitante   : Sistemas                                                   #
# Observaciones      : NINGUNA                                                    #
###################################################################################

echo "La fecha actual del sistema es: `date +%d-%m-%Y` y la hora `date +%I:%M`"> /tmp/adjunto_pvpcam.txt
chown `who -m | awk '{print $1}'`:informix /tmp/adjunto_pvpcam.txt 
chmod 666 /tmp/adjunto_pvpcam.txt      

correo() {
touch /tmp/cuerpo_pvpcam.txt
chown `who -m | awk '{print $1}'`:informix /tmp/cuerpo_pvpcam.txt
chmod 777 /tmp/cuerpo_pvpcam.txt
echo "#################################################################################################">  /tmp/cuerpo_pvpcam.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam.txt
echo "                    PVPCAM CONCATENADO en ${TIENDA} - ${DES_TDA}          ">> /tmp/cuerpo_pvpcam.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam.txt
echo "" >> /tmp/cuerpo_pvpcam.txt
echo "" >> /tmp/cuerpo_pvpcam.txt
cat /tmp/estado_pvpcam.txt >> /tmp/cuerpo_pvpcam.txt
echo "" >> /tmp/cuerpo_pvpcam.txt
echo "">> /tmp/cuerpo_pvpcam.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam.txt
/usr/bin/sendmailmon 128.221.1.200 romeror@sanborns.com.mx romeror@sanborns.com.mx "PVPCAM CONCATENADO ${TIENDA} - ${DES_TDA}" /tmp/adjunto_pvpcam.txt /tmp/cuerpo_pvpcam.txt text
}

correo1() {
touch /tmp/cuerpo_pvpcam1.txt
chown `who -m | awk '{print $1}'`:informix /tmp/cuerpo_pvpcam1.txt
chmod 777 /tmp/cuerpo_pvpcam1.txt
echo "#################################################################################################">  /tmp/cuerpo_pvpcam1.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam1.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam1.txt
echo "               NO HAV PVPCAM POR QUE FALTAN EDIS ${TIENDA} - ${DES_TDA}                          ">> /tmp/cuerpo_pvpcam1.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam1.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam1.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam1.txt
echo "" >> /tmp/cuerpo_pvpcam1.txt
echo "" >> /tmp/cuerpo_pvpcam1.txt
cat /tmp/edis_faltantes.txt >> /tmp/cuerpo_pvpcam1.txt
echo "" >> /tmp/cuerpo_pvpcam1.txt
echo "" >> /tmp/cuerpo_pvpcam1.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam1.txt
/usr/bin/sendmailmon 128.221.1.200 romeror@sanborns.com.mx romeror@sanborns.com.mx "SIN PVPCAM POR EDIS SIN CARGAR -> ${TIENDA} - ${DES_TDA}" /tmp/adjunto_pvpcam.txt /tmp/cuerpo_pvpcam1.txt text
}

correo2() {
touch /tmp/cuerpo_pvpcam2.txt
chown `who -m | awk '{print $1}'`:informix /tmp/cuerpo_pvpcam2.txt
chmod 666 /tmp/cuerpo_pvpcam2.txt
echo "#################################################################################################">  /tmp/cuerpo_pvpcam2.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam2.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam2.txt
echo "               NO HAY CAMBIOS DE PRECIO EN ${TIENDA} - ${DES_TDA}                          ">> /tmp/cuerpo_pvpcam2.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam2.txt
echo "##                                                                                             ##">> /tmp/cuerpo_pvpcam2.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam2.txt
echo "" >> /tmp/cuerpo_pvpcam2.txt
echo "" >> /tmp/cuerpo_pvpcam2.txt
#cat /tmp/edis_faltantes.txt >> /tmp/cuerpo_pvpcam2.txt
echo "" >> /tmp/cuerpo_pvpcam2.txt
echo "" >> /tmp/cuerpo_pvpcam2.txt
echo "#################################################################################################">> /tmp/cuerpo_pvpcam2.txt
/usr/bin/sendmailmon 128.221.1.200 romeror@sanborns.com.mx romeror@sanborns.com.mx "NO HAY CAMBIOS DE PRECIO EN ${TIENDA} - ${DES_TDA}" /tmp/adjunto_pvpcam.txt /tmp/cuerpo_pvpcam2.txt text
}

cd $dload
fecha_ayer=`date -d yesterday +%d%m`
pvpcam_dia="pvpcam`date +%w`"
if [ `find $dload -name $pvpcam_dia -mmin -720 | wc -l` -eq 0 ] || [ `cat $pvpcam_dia | wc -l` -eq 0 ]; then
	if [ `cat $dload/PVPCAM | wc -l` -ne 0 ] && [ `find $dload -name PVPCAM -mmin -720 | wc -l` -gt 0 ]; then
		cp -v $dload/PVPCAM $dload/pvpcam`date +%w`
		if [ $? -eq 0 ]; then
			echo " "
			echo "Se ha copiado PVPCAM -> pvpcam`date +%w`"
		else
			echo " "
			echo "NOOO se pudo copiarPVPCAM -> pvpcam`date +%w`"
		fi
		> $dload/PVPCAM
		echo "Se ha depura PVPCAM"
	else
		if [ `ls $HOME/recepcion/seguridad/c*${fecha_ayer} | wc -l` -gt 0 ]; then
			echo " "
			echo "NO HAY CAMBIOS DE PRECIO"
			correo2
		else
			echo " "
			echo "LOS EDIS NO SE HAN RECIBIDO, RECIBALOS: "
			ls -la $HOME/recepcion/c*${fecha_ayer}* > /tmp/edis_faltantes.txt
			correo1
		fi
	fi
else
	if [ `cat $dload/PVPCAM | wc -l` -eq 0 ]; then
		echo " "
		echo "El pvpcam_dia esta correcto, no haga nada y siga durmiendo"
		echo " "
	else
		if [ `diff $dload/PVPCAM $dload/${pvpcam_dia} | wc -l` -eq 0 ]; then
			> $dload/PVPCAM
		else
			lineas_pvpcam=`wc -l $dload/${pvpcam_dia} | awk '{print $1}'`
			lineas_PVPCAM=`wc -l $dload/PVPCAM | awk '{print $1}'`
			if [ $lineas_pvpcam -gt $lineas_PVPCAM ]; then
			    cd $dload
				ls -la PVPCAM pvpcam* > /tmp/estado_pvpcam.txt
				correo
			else
				cp -v $dload/PVPCAM $dload/pvpcam`date +%w`
				if [ $? -eq 0 ]; then
					echo " "
					echo "Se copio PVPCAM -> pvpcam`date +%w`"
				else
					echo " "
					echo "NOOO se pudo copiarPVPCAM -> pvpcam`date +%w`"
				fi
				> $dload/PVPCAM
				echo " "
				echo "Se depuro PVPCAM"
			fi
		fi
	fi
fi
cd $dload
ls -la PVPCAM pvpcam*
rm -f /tmp/estado_pvpcam.txt
rm -f /tmp/adjunto_pvpcam.txt
rm -f /tmp/edis_faltantes.txt
rm -f /tmp/cuerpo_pvpcam2.txt
