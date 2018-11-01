#!/bin/bash

function process_video_files() {

	# String variables from video.ini
	vid_dir=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=vid_dir = \")\S+(?=\")")

	# Numeric variables from video.ini
    cull_free_space=$(sudo cat /etc/pihelmetcam/video/video.ini | grep --only-matching --perl-regexp "(?<=cull_free_space = )\w+")

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
		oldest_file=$(find $vid_dir/completed -name 'vid*' -printf '%P\n' | sort | head -1)

		# Check if there are no more files to delete
		if [ "$oldest_file" == "" ]; then
			echo "There are no old files to delete"
			break
		fi

	    # Remove the file
	    echo "Deleting $oldest_file"
	    sudo rm $vid_dir/completed/$oldest_file

	done

}

process_video_files
