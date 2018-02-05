import os 
import os.path 
import time 
import shlex 
import subprocess

path = "/var/lib/node_exporter/ne-stats.prom"

if os.path.exists(path):
        os.remove(path)

os.mkfifo(path)


while 1:
        fifo = open(path, "w")

        fifo.write("tomeshV 1\n")

        s=""
        if os.path.isfile("/sys/devices/virtual/thermal/thermal_zone0/temp"):
                with file("/sys/devices/virtual/thermal/thermal_zone0/temp") as f:
                    s = f.read()
                fifo.write("hw_temp ")
                fifo.write(s)

        command_line = "iw dev"
        args = shlex.split(command_line)
        interfaces = subprocess.Popen(args,stdout=subprocess.PIPE)
        interfaces.wait()
        output = interfaces.stdout.read();
        ints = output.split("\n")
        for int in ints:
            if int.find("Interface") > -1:
                    words = int.split()
                    currentitn=words[1]
                    command_line = "iw dev " + currentitn + " info"
                    args = shlex.split(command_line)
                    interface = subprocess.Popen(args,stdout=subprocess.PIPE)
                    interface.wait()
                    output = interface.stdout.read()
                    types = output.split("\n")
                    for type in types:
                        if type.find("type") > -1:
                                words2= type.split(" ")
                                if words2[1]  == "mesh":
                                        fifo.write("wlan_mesh{iface=\"" + currentitn + "\"} 1\n")
                                        command_line = "iw dev " + currentitn + " station dump"
                                        args = shlex.split(command_line)
                                        links = subprocess.Popen(args,stdout=subprocess.PIPE)
                                        links.wait()
                                        output = links.stdout.read()
                                        linksline = output.split("\n")
                                        station=""
                                        signal=""

                                        for link in linksline:
                                            if link <> "" :
                                                words3 = link.replace("\t"," ").split(" ")
                                                if words3[0].find("Station") > -1:
                                                    station=words3[1]
                                                    if words3[1].find("signal") > -1:
                                                        signal=words3[3]
                                                        if words3[1].find("mesh") > -1 and words3[2].find("plink") > -1:
                                                            linkstatus=words3[3]
                                                            if words3[1].find("rx") > -1 and words3[2].find("bytes") > -1:
                                                                rx=words3[3]
                                                                if words3[1].find("tx") > -1 and words3[2].find("bytes") > -1:
                                                                    tx=words3[3]
                                                                if words3[1].find("TDLS") > -1:
                                                                    fifo.write('mesh_node_signal{mac="' + station + '"} ' + signal + "\n")
#                                                                   fifo.write('mesh_node_status{mac="' + station + '"} ' + linkstatus + "\n")
                                                                    fifo.write('mesh_node_rx{mac="' + station + '"} ' + rx + "\n")
                                                                    fifo.write('mesh_node_tx{mac="' + station + '"} ' + tx + "\n")

        fifo.close()
        time.sleep(1)
