#!/bin/bash

function process_video_files() {

	# String variables
	ffmpeg_output_format=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=ffmpeg_output_format = \")\S+(?=\")")
	ffmpeg_output_dir=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=ffmpeg_output_dir = \")\S+(?=\")")
	ffmpeg_input_dir=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=ffmpeg_input_dir = \")\S+(?=\")")
	ffmpeg_vid_length=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=vid_length = )\S+")

	# Numeric variables
    cull_free_space=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=cull_free_space = )\w+")

    # Process all of the video files in the 'processing' folder
    while : ; do

    	# Check for ffmpeg already running
    	ffmpeg_count=$(ps ax | grep -c ffmpeg)
    	if [ $ffmpeg_count -gt 1 ]; then
    		echo "ffmpeg already running"
    		break
    	fi

    	# Get the file name of the oldest video file in the folder
		input_file=$(find $ffmpeg_input_dir -name '*.h264' -printf '%P\n' | sort | head -1)

		# Trim the file extension
		input_file=${input_file%'.h264'}

		# Check for all files completed
	    if [ "$input_file" == "" ]; then
	    	echo "Found no files to process"
	    	break
	    fi

	    # Assemble ffmpeg command string
	    # Add a blank audio track to the file.  Some editing software requires an audio track.
	    ffmpeg_audio_input="ffmpeg -i $ffmpeg_input_dir/silence_$ffmpeg_vid_length.mp3 "
	    # Specify the input video file
	    ffmpeg_video_input="-i $ffmpeg_input_dir/$input_file.h264 "
	    # Copy video and add audio
	    ffmpeg_command_body=" -c:v copy -c:a libmp3lame -strict experimental "
	    # Specify the output file
	    ffmpeg_command_output="$ffmpeg_output_dir/$input_file.$ffmpeg_output_format"
	    # Asemble the whole command string
	    full_ffmpeg=$ffmpeg_audio_input$ffmpeg_video_input$ffmpeg_command_body$ffmpeg_command_output
	    echo "Executing $full_ffmpeg"
	    # Execute the conversion command
	    sudo $full_ffmpeg

	    # Remove the file after it has been processed
	    sudo rm $ffmpeg_input_dir/$input_file.h264
    done

	# Calculate required free space in kB
	cull_kb=$(expr $cull_free_space \* 1024)
	echo "Required free space: $cull_kb kB"


	while : ; do

		# Get free disk space on the root partition
		df_output=$(df | grep root)
		read num1 num2 free_space num4 num5 <<<${df_output//[^0-9]/ }

		# If disk space is OK
		if [ $free_space -gt $cull_kb ]; then
			echo "Disk space is fine: $free_space kB"
			break
		else
			echo "Disk free space is insufficient: $free_space kB"
		fi

    	# Get the file name of the oldest video file in the folder
		oldest_file=$(find $ffmpeg_output_dir -name 'vid*' -printf '%P\n' | sort | head -1)

		# Check if there are no more files to delete
		if [ "$oldest_file" == "" ]; then
			echo "There are no old files to delete"
			break
		fi

	    # Remove the file
	    echo "Deleting $oldest_file"
	    sudo rm $ffmpeg_output_dir/$oldest_file

	done

}

process_video_files
