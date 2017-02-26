#!/bin/bash

me="${0} >>"
usage="Usage: $0 .asm-file"
nasm="/usr/bin/nasm"
ld="/usr/bin/ld"
gcc="/usr/bin/gcc"

if [ -z $1 ]; then
	echo "$me $usage"
	exit
fi

filename=${1%%.*}	# Extract file name

$nasm -f elf -l ${filename}.lst -o ${filename}.o ${1}	# Assemble
#$ld -m elf_i386 -o ${filename} ${filename}.o	# Link
$gcc -m32 -o ${filename} ${filename}.o

echo "$me Assembled and linked $filename"
