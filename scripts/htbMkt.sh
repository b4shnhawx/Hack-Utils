#!/bin/bash

dir=`pwd`

mkdir {"$dir/nmap","$dir/content","$dir/exploits","$dir/scripts","$dir/tmp"}

#### CHEATSHEET NMAP
cat <<EOF > "$dir/nmap/cheatsheet_nmap.txt"
CHEATSHEET FOR NMAP
---------------------------------------------

namp -p- --open -T5 -v -n %IP% -oG %archivo.txt%

-p- --> Todos los puertos
--open --> Solo open, no filtered
-T5 --> Modo rapido y agresivo
-v --> verbose, mas info
-n --> No aplique resolucion dns ya que tarda mas
-oG --> Formato grepeable

---------------------------------------------

nmap -sC -sV -p%puerto1,puerto2% %IP% -oN %archivo.txt%

-sC --> Scripts por defecto de enumeracion
-sV --> Mostrar los servicios corriendo en el puerto
-p --> Los puertos
-oN --> Formato de nmap

---------------------------------------------

locate http-enum
nmap --script http-enum -p80 %IP% -oN webScan

http-enum --> Fuzzer web para mostrar posibles directorios y recursos en una web. Funciona como whatweb.

---------------------------------------------

EOF

#### CHEATSHEET
cat <<EOF > "$dir/cheatsheet.txt"
CHEATSHEET FOR OTHER MIERDAS
---------------------------------------------

ping -c %numero_de_paquetes% %IP% -R --> Traceroute guay

---------------------------------------------
TTLs:
64 *nix
128 Win
254 Solaris/AIX


---------------------------------------------

echo "cadena" | base64 --> Codifica a base64
echo "cadena" | base64 -d --> Decodifica base64

echo "cadena" | xxd --> Codifica a hexadecimal

EOF
