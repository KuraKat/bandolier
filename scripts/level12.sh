# Set up
MYDIR=$(mktemp -d)
cp data.txt $MYDIR/
cd $MYDIR
xxd -r data.txt data

# The loop
while true; do
	FTYPE=$(file -b data)
	echo -e "\n[!] Current TYPE: $FTYPE"

	if [[ "$FTYPE" == *"gzip"* ]]; then
		mv data data.gz
		gunzip data.gz
		#  Other potential versions
		[ -f data.gz ] && mv data.gz data
		[ -f data.out ] && mv data.out data

	elif [[  "$FTYPE" == *"bzip2"* ]]; then
		mv data data.bz2
		bunzip2 data.bz2
		[ -f data.out ] && mv data.out data

	elif [[ "$FTYPE" == *"tar"* ]]; then
		INTERNAL_FILE=$(tar -tf data | head -n 1)
		tar -xf data
		mv "$INTERNAL_FILE" data

	elif [[ "$FTYPE" == *"ASCII text"* ]]; then
		echo -e "\n[!] FINAL FILE REACHED"
		echo -n "RESULT:"
		cat data | awk '{print $NF}'
		break
	else
		echo "Stuck at: $FTYPE"
		exit
	fi
done
