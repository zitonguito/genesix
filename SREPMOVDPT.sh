#!/bin/bash
###################################################################################
# Script   : SREPMOVDPT.sh                                                        #
# Objetivo : Agregar cabecera correspondiente y enviar via correo                 #
#            electronico el reporte de movimientos DPT diario y acumulado         #
#	     el acumulado corre los dias lunes y los dias primero de mes          #
#                                                                                 #
# Fecha    : 22 de Septiembre 2015                                                #
# Modif    : -                                                                    #
# Autor    : Ruben Romero                                                         #
# Log      : /tmp/ENV_LENTO_MOV_8CAPAS.log                                        #
# Parametros         : NINGUNO                                                    #
# Archivos Generados :                                                            #
#                      /tmp/encabezados_DPTs.txt                                  #
#                      /tmp/DPTs_diario_0056.unl                                  #
#                      /tmp/DPTs_diario_0056.xls                                  #
#                      /tmp/DPTs_acumulado_0056.unl                               #
#                      /tmp/DPTs_acumulado_0056.xls                               #
#                      /tmp/repte_vtas_dpt.log                                    #
#                      /tmp/repte_vtas_dpt.txt                                    #
#                                                                                 #
#                      en /tmp                                                    #
# Forma de Ejecucion : desde la terminal  y por C R O N                           #
# Subprocesos        : Ninguno                                                    #
# Area Solicitante   : Sistemas                                                   #
# Observaciones      : Los archivos generados los borra al terminar               #
###################################################################################

cd /tmp

correo_fallo ()
{

horario=`date +%H%M`
descripcion_asunto=" -- FALLO -- REPORTE DE MOVIMIENTOS DPT ${1}"
detinatarios="betancourtp@sanborns.com.mx,gmesa@sanborns.net"

if [ $horario -gt 1200 ]; then
    saludo="Buenas Tardes."
else
    saludo="Buenos Dias."
fi    

echo " 
${saludo}

NOO se genero el reporte de movimientos DPT diario, quiza aun no se envia el man88 

Favor de REVISAR  !!!!!

Saludos...
Atte.:
Sistemas de Inventarios.">/tmp/repte_vtas_dpt.txt

G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
G_ENVIAMSG.sh "<<ENVIANDO CORREO...>>"
echo " |`date` | Correo enviado a $detinatarios " >> repte_vtas_dpt.log
sendmailmon servidor_correo ${detinatarios} romeror@sanborns.com.mx "${descripcion_asunto}" /tmp/repte_vtas_dpt.txt /tmp/repte_vtas_dpt.txt binary>>/tmp/repte_vtas_dpt.log
}

correo ()
{

if [ $1 == "DIARIO" ]; then 
	detinatarios="telcel@sanborns.com.mx,ruizg@sanborns.com.mx,marinesm@sanborns.com.mx,betancourtp@sanborns.com.mx,gmesa@sanborns.net"
else
	detinatarios="hernandezej@sanborns.net,chaveza@sanborns.com.mx,betancourtp@sanborns.com.mx,gmesa@sanborns.net"
fi
horario=`date +%H%M`
descripcion_asunto="REPORTE DE MOVIMIENTOS DPT ${1}"

if [ $horario -gt 1200 ]; then
    saludo="Buenas Tardes."
else
    saludo="Buenos Dias."
fi    

                echo " 
${saludo}

Se hace el envio de la informacion de reporte de movimientos DPT ${1}.

Saludos...
Atte.:
Sistemas de Inventarios.">/tmp/repte_vtas_dpt.txt

G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
G_ENVIAMSG.sh "<<ENVIANDO LOS CORREOS...>>"
echo ""
echo ""
echo ""
echo "ENVIANDO EL CORREO ${1}"
ls -la /tmp/DPTs_diario_0056.xls
read
#sendmailmon servidor_correo ${destino} romeror@sanborns.com.mx "${descripcion_asunto}" /tmp/repte_vtas_dpt.txt ${2} binary>>/tmp/repte_vtas_dpt.log
echo " |`date` | Correo enviado a $detinatarios " >> repte_vtas_dpt.log
sendmailmon servidor_correo ${detinatarios} romeror@sanborns.com.mx "${descripcion_asunto}" /tmp/repte_vtas_dpt.txt ${2} binary>>/tmp/repte_vtas_dpt.log
}


