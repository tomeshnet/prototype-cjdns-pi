#!/bin/bash

HLS_TIME=40
M3U8_SIZE=3
IPFS_GATEWAY="https://ipfs.io"

# Load settings

# Prepare Pi Camera
sudo modprobe bcm2835-v4l2
sudo v4l2-ctl --set-ctrl video_bitrate=100000

function startFFmpeg() {
  while true; do
    mv ~/ffmpeg.log ~/ffmpeg.1
    echo 1 > ~/stream-reset
    
    # Stream Raspberry Pi Camera
    ffmpeg -f video4linux2 -input_format h264 -video_size 1280x720 -framerate 30 -i /dev/video0 -vcodec copy -hls_time "${HLS_TIME}" "${what}.m3u8" > ~/ffmpeg.log 2>&1

    # Stream FM Station from a SDR module (see contrib/pi-stream to install drivers)
    # Frequency ends in M IE 99.9M
    # rtl_fm  -f 99.9M -M fm -s 170k -A std -l0 -E deemp -r 44.1k | ffmpeg  -r 15 -loop 1 -i ../audio.jpg  -f s16le -ac 1 -i pipe:0 -c:v libx264 -tune stillimage -preset ultrafast  -hls_time "${HLS_TIME}" "${what}.m3u8"  > ~/ffmpeg 2>&1
    
    sleep 0.5
  done
}

# Create directory for HLS content

currentpath="$HOME/live"
sudo umount "${currentpath}"
rm -rf "${currentpath}"
mkdir "${currentpath}"
sudo mount -t tmpfs tmpfs "${currentpath}"
# shellcheck disable=SC2164
cd "${currentpath}"

what="$(date +%Y%m%d%H%M)-LIVE"

# Start ffmpeg in background
startFFmpeg &

while true; do
#TODO# Fix this one
# shellcheck disable=SC2086,SC2012
  nextfile=$(ls -tr ${what}*.ts 2>/dev/null | head -n 1)

  if ! [ -z "${nextfile}" ]; then
    # Check if the next file on the list is still being written to by ffmpeg
    if lsof "${nextfile}" | grep -1 ffmpeg; then
      # Wait for file to finish writing
      # If not finished in 45 seconds something is wrong, timeout
      inotifywait -e close_write "${nextfile}" -t ${HLS_TIME}
    fi

    # Grab the timecode from the m3u8 file so we can add it to the log
    timecode=$(grep -B1 "${nextfile}" "${what}.m3u8" | head -n1 | awk -F : '{print $2}' | tr -d ,)
    attempts=5
    until [[ "${timecode}" || ${attempts} -eq 0 ]]; do
      # Wait and retry
      sleep 0.5
      timecode=$(grep -B1 "${nextfile}" "${what}.m3u8" | head -n1 | awk -F : '{print $2}' | tr -d ,)
      attempts=$((attempts-1))
    done

    if ! [[ "${timecode}" ]]; then
      # Set approximate timecode
      timecode="${HLS_TIME}.000000"
    fi

    reset_stream=$(cat ~/stream-reset)
    reset_stream_marker=''
    if [[ ${reset_stream} -eq '1' ]]; then
      reset_stream_marker=" #EXT-X-DISCONTINUITY"
    fi

    echo 0 > ~/stream-reset
    # Current UTC date for the log
    time=$(date "+%F-%H-%M-%S")

    # Add ts file to IPFS
    ret=$(ipfs add --pin=false "${nextfile}" 2>/dev/null > ~/tmp.txt; echo $?)
    attempts=5
    until [[ ${ret} -eq 0 || ${attempts} -eq 0 ]]; do
      # Wait and retry
      sleep 0.5
      ret=$(ipfs add --pin=false "${nextfile}" 2>/dev/null > ~/tmp.txt; echo $?)
      attempts=$((attempts-1))
    done
    if [[ ${ret} -eq 0 ]]; then
      # Update the log with the future name (hash already there)
      echo "$(cat ~/tmp.txt) ${time}.ts ${timecode}${reset_stream_marker}" >> ~/process-stream.log

      # Remove nextfile and tmp.txt
      rm -f "${nextfile}" ~/tmp.txt

      # Write the m3u8 file with the new IPFS hashes from the log
      totalLines="$(wc -l ~/process-stream.log | awk '{print $1}')"

      sequence=0
      if ((totalLines>M3U8_SIZE)); then
          sequence=$((totalLines-M3U8_SIZE))
      fi
      {
        echo "#EXTM3U"
        echo "#EXT-X-VERSION:3"
        echo "#EXT-X-TARGETDURATION:${HLS_TIME}"
        echo "#EXT-X-MEDIA-SEQUENCE:${sequence}"
      }  > current.m3u8
      tail -n ${M3U8_SIZE} ~/process-stream.log | awk '{print $6"#EXTINF:"$5",\n'${IPFS_GATEWAY}'/ipfs/"$2}' | sed 's/#EXT-X-DISCONTINUITY#/#EXT-X-DISCONTINUITY\n#/g' >> current.m3u8

      # Add m3u8 file to IPFS and IPNS publish
      m3u8hash=$(ipfs add current.m3u8 | awk '{print $2}')
      ipfs name publish --timeout=5s "${m3u8hash}" &

      # Copy files to web server
      cp current.m3u8 /var/www/html/live.m3u8
      cp ~/process-stream.log /var/www/html/live.log
    fi
  else
    sleep 5
  fi
done
