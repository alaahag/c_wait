# 'c_wait' - ConnectionWait v1.0

Features:
* Optimized for Docker images (including full support for the most popular docker-OS-images: <b>Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE</b>).
* Supporting lots of test-methods (to check for open-connection).
* You can choose to run by app using args or by the default values.
* You can add unlimited number of hosts.
* Allow connection-conditions ('<b>all</b>' hosts must be connected to complete the task, or '<b>any</b>' of them).
* Custom messages (easily editable from global values below).
* Simple, user-friendly and easy to use.

Methods tests-order:  
<b>Netcat</b>  
<b>Ncat</b>  
<b>Python</b>  
<b>Python3</b>  
<b>Bash</b>  
<b>cURL</b>  
<b>Wget</b>   (BusyBox version is not supported)  
<b>Telnet</b> (BusyBox version is not supported)  
<b>Socat</b>  
<b>Nmap</b>  
<b>NodeJS</b>  
<b>Perl</b>  
<b>Ruby</b>  
<b>PHP</b>  
<b>Scala</b>  
<b>GCC</b>  
<b>G++</b>  
<b>TCL</b>  
<b>JavaJDK</b>  
<b>Elixir</b>  
<b>GOLang</b>  

Default global values:  
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
