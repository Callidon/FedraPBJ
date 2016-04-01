#!/bin/bash
# modified version to output more details

prefix=$1
firstPort=$2
lastPort=$3

ir=0
nc=0
ic_tot = ""
nc_toto = ""

for i in  `seq $firstPort $lastPort`; do
   line=`tail -n 1 $prefix$i`
   x=${line% *}
   y=${line#* }
   ir=$(($ir+$x))
   nc=$(($nc+$y))
   irc_tot="${irc_tot} ${x}"
   nc_toto="${nc_toto} ${y}"
done

if [ -f "${prefix}PublicEndpoint" ]; then
  line=`tail -n 1 ${prefix}PublicEndpoint`
  x=${line% *}
  y=${line#* }
  ir=$(($ir+$x))
  nc=$(($nc+$y))
fi

echo "$ir $nc $irc_tot $nc_toto"
