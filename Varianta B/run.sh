# Sprincenatu Bogdan-Andrei 332CC

#!/bin/bash

tests="./tests"
out_dirr="./out"

mkdir "$out_dirr"

make

if [ $? -eq 0 ]; then
	i=0

	for file in "$tests"/*; do
		if [ -f "$file" ]; then
			./tema "$file" > "$out_dirr/$i.out"
			((i++))
		fi
	done
fi
