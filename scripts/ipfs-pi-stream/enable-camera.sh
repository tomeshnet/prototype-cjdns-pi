#!/usr/bin/env bash

# Enable camera on Raspberry Pi
# set_config_var taken from raspi-config
set_config_var() {
 lua - "$1" "$2" "$3" <<EOF > "$3.bak"
 local key=assert(arg[1])
 local value=assert(arg[2])
 local fn=assert(arg[3])
 local file=assert(io.open(fn))
 local made_change=false
for line in file:lines() do
  if line:match("^#?%s*"..key.."=.*$") then
    line=key.."="..value
    made_change=true
  end
  print(line)
end

if not made_change then
  print(key.."="..value)
end
EOF
sudo mv "$3.bak" "$3"
}

# Command extracted from raspi-config
sed /boot/config.txt -i -e "s/^startx/#startx/"
sed /boot/config.txt -i -e "s/^fixup_file/#fixup_file/"
set_config_var start_x 1 /boot/config.txt
set_config_var gpu_mem 128 /boot/config.txt
