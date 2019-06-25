# 'c_wait' - ConnectionWait v1.0

<b>Intro:</b>  
'c_wait' is a DevOps tool, the script will keep running and checking for open-connections for X hosts.  
When the task is complete: the script will exit successfully (exit 0).

<b>Where can I use this script?</b>  
Let's say that you want to initialize a server + db with Docker, but you don't want to let the server run without a db-connection (or else it will fail).  

<b>Example with Docker:</b>  
cat docker-compose.yml:  
```
services:  
  db:  
    image: postgres  
    container_name: db  
    ..........  
    ..........  
    expose:  
      - '5432'
    networks:  
      - shared  
    ..........  
    ..........  

  django_app:  
    build: .  
    ..........  
    ..........  
    entrypoint: /var/www/my_app/entrypoint_django_run.sh  
    networks:  
      - shared  
    ..........  
    ..........  

networks:  
  shared:    
```
cat entrypoint_django_run.sh  
```
./c_wait.sh db:5432  
python3 manage.py runserver 0.0.0.0:8000  
```
--------------------
<b>Features:</b>  
* Optimized for Docker images (including full support for the most popular docker-OS-images: <b>Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE</b>).  
* Supporting lots of check-methods (to check for open-connection).  
* You can choose to run app using args or by the default values.  
* You can add unlimited number of hosts.  
* Allow connection-conditions ('<b>all</b>' hosts must be connected to complete the task, or '<b>any</b>' of them).  
* Custom messages (easily editable from global values).  
* Simple, user-friendly and easy to use.  

* Methods tests-order:  
<b>Netcat</b>  
<b>Ncat</b>  
<b>Python</b>  
<b>Python3</b>  
<b>Bash</b>  
<b>cURL</b>  
<b>Wget</b>     (BusyBox version is not supported)  
<b>Telnet</b>   (BusyBox version is not supported)  
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

--------------------

<b>Default global values:</b>  
```
<b>HOSTS</b>="db:3306 db2:5432 0.0.0.0"  
<b>SLEEP_TIME</b>="3"  
<b>CONNECT_TYPE</b>="all"  
```

For more help, read the source-code comments.  

./c_wait --help  

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

<br>
<br>
<br>

Contact me for anything: alaahag@gmail.com  
[DevOps, Automation & PT engineer, Looking for my next challenge]
