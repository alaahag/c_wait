# 'c_wait' - ConnectionWait v1.0

<h3>Intro:</h3>  

<h5>'c_wait' is a DevOps and PT tool, the script will keep running and checking for open-connections for X hosts/ports.  
When the task is complete: the script will exit successfully (exit 0).  
If the script fails to run or fails to identify any method for test-connections: it will exit with failure (exit 1).</h5>  

<h3>Where can I use this script?</h3>  
<h5>When you need to initialize a server + db (with Kubernetes or Docker), but you can't let the server run without a db-connection up first (or else it will fail on initialization and your server will not run properly).</h5>  

--------------------

<h3>Features:</h3>  

* Optimized for K8s and Docker images (including full support for the most popular OS-images: <b>Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE</b>).  
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

<h3>Default global values:</h3>  

```
HOSTS="db:3306 db2:5432 0.0.0.0"  
SLEEP_TIME="3"  
CONNECT_TYPE="all"  
```

<h5>You can modify the default values (read the source-code comments).</h5>  

<h6>./c_wait --help</h6>  

     --------------------------------------------------------------------------
     -=-                   'c_wait' - ConnectionWait v1.0                   -=-
     --------------------------------------------------------------------------
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
    
--------------------

<h3>Example using Docker:</h3>  
<h6>cat docker-compose.yml:</h6>  

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

<h6>cat entrypoint_django_run.sh</h6>  

```
./c_wait.sh db:5432  
python3 manage.py runserver 0.0.0.0:8000  
```

--------------------

Contact me for anything: alaahag@gmail.com  
<h5>[DevOps, Automation & PT engineer, Looking for my next challenge].</h5>