limpia ()
{

if [ -f /tmp/DPTs_*_0056.sql ]; then
	rm -f /tmp/DPTs_*_0056.sql 2> /dev/null
fi

if [ -f /tmp/DPTs_*_0056.unl ]; then
	rm -f /tmp/DPTs_*_0056.unl 2> /dev/null
fi

if [ -f /tmp/encabezados_DPTs.txt ]; then
	rm -f /tmp/encabezados_DPTs.txt 2> /dev/null
fi

if [ -f DPTs_diario_0056.unl ]; then 
	rm -f DPTs_diario_0056.unl
fi

if [ -f DPTs_acumulado_0056.unl ]; then 
	rm -f DPTs_acumulado_0056.unl
fi

if [ -f DPTs_diario_0056.xls ]; then 
	echo ""
	#rm -f DPTs_diario_0056.xls
fi

if [ -f DPTs_acumulado_0056.xls ]; then 
	rm -f DPTs_acumulado_0056.xls
fi

}

query_diario ()
{
echo "set isolation to dirty read;
--drop table t1_vta_pzs;
select cod_pto, int_art, ean_art , fec_mov, count(*) piezas
from movalm_ser
where fec_mov  = today -1
group by 1,2,3,4
into temp t1_vta_pzs with no log;

--drop table t1_vta_imp;
select cod_pto, int_art, ean_art , fec_mov, sum(pvp_mov) imp_vta
from movalm_ser
where fec_mov  = today -1
group by 1,2,3,4
into temp t1_vta_imp with no log;

unload to 'DPTs_diario_0056.unl'
select v.cod_pto, p.des_pto, v.int_art, v.ean_art,
v.fec_mov, v.piezas, v2.imp_vta
from t1_vta_pzs v, t1_vta_imp v2, puntos p
where v.cod_pto = v2.cod_pto
and v.int_art = v2.int_art
and v.ean_art = v2.ean_art
and v.fec_mov = v2.fec_mov
and p.cod_emp = 1
and p.cod_pto = v.cod_pto "> /tmp/DPTs_diario_0056.sql

dbaccess gen /tmp/DPTs_diario_0056.sql	
}

query_acumulado ()
{
echo "set isolation to dirty read;
--drop table t1_vta_pzs;
select cod_pto, int_art, ean_art , fec_mov, count(*) piezas
from movalm_ser
where fec_mov  between MDY(month(today-1),1,year(today-1)) and today -1
group by 1,2,3,4
into temp t1_vta_pzs with no log;

--drop table t1_vta_imp;
select cod_pto, int_art, ean_art , fec_mov, sum(pvp_mov) imp_vta
from movalm_ser
where fec_mov  between MDY(month(today-1),1,year(today-1)) and today -1
group by 1,2,3,4
into temp t1_vta_imp with no log;

unload to 'DPTs_acumulado_0056.unl'
select v.cod_pto, p.des_pto, v.int_art, v.ean_art,
v.fec_mov, v.piezas, v2.imp_vta
from t1_vta_pzs v, t1_vta_imp v2, puntos p
where v.cod_pto = v2.cod_pto
and v.int_art = v2.int_art
and v.ean_art = v2.ean_art
and v.fec_mov = v2.fec_mov
and p.cod_emp = 1
and p.cod_pto = v.cod_pto "> /tmp/DPTs_acumulado_0056.sql

dbaccess gen /tmp/DPTs_acumulado_0056.sql	
}




