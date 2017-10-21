#!/bin/bash
# Skript pro prevod PNM obrazku do zdrojaku assembleru => prevod do VGA barev
# => $1 PNM obrazek
# => $2 VGA template do GIMPu
# => $3 Vystupni ASM soubor
# => $4 Nazev obrazku (navesti v ASM souboru)
sed '1,4d;:a;N;$!ba;s/\n/ /g;s/\([0-9]*\) \([0-9]*\) \([0-9]*\) /\1x\2x\3\n/g' $1 > doufamzesenetrefimdonejakehosouboru.txt
echo -ne "$4: \ndb " > doufamzesenetrefimdonejakehosouboru2.txt
cat doufamzesenetrefimdonejakehosouboru.txt | while read line; do
	printf '0x%x,' "$(cat $2 | sed '1,4d;s/ Untitled//g;s/ /x/g' | grep -n -m 1 "$line" | sed 's/:.*$/-1/g' | bc)" >> doufamzesenetrefimdonejakehosouboru2.txt
done
cat doufamzesenetrefimdonejakehosouboru2.txt > $3
rm doufamzesenetrefimdonejakehosouboru*
