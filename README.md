## 'c_wait' - ConnectionWait v1.3

### Intro:  

**'c_wait'** is a PenetrationTesting and DevOps tool.  
The script will keep checking for open-connections for hosts/ports [args].  
When the task is complete: the script will exit successfully (or else it will exit with failure).  

### Where can I use this script?  
When you wanna initialize a server + DB (using Kubernetes or Docker for example), but you don't wanna let the server run before DB-connection (or else: the server will fail on initialization).  

---

<h4>Changelog v1.3:</h4>  

- Added more testing-methods (_CQL-shell, Racket, Guile, Julia, Ocaml_).  
- Fixed bugs.  
- Optimized methods.  
- Optimized code.  
- Typo and usage.  
- More validations.  

<h4>Changelog v1.2:</h4>  

- Added a new option to display all supported and installed methods: [ ./c_wait.sh --installed ].  
- Full support for the latest _BusyBox_ version of _Telnet_ and _Wget_.  
- Added more testing-methods (_SSH, MongoDB-Client, Groovy, Zsh, Ocaml_).  
- Fixed bugs.  
- Optimized methods and performance.  
- Optimzed code.  
- Deleted _GNAT(Ada)_ method (not needed because it comes with _GCC_, and the _GCC_ runs faster).  

---

### Features:  

>1. Optimized for _Kubernetes_ and _Docker_ images (including full support for the most popular OS-images: _Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage_ and _openSUSE_).  
>2. In addition, support for: _BusyBox, Termux, macOS, RedHat, SUSELinux, ArchLinux, Mageia, GentooLinux, Endless, OpenBSD, FreeBSD, Solus, Guix, Slackware_ and other Linux distributions.  
>3. Supporting over 41 health-check methods, to check for open-connections.  
>4. Allow adding unlimited number of hosts.  
>5. Allow connection-mode:  
  @ 'all' hosts must be connected to complete the task.  
  @ 'any' of the hosts must be connected to complete the task.  
>6. Allow limited/forever connection-retries.  
>7. Option to display the installed and supported methods on host machine.  
>8. Custom methods and messages (easily editable from global values).  
>9. Simple, user-friendly and easy to use.  

<h4>Methods (health-check) tests-order:</h4>  

1. _Netcat_  
2. _Bash_  
3. _SSH_  
4. _cURL_  
5. _Wget_  
6. _Telnet_  
7. _Gawk_  
8. _Zsh_  
9. _Ncat_  
10. _Nmap_  
11. _Socat_  
12. _Python_  
13. _Python3_  
14. _NodeJS_  
15. _Ruby_  
16. _Perl_  
17. _PHP_  
18. _Tcl_  
19. _OpenSSL_  
20. _Scala_  
21. _CQL-shell_  
22. _MongoDB-Client_  
23. _Groovy_  
24. _R_  
25. _Erlang_  
26. _Clojure_  
27. _Racket_  
28. _Guile_  
29. _Julia_  
30. _PowerShell_  
31. _GCC_  
32. _Clang_  
33. _Elixir_  
34. _Java-JDK_  
35. _Rust_  
36. _Go_  
37. _Dart_  
38. _D_  
39. _Nim_  
40. _OCaml_  
41. _.NET_  

---

### Default global values  

 <h4>[with args]:</h4> 

```
HOSTS="8.8.8.8:53 db:3306"  
SLEEP_TIME="3"  
RETRIES_COUNT="0"  
CONNECT_MODE="all"  
IS_QUIET_MODE="no"  
```

<h4>[without args]:</h4>

```
METHODS="nc bash ssh curl wget telnet gawk zsh ncat nmap socat python python3 node ruby perl php tclsh openssl scala cqlsh mongo groovy Rscript erl clojure racket guile julia pwsh gcc clang elixirc javac rustc go dart dmd nim ocaml dotnet"

TIMEOUT="2"

readonly INIT_MESSAGE="'c_wait' - Initializing ..."
readonly CONNECT_MESSAGE="'c_wait' - Connection Succeed!"
readonly FAIL_MESSAGE="'c_wait' - Connection Failed!"
readonly DONE_MESSAGE="'c_wait' - Task Completed :)"
readonly QUIT_MESSAGE="'c_wait' - Terminated!"
```

<h5>You can modify the default values (read the source-code comments).</h5>  

<h6>./c_wait --help</h6>  

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
    
---

<h3>Issues:</h3>  

<h5>Methods:</h5>

- _Mongo-shell_: will not be able to connect to '0.0.0.0' (connection will fail).  

<h5>Bugs:</h5>

- No known bugs.

---

### Example using Docker: 

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

---

### Considered but not added (methods): 

> 1. _GNAT(Ada) + GFortran_ -> It comes installed with GCC, and the GCC is runs better (performance).  
> 2. _Common Lisp + Haskell + Gforth_ -> Need to install some extra packages / libraries (not good for us).  
> 3. _Swift_ -> We have the Clang, and Swift depends on it, runs slower.  
> 4. _Kotlin_ -> We have the JAVA-JDK, and Kotlin depends on it, runs slower.  
> 5. _MySQL + PostgreSQL_ -> the client version is not fully supported for all OSes.  

---

Contact me for any ideas, help and support: alaahag@gmail.com , +972527337763  
<h5>[PT & DevOPS developer, Looking for my next challenge].</h5>
