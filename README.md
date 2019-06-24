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
                Hosts:              '$HOSTS'
                -c|--connect        '$CONNECT_TYPE' of the selected host(s)
                -s|--sleep          '$SLEEP_TIME' second(s)
    


(Don't forget to chmod +x c_wait.sh before running it) ;)


Contact me for anything: alaahag@gmail.com
