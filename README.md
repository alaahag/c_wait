## 'c_wait' - ConnectionWait v1.4

### Intro:  

**'c_wait'** is a PenetrationTesting and DevOps tool **[an advanced health-check tool]**.  
The script checks for open-connections (using user-input [args]).  
When the task is complete: It will exit successfully (or with failure).  

### Examples, Where can I use this script?  
- <h5>DevOps and automations: Health-check for databases before initializing the servers.</h5>  
- <h5>PenetrationTesting: Display current installed health-check methods inside X machine.</h5>  

---

<h4>Changelog v1.4</h4>  
- Added more health-check methods (_Crystal_, _Picolisp_, _G++_, _Clang++_, _GNAT(Ada)_, _Haskell_, _Swift_, _Kotlin_, _Prolog(SWI)_, _Neko_, _FreePascal_).  
- Added an option to save output to a log file.  
- Fixed small bugs and optimized health-check methods.  
- Typo.  

<h4>Changelog v1.3:</h4>  

- Added more health-check methods (_CQL-shell, Racket, Guile, Julia_).  
- Fixed bugs.  
- Optimized methods.  
- Optimized code.  
- Typo.  
- More validations.  

<h4>Changelog v1.2:</h4>  

- Added a new option to display all supported and installed methods: [ ./c_wait.sh --installed ].  
- Full support for the latest _BusyBox_ version of _Telnet_ and _Wget_.  
- Added more health-check methods (_SSH, MongoDB-Client, Groovy, Zsh, Ocaml_).  
- Fixed bugs.  
- Optimized methods and performance.  
- Optimzed code.  

---

### Features:  

>1. Optimized for _Kubernetes_ and _Docker_ images (including full support for the most popular OS-images: _Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage_ and _openSUSE_).  
>2. In addition, support for: _BusyBox, Termux, macOS, RedHat, SUSELinux, ArchLinux, Mageia, GentooLinux, Endless, OpenBSD, FreeBSD, Solus, Guix, Slackware_ and other Linux distributions.  
>3. Supporting over 53 health-check methods, to check for open-connections.  
>4. Allow adding unlimited number of hosts.  
>5. Allow connection-mode:  
  @ 'all' hosts must be connected to complete the task.  
  @ 'any' of the hosts must be connected to complete the task.  
>6. Allow limited/forever connection-retries.  
>7. Option to display the installed and supported methods on host machine.  
>8. Custom methods and messages (easily editable from global values).  
>9. Simple, user-friendly and easy to use.  

<h4>Methods; health-check order:</h4>  

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
21. _Crystal_  
22. _CQL-shell_  
23. _Mongo-shell_  
24. _Groovy_  
25. _R_  
26. _Elixir_  
27. _Erlang_  
28. _Clojure_  
29. _Racket_  
30. _Guile_  
31. _PicoLisp_  
32. _PowerShell_  
33. _Julia_  
34. _GCC_  
35. _G++_  
36. _Clang_  
37. _Clang++_  
38. _GNAT(Ada)_  
39. _Java-JDK_  
40. _Haskell_  
41. _Rust_  
42. _Go_  
43. _SBCL_  
44. _Dart_  
45. _D_  
46. _Nim_  
47. _OCaml_  
48. _Swift_  
49. _Kotlin_  
50. _.NET_  
51. _Prolog(SWI)_  
52. _Neko_  
53. _FreePascal_  

---

### Default global values:  

 <h4>With args:</h4> 

```
HOSTS="8.8.8.8:53 db:3306"  
SLEEP_TIME="3"  
RETRIES_COUNT="0"  
CONNECT_MODE="all"  
IS_QUIET_MODE="no"  
LOG_FILE="-"  
```

<h4>Without args:</h4>

```
METHODS="nc bash ssh curl wget telnet gawk zsh ncat nmap socat python python3 node ruby perl php tclsh openssl scala crystal cqlsh mongo groovy Rscript elixir erl clojure racket guile pil pwsh julia gcc g++ clang clang++ gnatmake javac ghc rustc go sbcl dart dmd nim ocamlc swiftc kotlinc dotnet swipl nekoc fpc"

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
[ 'c_wait' - ConnectionWait v1.4 ]

Usage:
  ./c_wait.sh --connect {all|any}
     --sleep <secs> --retry <num|'forever'>
     --log <file|'-'> <hosts:ports ...>

Short usage:
  ./c_wait.sh -c {all|any} -r <num|'0'>
     -s <secs> -l <file|'-'> <hosts ...>

Examples:
  ./c_wait.sh -l out.txt
  ./c_wait.sh --sleep 1 google.com 8.8.8.8:53
  ./c_wait.sh -s 4 ftp:21 192.168.1.1:22
  ./c_wait.sh --quiet -s 10 -r 3 myserver:8000
  ./c_wait.sh -c any --log - localhost myftp:21
  ./c_wait.sh --connect all -q --retry 4 tln:25

Options and default values:
  <hosts:ports ...>
     ('8.8.8.8:53 db:3306')

  -c | --connect {all|any}
     ('all' of the selected hosts)

  -s | --sleep <seconds>
     ('3' seconds)

  -r | --retry <number|'forever'>
     (connection-retries: 'forever')

  -l | --log <file|'-'>
     (log file: '')

  -q | --quiet
     (minimal output? 'no')

Display info:
  -i | --installed
     (display installed methods)

  -h | --help | /?
     (display this usage)
```
    
---

<h3>Known 'Issues':</h3>  

<h5>Methods:</h5>  

- <h5>Mongo-shell: Will not be able to connect to '0.0.0.0' (connection will fail).</h5>  

<h5>Others:</h5>  

- <h5>No support for Solaris (because of incompatible version of 'grep').</h5>  

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

### TODO: 

> 1. _GAS(GNU Assembler)_.  
> 2. _GFortran_.  
> 3. _Gforth_.  

---

Contact me for any ideas, help and support: alaahag@gmail.com , +972527337763  
<h5>[PT & DevOPS developer, Looking for my next challenge].</h5>
