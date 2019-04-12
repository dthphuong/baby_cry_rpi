PREDICTION=0
PLAYING=0
CPT=0

function clean_up {
	# Perform program exit housekeeping
	echo ""
	echo "Thank you for using our product !!!"
	echo "Good Bye."
	stop_playing
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM

function recording(){
	echo "Listening . . . . ."
	arecord -D plughw:0 -d 9 -f S16_LE -c1 -r44100 -t wav /opt/baby_cry_rpi/recording/signal_9s.wav
}


function predict() {
	echo "Predicting . . . . ."
	python /opt/baby_cry_rpi/script/make_prediction.py
	PREDICTION=$(cat /opt/baby_cry_rpi/prediction/prediction.txt)
	# echo "Prediction is $PREDICTION"
}

function start_playing() {
	if [[ $PLAYING == 0 ]]; then
		echo "Start playing a lullaby. . ."
                aplay -D plughw:0 /opt/baby_cry_rpi/lullaby/lullaby_classic.wav
		PLAYING=1
	fi
}

function stop_playing(){
	if [[ $PLAYING == 1 ]]; then
		echo "Stop playing"
		PLAYING=0
	fi
}

# Main program
clear
echo "================================================"
echo "==========Welcome to Baby Cry Detector=========="
echo "=========Develop by FPO AI Research Team========"
echo "================================================"
echo "Using KT AI Maker Kit and Raspberry PI 3B+"
echo "Reference: https://github.com/giulbia/baby_cry_detection"
echo ""

amixer set 'PCM' 90%
while true; do
	recording
	predict
	if [[ $PREDICTION == 0 ]]; then
		stop_playing
	else
		CPT=$(expr $CPT + 1)
		start_playing
	fi
echo "===> PREDICTION = $PREDICTION, PLAYING=$PLAYING, # TIMES MY BABY CRIED=$CPT"
done
clean_up
