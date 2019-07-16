# 'c_wait' - ConnectionWait v1.1

<h3>Intro:</h3>  

<h4>'c_wait' is a PT and DevOps tools. The script will keep checking for open-connections for X hosts/ports.  
When the task is complete: the script will exit successfully (or else it will exit with failure).</h4>  

<h3>Where can I use this script?</h3>  
<h4>When you want to initialize a server + db (Kubernetes or Docker for example), but you don't want to let the server run before DB-connection up (or else: the server will fail on initialization).</h4>  

--------------------

<h3>Features:</h3>  

* Optimized for Kubernetes and Docker images (including full support for the most popular OS-images: <b>Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE</b>).  
* In addition, including support for: <b>BusyBox, Termux, macOS, Red Hat, SUSE Linux, Manjaro, Endless and other Linux distributions</b>.  
* Supporting various health-check methods, to check for open-connections.  
* Allow adding unlimited number of hosts.  
* Allow connection-mode:  
  @ 'all' hosts must be connected to complete the task.  
  @ 'any' of the hosts must be connected to complete the task.  
* Allow limited/infinity connection-retries.  
* Custom methods and messages (easily editable from global values below).  
* Simple, user-friendly and easy to use.  

* Methods tests-order:  
<b>Netcat</b>  
<b>Ncat</b>  
<b>Python2</b>  
<b>Python3</b>  
<b>Bash</b>  
<b>cURL</b>  
<b>Wget</b>      (BusyBox version is not supported)  
<b>Telnet</b>    (BusyBox version is not supported)  
<b>Socat</b>  
<b>NodeJS</b>  
<b>Perl</b>  
<b>Ruby</b>  
<b>PHP</b>  
<b>TCL</b>  
<b>Erlang</b>  
<b>Gawk</b>  
<b>Nmap</b>  
<b>Scala</b>  
<b>R</b>  
<b>PowerShell</b>  
<b>GCC</b>  
<b>Clang</b>  
<b>Java JDK</b>  
<b>Elixir</b>  
<b>Rust</b>  
<b>Go</b>  
<b>Dart</b>  
<b>D</b>  
<b>Nim</b>  
<b>.NET</b>   

--------------------

<h3>Default global values:</h3>  

```
HOSTS="8.8.8.8:53 db:3306"  
SLEEP_TIME="3"  
RETRIES_COUNT="inf"  
CONNECT_MODE="all"  
IS_QUIET_MODE="false"  
```

<h5>You can modify the default values (read the source-code comments).</h5>  

<h6>./c_wait --help</h6>  

```
['c_wait' - ConnectionWait v1.1.0]

Usage:
  ./c_wait.sh --connect <'all'/'any'>
     --sleep <secs> --retry <num/'inf'>
     <hosts:ports ...>

Examples:
  ./c_wait.sh --sleep 4 ftp:21 192.168.1.1:22
  ./c_wait.sh --quiet -s 10 -r 3 myserver:8000
  ./c_wait.sh -c any -q localhost myftp:21
  ./c_wait.sh --connect all --retry 4 srv:86

Options and default values:
  <hosts:ports ...>
     ('8.8.8.8:53 db:3306')

  -c | --connect <'all'/'any'>
     ('all' of the selected hosts)

  -s | --sleep <seconds>
     ('3' seconds)

  -r | --retry <number/'infinity'>
     ('infinity' connection-retries)

  -q | --quiet
     (minimal output messages? 'false')

  -h | --help | /?
     (show this usage)
```
    
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

Contact me for anything: alaahag@gmail.com , +972527337763  
<h5>[PT & DevOPS developer, Looking for my next challenge].</h5>
