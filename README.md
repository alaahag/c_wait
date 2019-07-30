# 'c_wait' - ConnectionWait v1.3

### Intro:  

**'c_wait'** is a PenetrationTesting and DevOps tool.  
The script will keep checking for open-connections for hosts/ports [args].  
When the task is complete: the script will exit successfully (or else it will exit with failure).  

### Where can I use this script?  
When you wanna initialize a server + DB (using Kubernetes or Docker for example), but you don't wanna let the server run before DB-connection (or else: the server will fail on initialization).  

--------------------

<h4>Changelog v1.3:</h4>  

- Added more testing-methods (_CQL-shell, Racket, Guile, Julia, Ocaml_).  
- Fixed bugs.  
- Optimized methods.  
- Optimized code.  
- Typo and usage.  
- More validations.  

<h4>Changelog v1.2:</h4>  

- Added a new option to display all supported and installed methods: [ ./c_wait.sh --installed ].  
- Support for latest _BusyBox_ version of _Telnet_ and _Wget_.  
- Added more testing-methods (_SSH, MongoDB-Client, Groovy, Zsh, Ocaml_).  
- Fixed bugs.  
- Optimized methods and performance.  
- Optimzed code.  
- Deleted _GNAT(Ada)_ method (not needed because it comes with _GCC_, and the _GCC_ runs faster).  

--------------------

### Features:  

- Optimized for Kubernetes and Docker images (including full support for the most popular OS-images: _Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage_ and _openSUSE_).  
- In addition, support for: _BusyBox, Termux, macOS, RedHat, SUSELinux, ArchLinux, Mageia, GentooLinux, Endless, Solus, Guix, Slackware_ and other Linux distributions.  
- Supporting over 41 health-check methods, to check for open-connections.  
- Allow adding unlimited number of hosts.  
- Allow connection-mode:  
  @ 'all' hosts must be connected to complete the task.  
  @ 'any' of the hosts must be connected to complete the task.  
- Allow limited/forever connection-retries.  
- Option to display the installed and supported methods on host machine.
- Custom methods and messages (easily editable from global values).  
- Simple, user-friendly and easy to use.  

* Methods (health-check) tests-order:  
**Netcat**  
**Bash**  
**SSH**  
**cURL**  
**Wget**  
**Telnet**  
**Gawk**  
**Zsh**  
**Ncat**  
**Nmap** 
**Socat**  
**Python**  
**Python3**  
**NodeJS**  
**Ruby**  
**Perl**  
**PHP**  
**Tcl**  
**OpenSSL**  
**Scala**  
**CQL-shell**  
**MongoDB-Client** 
**Groovy**  
**R**  
**Erlang**  
**Clojure**  
**Racket**  
**Guile**  
**Julia**  
**PowerShell**  
**GCC**  
**Clang**  
**Elixir**  
**Java-JDK**  
**Rust**  
**Go**  
**Dart**  
**D**  
**Nim**  
**OCaml**  
**.NET**  

--------------------

### Default global values [with args]:  

```
HOSTS="8.8.8.8:53 db:3306"  
SLEEP_TIME="3"  
RETRIES_COUNT="0"  
CONNECT_MODE="all"  
IS_QUIET_MODE="no"  
```

<h4>You can modify the default values (read the source-code comments).</h4>  

<h5>./c_wait --help</h5>  

```
[ 'c_wait' - ConnectionWait v1.3 ]

Usage:
  ./c_wait.sh --connect <'all'/'any'>
     --sleep <secs> --retry <num/'forever'>
     <hosts:ports ...>

Examples:
  ./c_wait.sh --sleep 4 ftp:21 192.168.1.1:22
  ./c_wait.sh --quiet -s 10 -r 3 myserver:8000
  ./c_wait.sh -c any -q localhost myftp:21
  ./c_wait.sh --connect all --retry 4 tln:25

Options and default values:
  <hosts:ports ...>
     ('8.8.8.8:53 db:3306')

  -c | --connect <'all'/'any'>
     ('all' of the selected hosts)

  -s | --sleep <seconds>
     ('3' seconds)

  -r | --retry <number/'forever'>
     (connection-retries: 'forever')

  -q | --quiet
     (minimal output? 'no')

Display info:
  -i | --installed
     (display installed methods)

  -h | --help | /?
     (display this usage)
```
    
--------------------

<h3>Known issues:</h3>  

- Mongo-shell: will not connect to all interfaces '0.0.0.0'.

--------------------

### Example using Docker: 

<h4>cat docker-compose.yml:</h4>  

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

<h4>cat entrypoint_django_run.sh</h4>  

```
./c_wait.sh db:5432  
python3 manage.py runserver 0.0.0.0:8000  
```

--------------------

### Considered but not added: 

```
* GNAT(Ada) + GFortran -> It comes installed with GCC, and the GCC is runs better (performance).  
* Common Lisp + Haskell + Gforth -> Need to install some extra packages / libraries (not good for us).  
* Swift -> We have the Clang, and Swift depends on it, runs slower.  
* Kotlin -> We have the JAVA-JDK, and Kotlin depends on it, runs slower.  
* MySQL + PostgreSQL -> the client version is not fully supported for all OSes.  
```

--------------------

Contact me for any ideas, help and support: alaahag@gmail.com , +972527337763  
<h5>[PT & DevOPS developer, Looking for my next challenge].</h5>
