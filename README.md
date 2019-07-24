# 'c_wait' - ConnectionWait v1.2

<h3>Intro:</h3>  

'c_wait' is a PT and DevOps tool.  
The script will keep checking for open-connections for hosts/ports [args].  
When the task is complete: the script will exit successfully (or else it will exit with failure).  

<h3>Where can I use this script?</h3>  
When you wanna initialize a server + DB (using Kubernetes or Docker for example), but you don't wanna let the server run before DB-connection (or else: the server will fail on initialization).  

--------------------

<h3>What's new in v1.2:</h3>  

* Added a new option to display all supported and installed methods: [ ./c_wait.sh --installed ].  
* Full support for <b>BusyBox</b> version of <b>Telnet</b> and <b>Wget</b>.  
* Added more testing-methods (<b>SSH, MongoDB-Client, Groovy, Zsh, Ocaml</b>).  
* Fixed bugs.  
* Optimized methods and performance.  
* Optimzed code.  
* Deleted <b>GNAT(Ada)</b> method (not needed because it comes with <b>GCC</b>, and the <b>GCC</b> runs faster).  

--------------------

<h3>Features:</h3>  

* Optimized for Kubernetes and Docker images (including full support for the most popular OS-images: <b>Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage</b> and <b>openSUSE</b>).  
* In addition, support for: <b>BusyBox, Termux, macOS, RedHat, SUSELinux, ArchLinux, Mageia, GentooLinux, Endless and other Linux distributions</b>.  
* Supporting over 37 health-check methods, to check for open-connections.  
* Allow adding unlimited number of hosts.  
* Allow connection-mode:  
  @ 'all' hosts must be connected to complete the task.  
  @ 'any' of the hosts must be connected to complete the task.  
* Allow limited/infinity connection-retries.  
* Option to display the installed and supported methods on host machine.
* Custom methods and messages (easily editable from global values).  
* Simple, user-friendly and easy to use.  

* Methods (health-check) tests-order:  
<b>Netcat</b>  
<b>SSH</b>  
<b>Python</b>  
<b>Python3</b>  
<b>Bash</b>  
<b>cURL</b>  
<b>Wget</b>  
<b>Telnet</b>  
<b>Socat</b>  
<b>NodeJS</b>  
<b>Ruby</b>  
<b>Perl</b>  
<b>PHP</b>  
<b>Tcl</b>  
<b>OpenSSL</b>  
<b>Gawk</b>  
<b>Ncat</b>  
<b>Nmap</b>  
<b>Zsh</b>  
<b>MongoDB-Client</b>  
<b>Erlang</b>  
<b>Clojure</b>  
<b>Groovy</b>  
<b>Scala</b>  
<b>R</b>  
<b>PowerShell</b>  
<b>GCC</b>  
<b>Clang</b>  
<b>Elixir</b>  
<b>Java-JDK</b>  
<b>Rust</b>  
<b>Go</b>  
<b>Dart</b>  
<b>D</b>  
<b>Nim</b>  
<b>OCaml</b>  
<b>.NET</b>  

--------------------

<h3>Default global values [with args]:</h3>  

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
[ 'c_wait' - ConnectionWait v1.2 ]

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
     (minimal output? 'false')

Info:
  -i | --installed
     (display installed methods)

  -h | --help | /?
     (display this usage)
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

<h3>Considered but not added (why):</h3>  

```
* GNAT(Ada) + GFortran -> Because it comes with GCC, and the GCC is faster.  
* Scheme + Common Lisp + Haskell + Gforth -> Need to install some extra packages / libraries.  
* Swift -> We have Clang, and Swift runs slower than it.  
* Kotlin -> We have a JAVA-JDK, and Kotlin runs slower than it.  
* MySQL + PostgreSQL -> We might consider adding them (there's a small problem with timeout).  
```

--------------------

Contact me for anything: alaahag@gmail.com , +972527337763  
<h5>[PT & DevOPS developer, Looking for my next challenge].</h5>
