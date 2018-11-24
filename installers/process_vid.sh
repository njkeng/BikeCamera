#!/bin/bash

function process_video_files() {

	# String variables from video.ini
	vid_dir=$(sudo cat /etc/bikecamera/video/video.ini | grep --only-matching --perl-regexp "(?<=vid_dir = \")\S+(?=\")")

	# Numeric variables from video.ini
    cull_free_space=$(sudo cat /etc/bikecamera/video/video.ini | grep --only-matching --perl-regexp "(?<=cull_free_space = )\w+")

	# Numeric variables from status.ini
    status_current=$(sudo cat /etc/bikecamera/video/status.ini | grep --only-matching --perl-regexp "(?<=status_current = )\w+")


    # Process all of the video files in the 'completed' folder
    while : ; do

    	# # Check for camera recording
    	# if [ $status_current -gt 1 ]; then
    	# 	echo "Video is being recorded - skip processing"
    	# 	break
    	# fi

    	# Check for MP4Box already running
    	MP4Box_count=$(ps ax | grep -c MP4Box)
    	if [ $MP4Box_count -gt 1 ]; then
    		echo "MP4Box already running - will not start a second conversion"
    		break
    	fi

    	# Get the file name of the oldest video file in the folder
		input_file=$(find $vid_dir/completed -name '*.h264' -printf '%P\n' | sort | head -1)
		# Trim the file extension
		input_file=${input_file%'.h264'}

		# Check for all files completed
	    if [ "$input_file" == "" ]; then
	    	echo "Found no files to process"
	    	break
	    fi

	    # Execute the conversion command
	    sudo MP4Box -add $vid_dir/completed/$input_file.h264 $vid_dir/mp4/$input_file.mp4

	    # Remove the file after it has been processed
	    sudo rm $vid_dir/completed/$input_file.h264
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
		oldest_file=$(find $vid_dir -mindepth 1 -name 'vid*' -printf '%P\n' | sort | head -1)

		# Check if there are no more files to delete
		if [ "$oldest_file" == "" ]; then
			echo "There are no old files to delete"
			break
		fi

	    # Remove the file
	    echo "Deleting $oldest_file"
	    sudo rm $vid_dir/$oldest_file

	done

}

process_video_files