crea_encabezados ()
{
# -- Crea encabezado -- #
echo "No. TIENDA| --- TIENDA ---| ----- SKU -----| ------- EAN ------- | --- FECHA ----| - PIEZAS - | -- IMPORTE -- |" > /tmp/encabezados_DPTs.txt
}
	

convienrte_a_xls ()
{
#Script para formatear archivos unl(resultado de algun query) dejandolos como archivo.xls, previamente hay que generar una cabecera con el encabezado de las columnas (campos separados por "|"), correr el shell pasando como parametros el archivo de cabecera y el archivo.unl 
#Modificado Ruben Romero,  12 Febrero de 2015
salida=`echo $2|cut -f1 -d.`
if [ `echo $2|cut -c-3` = "top" ];then
    awk 'BEGIN { FS = "|" } { print "<html>\n<meta http-equiv=\"content-type\" content=\"application/vnd.ms-excel\"/>\n<body>\n<table bgcolor=\"white\" border=\"1\">\n<tr>" } { for (i = 1; i<=NF; i++){ if ( i == 8 || i == 10 ) { print "<th bgcolor=\"yellow\" borderColor=#ff0000><P align=right><strong><font color=\"black\">"$i"</strong></font></P></th>"} else  { print "<th bgcolor=\"yelloy\" borderColor=#ff0000><strong><font color=\"black\">"$i"</strong></font></th>" }}{ print "</tr>"}}' $1 > ${salida}.xls 
else
    awk 'BEGIN { FS = "|" } { print "<html>\n<meta http-equiv=\"content-type\" content=\"application/vnd.ms-excel\"/>\n<body>\n<table bgcolor=\"white\" border=\"1\">\n<tr>" } { for (i = 1; i<=NF; i++) print "<th bgcolor=\"yellow\" borderColor=#ff0000><strong><font color=\"black\">"$i"</strong></font></th>" }{ print "</tr>"}' $1 > ${salida}.xls
fi
awk 'BEGIN {FS = "|"} {print "<tr>"}{ for ( i=1; i<NF; i++ ) printf "<td>%s</td>", $i }{print "</tr>"} END {print "</table></body></html>"}' $2 >>${salida}.xls
}

convierte ()
{
convienrte_a_xls /tmp/encabezados_DPTs.txt DPTs_${1}_0056.unl

}
#######################################################################
############################## M A I N ################################
#######################################################################


########################################
########## D  I  A  R  I  O ############
########################################

tipo="DIARIO"
G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
G_ENVIAMSG.sh "<<GENERANDO REPORTE>"
limpia	
query_diario
if [ -s DPTs_diario_0056.unl ]; then
	crea_encabezados
	convierte diario
	G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
	G_ENVIAMSG.sh "<<GENERANDO REPORTE>"
	sleep 3
	correo $tipo DPTs_diario_0056.xls

else
	correo_fallo
	G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
	G_ENVIAMSG.sh "<<NO SE HA CORRIDO EL MAN88>"
	echo "NO SE HA CORRIDO EL MAN88" | tee -a /tmp/repte_vtas_dpt.log
fi

##############################################
############# A C U M U L A D O  #############
##############################################

if [ `date +%w` -eq 1 ] || [ `date +%e` -eq 1 ]; then
	tipo="SEMANAL"
	G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
	G_ENVIAMSG.sh "<<GENERANDO REPORTE>"
	limpia	
	query_acumulado
	query_diario
	if [ -s DPTs_diario_0056.unl ]; then
		crea_encabezados
		convierte acumulado
		G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
		G_ENVIAMSG.sh "<<GENERANDO REPORTE>"
		sleep 3
		#correo $tipo DPTs_acumulado_0056.xls
	else
		G_PRESENTA.sh "ENVIO DE REPORTE DE MOVIMIENTOS DPT" "SREPMOVDPT.sh"
		G_ENVIAMSG.sh "<<NO SE HA CORRIDO EL MAN88>"
		echo "NO SE HA CORRIDO EL MAN88" | tee -a /tmp/repte_vtas_dpt.log
	
	fi	

fi

