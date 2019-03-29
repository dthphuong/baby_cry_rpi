PREDICTION=0
PLAYING=0
CPT=0

function clean_up {

	# Perform program exit housekeeping
	echo ""
	echo "Thank you for using parenting 2.1"
	echo "Good Bye."
	stop_playing
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM

function recording(){
	echo "Start Recording..."
	arecord -D plughw:0 -d 9 -f S16_LE -c1 -r44100 -t wav /home/pi/baby_cry_rpi/recording/signal_9s.wav
}


function predict() {
	echo "Predicting..."
	echo -n "What is the prediction? "
	python /home/pi/baby_cry_rpi/script/make_prediction.py
	PREDICTION=$(cat /home/pi/baby_cry_rpi/prediction/prediction.txt)
	echo "Prediction is $PREDICTION"
}

function start_playing() {
	if [[ $PLAYING == 0 ]]; then
		echo "start playing"
                aplay -D plughw:0 /home/pi/baby_cry_rpi/lullaby/lullaby_classic.wav
		PLAYING=1
	fi
}

function stop_playing(){
	if [[ $PLAYING == 1 ]]; then
		echo "stop playing"
		PLAYING=0
	fi
}

echo "Welcome to Parenting 2.1"
echo ""
while true; do
	recording
	predict
	if [[ $PREDICTION == 0 ]]; then
		stop_playing
	else
		CPT=$(expr $CPT + 1)
		start_playing
	fi
echo "State of the Process PREDICTION = $PREDICTION, PLAYING=$PLAYING, # TIMES MY BABY CRIED=$CPT"
done
clean_up
