# 'c_wait' ConnectionWait v1.0

Features:
* Optimized for Docker images (including full support for the most popular docker-OS-images: Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE).
* Supporting lots of test-methods (to check for open-connection).
* You can choose to run by app using args or by the default values.
* You can add unlimited number of hosts.
* Allow connection-conditions
    (1. 'all' hosts must be connected to complete the task.
    (2. 'any' of the hosts must be connected to complete the task.
* Custom messages (easily editable from global values below).
* Simple, user-friendly and easy to use.

- Methods test-order:
nc ncat python python3 bash curl wget telnet socat nmap node perl ruby php scala gcc g++ tclsh javac elixirc go

Note: telnet & wget (the BusyBox versions only) are not supported!

- Default global values:
HOSTS="db:3306 db2:5432 0.0.0.0"
SLEEP_TIME="3"
CONNECT_TYPE="all"

For help, type:
./c_wait.sh /?

    "--------------------------------------------------------------------------"
    "-=-                   'c_wait' - ConnectionWait v1.0                   -=-"
    "--------------------------------------------------------------------------"
      Usage:    ./c_wait --connect <all/any> --sleep <seconds> <hosts:ports>
     
      Examples:
                ./c_wait 192.168.1.1:22
                ./c_wait -s 10 myserver:8000
                ./c_wait -c any localhost mydb1:5432 mydb2:3306 myftp:21
                ./c_wait --connect all -sleep 5 google.com 0.0.0.0:443
     
      Default options:
                Hosts:              'db:3306 db2:5432 0.0.0.0'
                -c|--connect        'all' of the selected host(s)
                -s|--sleep          '3' second(s)
    


(Don't forget to chmod +x c_wait.sh before running it) ;)


Contact me for anything: alaahag@gmail.com
