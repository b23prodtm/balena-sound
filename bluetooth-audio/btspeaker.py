#!/usr/bin/env python
import bluetooth, sys, os, re, subprocess, time
def parse_argv (myenv, argv, i, options, usage):
    """Parse script arguments recursively
    i -- index in both argv and myenv
    options -- Literals set of options, e.g. afh where -a, -f, -h are valid options as for -afh
    """
    if i >= len(argv):
        return
    pf = "-+[" + options + "]*"
    time = re.compile(pf + "d(uration)?.*")
    serv = re.compile(pf + "[su](uid)?.*")
    pport = re.compile(pf + "[p](rotocol)?.*")
    help = re.compile(pf + "h(elp)?.*")
    any = re.compile(pf)
    if i < len(argv):
        if time.match(argv[i]):
            myenv['BTSPEAKER_SCAN_DURATION'] = argv[i+1]
            del argv[i]
        elif serv.match(argv[i]):
            myenv['service'] = argv[i+1]
            del argv[i]
        elif pport.match(argv[i]):
            myenv['proto-port'] = argv[i+1]
            del argv[i]
        elif help.match(argv[i]):
            print(usage)
            sys.exit(0)
        elif any.match(argv[i]):
            del argv[i]
        elif re.compile("([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}").match(argv[i]):
            myenv["BTSPEAKER_SINK"] = argv[i]
        else:
            print("Wrong argument %s !" % argv[i])
            print(usage)
    parse_argv(myenv, argv, i+1, options, usage)

def bt_service(addr, proto_port="", *serv):
    for services in bluetooth.find_service(address=addr):
        if len(serv) > 0 and (services["name"] in serv or services["service-id"] in serv):
            return bt_connect(services["protocol"], addr, services["port"])
        else:
            print("  UUID: %s (%s)" % (services["name"], services["service-id"]))
            print("    Protocol: %s, %s, %s" % (services["protocol"], addr, services["port"]))
    if proto_port != "" and re.compile("[^:]+:[0-9]+").match(proto_port):
        s = proto_port.find(":")
        proto = proto_port[0:s]
        port = proto_port[s+1:]
        return bt_connect(proto, addr, port)

def bt_connect(proto, addr, port):
    timeout = 0
    while timeout < 5:
        try:
            print("  Attempting %s connection to %s (%s)" % (proto, addr, port))
            s = bluetooth.BluetoothSocket(int(proto))
            s.connect((addr,int(port)))
            print("Success")
            return s
        except bluetooth.btcommon.BluetoothError as err:
            print("%s\n" % (err))
            print("  Fail, probably timeout. Attempting reconnection... (%s)" % (timeout))
            timeout += 1
            time.sleep(1)
    print("  Service or Device not found")
    return None

def bt_connect_service(nearby_devices, btsink="00:00:00:00:00:00", proto_port="", serv=""):
    for addr, name in nearby_devices:
        sock = None
        if btsink == "00:00:00:00:00:00":
            print("  - %s , %s:" % (addr, name))
            sock = bt_service(addr, proto_port, serv)
        elif btsink == addr:
            print("  - found device %s , %s:" % (addr, name))
            sock = bt_service(addr, proto_port, serv)
        if sock:
            print("  - service %s available" % (serv))
            return sock

def main(argv):
    myenv = dict()
    main.defaults = dict()
    main.defaults = {
        "file":argv[0],
        "BTSPEAKER_SCAN_DURATION":"5",
        "service":"Audio Sink",
        "BTSPEAKER_SINK":"00:00:00:00:00:00",
        "proto-port": str(bluetooth.L2CAP) + ":25"
        }
    myenv.update(main.defaults)
    myenv.update(os.environ)
    parse_argv(myenv, argv, 1, 'sdhp', "Usage: {} [-h,--help] [-d,--duration <seconds>] [-s,--uuid <service-name>] [-p, --protocol <proto:port>] [bt-address]\n\
    defaults: {}".format(argv[0], main.defaults))
    print("looking for nearby devices...")
    try:
        nearby_devices = bluetooth.discover_devices(lookup_names = True, flush_cache = True, duration = int(myenv["BTSPEAKER_SCAN_DURATION"]))
        print("found %d devices" % len(nearby_devices))
        print("discovering %s services... %s" % (myenv["BTSPEAKER_SINK"], myenv["service"]))
        sock = bt_connect_service(nearby_devices, myenv["BTSPEAKER_SINK"], myenv["proto-port"], myenv["service"])
        if sock:
            # pair the new device as known device
            print("bluetooth pairing...")
            ps = subprocess.Popen("printf \"pair %s\\nexit\\n\" \"$1\" | bluetoothctl", shell=True, stdout=subprocess.PIPE)
            print(ps.stdout.read())
            ps.stdout.close()
            ps.wait()
            sock.close()
    except bluetooth.btcommon.BluetoothError as err:
        print(" Main thread error : %s" % (err))
        exit(1)

if __name__ == '__main__':
    main(sys.argv)
