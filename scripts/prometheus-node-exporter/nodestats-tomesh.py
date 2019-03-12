import os
import os.path
import time
import shlex
import subprocess
import json

path = "/var/lib/node_exporter/ne-stats.prom"

if os.path.exists(path):
        os.remove(path)

os.mkfifo(path)

while 1:
        fifo = open(path, "w")

        fifo.write("tomeshV 1.2\n")
        try:
                s=""
                if os.path.isfile("/sys/devices/virtual/thermal/thermal_zone0/temp"):
                        with file("/sys/devices/virtual/thermal/thermal_zone0/temp") as f:
                            s = f.read()
                        fifo.write("hw_temp ")
                        fifo.write(s)


                # Wireless Link Dump

                # Get cjdns peer information
                remotePeers = {}
                myaddress=""
                if os.path.isfile("/opt/cjdns/tools/cexec"):
                    command_line = "/opt/cjdns/tools/cexec \"Core_nodeInfo()\""
                    args = shlex.split(command_line)
                    interfaces = subprocess.Popen(args,stdout=subprocess.PIPE)
                    interfaces.wait()
                    output = interfaces.stdout.read();
                    try:
                            data = json.loads(output)
                            tmp=data["myAddr"].split(".")
                            myaddress=tmp[5] + ".k"
                            myaddress=myaddress.splitlines()[0]
                            command_line = "/opt/cjdns/tools/peerStats"
                            args = shlex.split(command_line)
                            interface = subprocess.Popen(args,stdout=subprocess.PIPE)
                            interface.wait()
                            output = interface.stdout.read()
                            peers = output.split("\n")
                            for peer in peers:
                                words2= peer.split(" ")
                                if len(words2) > 1:
                                        tmp=words2[1].split(".")
                                        remotePubKey=tmp[5] + ".k"
                                        remotePeers[words2[0]]=remotePubKey
                    except:
                        pass
                # Look through wireless interfaces
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

                            # Read mac address from system file
                            with open("/sys/class/net/" + currentitn + "/address") as f:
                                mac = f.readlines()
                            mac = [x.strip() for x in mac][0]

                            command_line = "iw dev " + currentitn + " info"
                            args = shlex.split(command_line)
                            interface = subprocess.Popen(args,stdout=subprocess.PIPE)
                            interface.wait()
                            output = interface.stdout.read()
                            types = output.split("\n")
                            for type in types:
                                if type.find("type") > -1:
                                        words2= type.split(" ")
                                        if (words2[1]  == "mesh") or (words2[1] == "IBSS"):
                                                meshtype=words2[1]
                                                fifo.write("wlan_mesh{type=\"" + meshtype + "\", iface=\"" + currentitn + "\"} 1\n")

                                                # Loop through connected stations
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
                                                            linkstatus=""
                                                            rx=-1
                                                            tx=-1
                                                            signal=-100
                                                            cjdnsdata=""
                                                            if station in remotePeers:
                                                                cjdnsdata=',sourcekey="' + myaddress + '", key="' + remotePeers[station] + '"'
                                                        if words3[1].find("signal") > -1:
                                                            signal=words3[3]
                                                        if words3[1].find("mesh") > -1 and words3[2].find("plink") > -1:
                                                             linkstatus=words3[3]
                                                        if words3[1].find("rx") > -1 and words3[2].find("bytes") > -1:
                                                              rx=words3[3]
                                                        if words3[1].find("tx") > -1 and words3[2].find("bytes") > -1:
                                                               tx=words3[3]
                                                        if words3[1].find("TDLS") > -1:
                                                               fifo.write('mesh_node_signal{sourcemac="' + mac + '",mac="' + station + '",link="' + linkstatus + '"' + cjdnsdata + '} ' + signal + "\n")
                                                               fifo.write('mesh_node_rx{sourcemac="' + mac + '",mac="' + station + '"} ' + rx + "\n")
                                                               fifo.write('mesh_node_tx{sourcemac="' + mac + '",mac="' + station + '"} ' + tx + "\n")


                if os.path.isfile("/usr/bin/yggdrasilctl"):
                    args = shlex.split("sudo /usr/bin/yggdrasilctl -json getPeers")
                    interfaces = subprocess.Popen(args,stdout=subprocess.PIPE)
                    interfaces.wait()
                    raw_json = interfaces.stdout.read();
                    try:
                        peers = json.loads(raw_json.decode())

                        for peer,data in peers["peers"].items():
                                fifo.write('mesh_node_ygg_peer_rx{peer="'+peer+'",endpoint="'+str(data["endpoint"])+'"}'+" "+str(data["bytes_recvd"])+"\n")
                                fifo.write('mesh_node_ygg_peer_tx{peer="'+peer+'",endpoint="'+str(data["endpoint"])+'"}'+" "+str(data["bytes_sent"])+"\n")
                    except:
                        pass
        except:
                fifo.write('mesh_node_error 1\n')
        fifo.close()
        time.sleep(1)
