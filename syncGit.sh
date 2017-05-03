#!/bin/bash

sources=(
	~/Documents/Money
	~/Documents/School/SJSU
)

for source in ${sources[@]}; do
	echo $source

	git -C $source pull

	git -C $source add .
	git -C $source commit -m "Sync `date +'%Y-%m-%d'`"
	git -C $source push
done
