import os
import os.path
import time
import shlex
import subprocess


path = "/var/lib/node_exporter/ne-ubnt.prom"
if os.path.exists(path):
        os.remove(path)

os.mkfifo(path)

while 1:
        fifo = open(path, "w")

        command_line = "snmpwalk -v 1 -c tomesh 192.168.1.20 1.3.6.1.4.1.41112"
        args = shlex.split(command_line)
        interfaces = subprocess.Popen(args,stdout=subprocess.PIPE)
        interfaces.wait()
        output = interfaces.stdout.read();
        ints = output.split("\n")
        for int in ints:
                res = int.split("=")
                if res[0]=="iso.3.6.1.4.1.41112.1.4.1.1.6.1 ":
                        res2=res[1].split(":")
                        fifo.write("ubnt_power " + res2[1].strip() + "\n")
                if res[0]=="iso.3.6.1.4.1.41112.1.4.1.1.7.1 ":
                        res2=res[1].split(":")
                        fifo.write("ubnt_disatance " + res2[1].strip() + "\n")
                if res[0]=="iso.3.6.1.4.1.41112.1.4.1.1.4.1 ":
                        res2=res[1].split(":")
                        fifo.write("ubnt_freq " + res2[1].strip() + "\n")
                if res[0]=="iso.3.6.1.4.1.41112.1.4.5.1.5.1 ":
                        res2=res[1].split(":")
                        fifo.write("ubnt_signal_rx " + res2[1].strip() + "\n")
                if res[0]=="iso.3.6.1.4.1.41112.1.4.5.1.8.1 ":
                        res2=res[1].split(":")
                        fifo.write("ubnt_signal_tx " + res2[1].strip() + "\n")
        fifo.close()
        time.sleep(1)
