#!/bin/sh

# 'c_wait' ConnectionWait v1.4
# Author: Alaa H.J <MasterX>

# ----------------------------------------------
# ------ Default global values [not args] ------
# ----------------------------------------------
# DO NOT TOUCH THE METHODS BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING!
# Methods; health-check order [if method is not exist or not-supported then it will try the next method] (you can change the methods order, or disable/enable some methods):
METHODS="nc bash ssh curl wget telnet gawk zsh ncat nmap socat python python3 node ruby perl php tclsh openssl scala crystal cqlsh mongo groovy Rscript elixir erl clojure racket guile pil pwsh julia gcc g++ clang clang++ gnatmake javac ghc rustc go sbcl dart dmd nim ocamlc swiftc kotlinc dotnet swipl nekoc fpc"
# Netcat, Bash, SSH, cURL, Wget, Telnet, Gawk, Zsh, Ncat, Nmap, Socat, Python, Python3, NodeJS, Ruby, Perl, PHP, Tcl, OpenSSL, Scala, Crystal, CQL-shell, Mongo-shell, Groovy, R, Elixir, Erlang, Clojure, Racket, Guile, PicoLisp, PowerShell, Julia, GCC, G++, Clang, Clang++, GNAT(Ada), Java-JDK, Haskell, Rust, Go, SBCL, Dart, D, Nim, OCaml, Swift, Kotlin, .NET, Prolog(SWI), Neko, FreePascal

TIMEOUT="2" # Modify the connection-timeout if you have a very slow internet connection [default: '2' second].

# Custom messages:
readonly INIT_MESSAGE="'c_wait' - Initializing ..."       # Show a custom output when the script is about to get started (you can clear the text to suppress this output).
readonly CONNECT_MESSAGE="'c_wait' - Connection Succeed!" # Show a custom output when successfully connected to the host (you can clear the text to suppress this output).
readonly FAIL_MESSAGE="'c_wait' - Connection Failed!"     # Show a custom output when failed connecting to the host (you can clear the text to suppress this output).
readonly DONE_MESSAGE="'c_wait' - Task Completed :)"      # Show a custom output when the script is finished and successfully connected to the hosts (you can clear the text to suppress this output).
readonly QUIT_MESSAGE="'c_wait' - Terminated!"            # Show a custom output when the script is about to get terminated after failure or interrupt (you can clear the text to suppress this output).
# ------------------------------------------

# ------------------------------------------
# ------ Default global values [args] ------
# ------------------------------------------
HOSTS="8.8.8.8:53 db:3306" # IPs / HostNames. Example: db:3306,db2:5432,0.0.0.0,google.com [default port: '80'].
SLEEP_TIME="3"             # Sleep (wait) for X seconds [Default value: '3'].
RETRIES_COUNT="0"          # Max-retries for health-check. Type: {0|forever|inf|infinity} for unlimited connection-retries [default value: '0'].
CONNECT_MODE="all"         # Options: {all|any}. Type: 'all' to verify that all selected hosts are connected. Type: 'any' to verify that any of the selected hosts is connected [default value: 'all'].
IS_QUIET_MODE="no"         # Options: {yes|no}. Enable or disable output texts (but always alerts you when the script is about to get started or terminated) [default value: 'no'].
LOG_FILE="-"               # Log file name. Type: '-' to not save the output to a log file [default value: '-'].
# ------------------------------------------


Usage()
{
    echo "[ 'c_wait' - ConnectionWait v1.4 ]"
    echo
    echo "Usage:"
    echo "  $0 --connect {all|any}"
    echo "     --sleep <secs> --retry <num|'forever'>"
    echo "     --log <file|'-'> <hosts:ports ...>"
    echo
    echo "Short usage:"
    echo "  $0 -c {all|any} -r <num|'0'>"
    echo "     -s <secs> -l <file|'-'> <hosts ...>"
    echo
    echo "Examples:"
    echo "  $0 -l out.txt"
    echo "  $0 --sleep 1 google.com 8.8.8.8:53"
    echo "  $0 -s 4 ftp:21 192.168.1.1:22"
    echo "  $0 --quiet -s 10 -r 3 myserver:8000"
    echo "  $0 -c any --log - localhost myftp:21"
    echo "  $0 --connect all -q --retry 4 tln:25"
    echo
    echo "Options and default values:"
    echo "  <hosts:ports ...>"
    echo "     ('$HOSTS')"
    echo
    echo "  -c | --connect {all|any}"
    echo "     ('$CONNECT_MODE' of the selected hosts)"
    echo
    echo "  -s | --sleep <seconds>"
    echo "     ('$SLEEP_TIME' seconds)"
    echo
    echo "  -r | --retry <number|'forever'>"
    echo "     (connection-retries: '$RETRIES_COUNT')"
    echo
    echo "  -l | --log <file|'-'>"
    echo "     (log file: '$LOG_FILE')"
    echo
    echo "  -q | --quiet"
    echo "     (minimal output? '$IS_QUIET_MODE')"
    echo
    echo "Display info:"
    echo "  -i | --installed"
    echo "     (display installed methods)"
    echo
    echo "  -h | --help | /?"
    echo "     (display this usage)"
    exit 1
}


Help()
{
    echo "[*] Type: '$0 --help' for usage."
    exit 1
}


Terminated()
{
    if [ -n "$QUIT_MESSAGE" ]; then printf "%s\n" "[x] [$(date +%T)] $QUIT_MESSAGE" "" | tee -a $LOG_FILE; fi
    exit 1
}


Print_Installed_Methods()
{
    echo "[*] Installed and supported methods:"
    for method in $METHODS; do
        if command -v "$method" >/dev/null; then
            case "$method" in
                "nc")       printf "Netcat(nc)"         ;;
                "ssh")      printf "SSH"                ;;
                "curl")     printf "cURL"               ;;
                "node")     printf "NodeJS(node)"       ;;
                "php")      printf "PHP"                ;;
                "tclsh")    printf "Tcl(tclsh)"         ;;
                "openssl")  printf "OpenSSL"            ;;
                "cqlsh")    printf "CQL-shell(cqlsh)"   ;;
                "mongo")    printf "Mongo-shell(mongo)" ;;
                "Rscript")  printf "R(Rscript)"         ;;
                "erl")      printf "Erlang(erl)"        ;;
                "pil")      printf "PicoLisp(pil)"      ;;
                "pwsh")     printf "PowerShell(pwsh)"   ;;
                "gcc")      printf "GCC"                ;;
                "gnatmake") printf "GNAT(gnatmake)"     ;;
                "javac")    printf "Java-JDK(javac)"    ;;
                "ghc")      printf "Haskell(ghc)"       ;;
                "rustc")    printf "Rust(rustc)"        ;;
                "sbcl")     printf "SBCL"               ;;
                "dmd")      printf "D(dmd)"             ;;
                "ocamlc")   printf "OCaml(ocamlc)"      ;;
                "swiftc")   printf "Swift(swiftc)"      ;;
                "kotlinc")  printf "Kotlin(kotlinc)"    ;;
                "dotnet")   printf ".NET(dotnet)"       ;;
                "swipl")    printf "Prolog(swipl)"      ;;
                "nekoc")    printf "Neko(nekoc)"        ;;
                "fpc")      printf "FreePascal(fpc)"    ;;
                *)
                    # Else, capitalize first letter and print
                    local fLetter=$(echo "$method" | cut -c1 | tr '[:lower:]' '[:upper:]')
                    local restLetters=$(echo "$method" | cut -c2-)
                    printf "%s" "$fLetter$restLetters"
                    ;;
            esac
            printf "  "
        fi
    done
    echo; exit 1
}


Validate_Args()
{
    local temp_hosts=""
    until [ -z "$1" ]; do
        local param1="$1"
        local param2=""

        if [ -n "$2" ]; then param2="$2"; fi
        case "$param1" in
            -c|--connect)
                if [ "$param2" = "any" ] || [ "$param2" = "all" ]; then
                    CONNECT_MODE="$param2"
                    shift 2
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid: --connect '$param2' (must be 'all' or 'any')!"
                    Help
                fi
                ;;

            -s|--sleep)
                if echo "$param2" | grep -Eo '^[0-9]{1,5}$' >/dev/null; then
                    SLEEP_TIME="$param2"
                    shift 2
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid: --sleep '$param2' (must be greater than or equal to 0)!"
                    Help
                fi
                ;;

            -r|--retry)
                if echo "$param2" | grep -Eo '^([1-9][0-9]{1,4}|[1-9])$' >/dev/null; then
                    RETRIES_COUNT="$param2"
                    shift 2
                elif echo "$param2" | grep -Eo '^(0|forever|inf|infinity)$' >/dev/null; then
                    RETRIES_COUNT="forever"
                    shift 2
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid: --retry '$param2' (must be greater than or equal to 0 ['0' means forever])!"
                    Help
                fi
                ;;

            -l|--log)
                if [ "$param2" = "-" ]; then
                    LOG_FILE=""
                elif echo "$param2" | grep -Eo '^[a-zA-Z0-9._-]+$' >/dev/null; then
                    touch "$param2" 2>/dev/null
                    if [ $? -ne 0 ]; then
                        echo "[-] [$(date +%T)] 'c_wait' - Permission denied while logging a file: '$param2'!"
                        LOG_FILE=""
                    else
                        LOG_FILE="$(pwd)/$param2";
                    fi
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid --log '$param2' file name!"
                    Help
                fi
                shift 2
                ;;

            -q|--quiet)
                IS_QUIET_MODE="yes"
                shift
                ;;

            -i|--installed)
                Print_Installed_Methods
                ;;

            -h|--help|/?)
                Usage
                ;;

            -*)
                echo "[x] [$(date +%T)] 'c_wait' - Invalid parameters: '$param1'!"
                Help
                ;;

            *)
                # Hosts:Ports [default port: '80']
                if echo "$param1" | grep -Eo '^[a-zA-Z0-9._-]+(:([1-9]{1}|[0-9]{2,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$' >/dev/null; then
                    local temp_host=$(echo "$param1" | cut -d: -f1)
                    local temp_port=$(echo "$param1" | cut -d: -f2)
                    if [ -z "$temp_port" ] || [ "$temp_port" = "$param1" ]; then temp_port="80"; fi
                    temp_hosts="$temp_hosts $temp_host:$temp_port"
                    shift
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid host values: '$param1'!"
                    Help
                fi
                ;;
        esac
    done

    if [ -z "$temp_hosts" ]; then
        # Missing hosts output : terminate app
        if [ -z "$HOSTS" ]; then echo "[x] [$(date +%T)] 'c_wait' - Missing hosts!"; exit 1; fi
        # Call function to recursively validate host values (if there are no args from input)
        Validate_Args $HOSTS
    else
        # Remove trailing spaces
        HOSTS="$(echo "$temp_hosts" | awk '{$1=$1};1')"
    fi

    if [ "$IS_QUIET_MODE" != "yes" ]; then IS_QUIET_MODE="no"; fi
}


Method_On_Action()
{
    local method="$1"
    local host="$2"
    local port="$3"
    local exec_package="cwait_$method"

    case "$method" in
        "nc")
            "$method" -zvw"$TIMEOUT" "$host" "$port" >/dev/null 2>&1
            ;;

        "bash")
            $TIMEOUT_CMD "$method" -c "echo >/dev/tcp/$host/$port" >/dev/null 2>&1
            ;;

        "ssh")
            if $TIMEOUT_CMD "$method" -o BatchMode=yes -p "$port" "$host" 2>&1 | grep -iEo "exchange_identification|Permission denied|verification failed" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "curl")
            case $("$method" -kI --connect-timeout "$TIMEOUT" "$host":"$port" 2>&1 | grep -Eo "\([0-9]+\)") in
                ""|"(8)"|"(52)"|"(56)")
                    GOOD_CONNECT_RESULT="0"
                    ;;
            esac
            return
            ;;

        "wget")
            if "$method" -t 1 --spider -S -T "$TIMEOUT" "$host":"$port" 2>&1 | grep -iEo "\<connected\>|\<header\>|\<response\>|http/" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "telnet")
            if $TIMEOUT_CMD "$method" "$host" "$port" </dev/null 2>/dev/null | grep -io "\<connected\>" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "gawk")
            $TIMEOUT_CMD "$method" "BEGIN {S=\"/inet/tcp/0/$host/$port\";print |& S;x=close(S);exit x}" >/dev/null 2>&1
            ;;

        "zsh")
            $TIMEOUT_CMD "$method" -c "zmodload zsh/net/tcp;ztcp $host $port" >/dev/null 2>&1
            ;;

        "ncat")
            "$method" -w "$TIMEOUT" "$host" "$port" </dev/null >/dev/null 2>&1
            ;;

        "nmap")
            if "$method" --host-timeout "$TIMEOUT"000ms --open "$host" -p "$port" 2>&1 | grep -io "\<open\>" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "socat")
            "$method" /dev/null TCP4:"$host":"$port",connect-timeout="$TIMEOUT" >/dev/null 2>&1
            ;;

        "python"|"python3")
            "$method" -c 'exec("""\nimport socket;socket.setdefaulttimeout('$TIMEOUT');\nif socket.socket(socket.AF_INET,socket.SOCK_STREAM).connect(("'$host'",'$port'))==1:exit(1)\n""")' >/dev/null 2>&1
            ;;

        "node")
            "$method" --no-warnings -e "var net=require('net');var s=new net.Socket();s.setTimeout("$TIMEOUT"000,function(){s.destroy()});s.connect($port,'$host',function(){process.exit(0)});s.on('close',function(){process.exit(1)})" >/dev/null 2>&1
            ;;

        "ruby")
            "$method" -e "require 'socket';require 'timeout';Timeout::timeout($TIMEOUT) do;s=TCPSocket.new('$host',$port);s.close;end" >/dev/null 2>&1
            ;;

        "perl")
            "$method" -X -e 'use IO::Socket::INET;my $s=new IO::Socket::INET(PeerAddr=>"'$host'",PeerPort=>"'$port'",Proto=>"tcp",Timeout=>"'$TIMEOUT'");if($s){$s->close}else{exit(1)}' >/dev/null 2>&1
            ;;

        "php")
            "$method" -r '$c=@fsockopen("'$host'",'$port',$errno,$errstr,'$TIMEOUT');if(is_resource($c)){fclose($c);}else{exit(1);}' >/dev/null 2>&1
            ;;

        "tclsh")
            echo 'if [catch {socket -async "'$host'" '$port'} s] {exit 1};fileevent $s writable {set c 1};after '$TIMEOUT'000 set c 0;vwait c;if {$c} {close $s;exit 0};catch {exit 1}' | tclsh >/dev/null 2>&1
            ;;

        "openssl")
            if $TIMEOUT_CMD "$method" s_client -connect "$host":"$port" </dev/null 2>/dev/null | head -1 | grep -io "\<connected\>" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "scala")
            "$method" -e "try{val s=new java.net.Socket();s.connect(new java.net.InetSocketAddress(\"$host\",$port),"$TIMEOUT"000);s.close()}catch{case e:Exception=>sys.exit(1)}" >/dev/null 2>&1
            ;;

        "crystal")
            "$method" eval "require \"socket\";s=TCPSocket.new(\"$host\",$port,connect_timeout:$TIMEOUT);s.close" >/dev/null 2>&1
            ;;

        "cqlsh")
            local cqlsh_res="$("$method" --connect-timeout="$TIMEOUT" "$host" "$port" </dev/null 2>&1 | grep -Eo '[a-zA-Z]+')"
            if [ -z "$cqlsh_res" ] || echo "$cqlsh_res" | grep -iEo "\<protocolerror\>|\<closed\>" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "mongo")
            if $TIMEOUT_CMD "$method" --host "$host" --port "$port" --verbose --norc </dev/null 2>&1 | head -4 | grep -io "\<connected\>" >/dev/null; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "groovy")
            "$method" -e "Socket s=new Socket();s.connect(new InetSocketAddress(\"$host\",$port),"$TIMEOUT"000);s.close()" >/dev/null 2>&1
            ;;

        "Rscript")
            # The timeout is not working properly on Linux OSes (works on Mac, So the extra TIMEOUT_CMD is needed here)
            $TIMEOUT_CMD "$method" --vanilla -e "{s<-socketConnection(host=\"$host\",port=$port,timeout=$TIMEOUT);close(s)}" >/dev/null 2>&1
            ;;

        "elixir")
            "$method" -e "case :gen_tcp.connect('$host',$port,[],"$TIMEOUT"000)do{:ok,s}->:gen_tcp.close(s);{:error,_}->System.halt(1);end" >/dev/null 2>&1
            ;;

        "erl")
            "$method" -noshell -eval "case gen_tcp:connect(\"$host\",$port,[],"$TIMEOUT"000) of {ok,S}->gen_tcp:close(S),init:stop();{error,_}->erlang:halt(1)end." >/dev/null 2>&1
            ;;

        "clojure")
            "$method" -e "(def s(java.net.Socket.))(.connect s(java.net.InetSocketAddress. \"$host\" $port)"$TIMEOUT"000)(.close s)" >/dev/null 2>&1
            ;;

        "racket")
            "$method" -q -e "(define w(thread(lambda()(sleep $TIMEOUT)(exit 1))))(tcp-connect \"$host\" $port)" >/dev/null 2>&1
            ;;

        "guile")
            "$method" -q --no-debug -c "(use-modules(ice-9 threads))(call-with-new-thread(lambda()(sleep $TIMEOUT)(primitive-exit 1)))(let([s(socket PF_INET SOCK_STREAM 0)][d(vector-ref(addrinfo:addr(car(getaddrinfo \"$host\")))1)])(connect s AF_INET d $port)(close s))" >/dev/null 2>&1
            ;;

        "pil")
            "$method" -"call (let? s(abort $TIMEOUT(connect \"$host\" $port))(close s)(bye))(bye 2)" >/dev/null 2>&1
            ;;

        "pwsh")
            "$method" -Command '$t=New-Object Net.Sockets.TcpClient;$c=$t.BeginConnect("'$host'",'$port',$null,$null);$w=$c.AsyncWaitHandle.WaitOne('$TIMEOUT'000,$false);if(!$w){$t.Close();exit 1}else{if($t.Connected){$t.EndConnect($c);$t.Close()}else{exit 1}}' >/dev/null 2>&1
            ;;

        "julia")
            "$method" --compile=min -q -e "using Sockets;t=@async while true sleep($TIMEOUT);exit(1);end;s=connect(\"$host\",$port);close(s)" >/dev/null 2>&1
            ;;

        "gcc"|"g++"|"clang"|"clang++")
            local package="$exec_package.cpp"
            if [ ! -s "$exec_package" ]; then printf "%s\n" "#include<unistd.h>" "#include<string.h>" "#include<netdb.h>" "#include<sys/socket.h>" "#include<netinet/in.h>" "#include <sys/time.h>" "#include <stdlib.h>" "int main(int argc,char *argv[]){int s;struct sockaddr_in sa;struct hostent *sv;s=socket(AF_INET,SOCK_STREAM,0);sv=gethostbyname(argv[1]);if (sv==NULL) return 1;bzero((char *) &sa,sizeof(sa));sa.sin_family=AF_INET;bcopy((char *)sv->h_addr,(char *)&sa.sin_addr.s_addr,sv->h_length);sa.sin_port=htons(atoi(argv[2]));struct timeval timeout={atoi(argv[3]),0};if(setsockopt(s,SOL_SOCKET,SO_SNDTIMEO,(const void*) &timeout,sizeof(timeout))!=0 || connect(s,(struct sockaddr *) &sa,sizeof(sa))<0) return 1;close(s);}" > "$package" && "$method" "$package" -o "$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "gnatmake")
            local package="$exec_package.adb"
            if [ ! -s "$exec_package" ]; then echo "with GNAT.Sockets;use GNAT.Sockets;with Ada.Command_Line;use Ada.Command_Line;procedure $exec_package is Client:Socket_Type;Address:Sock_Addr_Type;begin Create_Socket(Client);Set_Socket_Option(Socket=>Client,Option=>(Name=>Send_Timeout,Timeout=>Duration'Value(Argument(Number=>3))));Address.Port:=Port_Type'Value(Argument(Number=>2));Address.Addr:=Addresses(Get_Host_By_Name(Argument(Number=>1)),1);Connect_Socket(Client,Address);Close_Socket(Client);end $exec_package;" > "$package" && "$method" -q -O3 "$package" -o "$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT.0" >/dev/null 2>&1
            ;;

        "javac")
            local package="$exec_package.java"
            if [ ! -s "$exec_package" ]; then echo "import java.net.Socket;import java.net.InetSocketAddress;class $exec_package{public static void main(String[] args){try{Socket s=new Socket();s.connect(new InetSocketAddress(args[0],Integer.valueOf(args[1])),Integer.valueOf(args[2]));s.close();}catch(Exception e){System.exit(1);}}}" > "$package" && "$method" -g:none -nowarn "$package" >/dev/null 2>&1; fi
            java "$exec_package" "$host" "$port" "$TIMEOUT"000 >/dev/null 2>&1
            ;;

        "ghc")
            local package="$exec_package.hs"
            if [ ! -s "$exec_package" ]; then printf "%s\n" "import Network.Socket;import System.Environment(getArgs);import System.Posix(exitImmediately);import System.Exit(ExitCode(ExitFailure));import Control.Concurrent(threadDelay);import Control.Concurrent.Async(async)" "tr::Int->IO()" "tr n=do" " threadDelay n;exitImmediately(ExitFailure 1)" "main=do" " (h:p:t:_)<-getArgs;async(tr(read t::Int));ad<-getAddrInfo Nothing(Just h)(Just p);let s=head ad" " sock<-socket(addrFamily s) Stream defaultProtocol;connect sock(addrAddress s);close sock" > "$package" && "$method" -O "$package" -o "$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT"000000 >/dev/null 2>&1
            ;;

        "rustc")
            local package="$exec_package.rs"
            if [ ! -s "$exec_package" ]; then echo "use std::env;use std::net::TcpStream;use std::time::Duration;use std::process::exit;use std::net::ToSocketAddrs;use std::net::SocketAddr;fn r_ad()->Result<SocketAddr,String>{let mut ad=match env::args().nth(1).unwrap_or_default().to_socket_addrs(){Ok(ad)=>ad,Err(_e)=>exit(1),};match ad.next(){None=>exit(1),Some(ad)=>Ok(ad),}}fn main(){if let Err(_e)=TcpStream::connect_timeout(&r_ad().unwrap(),Duration::from_secs(env::args().nth(2).unwrap_or_default().parse().unwrap())){exit(1)}}" > "$package" && "$method" -O "$package" -o "$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host:$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "go")
            local package="$exec_package.go"
            if [ ! -s "$exec_package" ]; then echo 'package main;import("net";"os";"time";"strconv";);func main(){T,e:=strconv.Atoi(os.Args[2]);c,e:=net.DialTimeout("tcp",os.Args[1],time.Duration(T)*time.Second);if e,ok:=e.(*net.OpError);ok && e.Timeout(){os.Exit(1)};if e!=nil{os.Exit(1)};defer c.Close()}' > "$package" && "$method" build "$package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host:$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "sbcl")
            local package="$exec_package.lisp"
            if [ ! -s "$package" ]; then echo "(require :sb-bsd-sockets)(use-package :sb-thread)(make-thread #'(lambda ()(sleep(parse-integer(nth 3 sb-ext:*posix-argv*)))(sb-ext:quit :unix-status 2)))(let((socket(make-instance 'sb-bsd-sockets:inet-socket :type :stream :protocol :tcp)))(sb-bsd-sockets:socket-connect socket(sb-bsd-sockets::host-ent-address(sb-bsd-sockets:get-host-by-name(nth 1 sb-ext:*posix-argv*)))(parse-integer(nth 2 sb-ext:*posix-argv*))))" > "$package"; fi
            "$method" --noprint --non-interactive --load "$package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "dart")
            local package="$exec_package.dart"
            if [ ! -s "$package" ]; then echo 'import "dart:io";void main(List<String> args){new Future.delayed(new Duration(seconds:int.parse(args[2])),(){exit(1);});Socket.connect(args[0],int.parse(args[1])).then((socket){socket.destroy();exit(0);});}' > "$package"; fi
            "$method" "$package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "dmd")
            local package="$exec_package.d"
            if [ ! -s "$exec_package" ]; then echo "import std.socket;import std.datetime;import std.conv;void main(in string[] args){auto s=new Socket(AddressFamily.INET,SocketType.STREAM,ProtocolType.TCP);s.setOption(SocketOptionLevel.SOCKET,SocketOption.SNDTIMEO,to!int(args[3]).seconds);scope(exit){s.close();}auto addresses=getAddress(args[1],args[2]);s.connect(addresses[0]);}" > "$package" && "$method" -debug=0 -O "$package" -of="$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "nim")
            local package="$exec_package.nim"
            if [ ! -s "$exec_package" ]; then printf "%s\n" "from threadpool import spawn;from os import paramStr,sleep;import net;from strutils import parseInt;" "proc t():void=" " var T:int=parseInt(paramStr(3));" " sleep(T);" " system.quit(QuitFailure);" "spawn t();" "let s:Socket=newSocket();" "var P:int=parseInt(paramStr(2));" "s.connect(paramStr(1).string,Port(P));" "s.close();" > "$package" && "$method" c --opt:speed --threads:on -d:release -o:"$exec_package" "$package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT"000 >/dev/null 2>&1
            ;;

        "ocamlc")
            local package="$exec_package.ml"
            if [ ! -s "$exec_package" ]; then echo "open Unix;;let ad=ADDR_INET((gethostbyname Sys.argv.(1)).h_addr_list.(0),(int_of_string Sys.argv.(2))) in let s=socket PF_INET SOCK_STREAM 0 in setsockopt_float s SO_SNDTIMEO (float_of_string Sys.argv.(3));connect s ad;shutdown s SHUTDOWN_ALL" > "$package" && "$method" unix.cma "$package" -o "$exec_package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT.0" >/dev/null 2>&1
            ;;

        "swiftc")
            local package="$exec_package.swift"
            if [ ! -s "$exec_package" ]; then printf "%s\n" "import Foundation" "#if os(macOS)||os(iOS)||os(tvOS)||os(watchOS)" " import Darwin;let s=socket(AF_INET,SOCK_STREAM,0)" "#else" " import Glibc;let s=socket(AF_INET,Int32(SOCK_STREAM.rawValue),0)" "#endif" 'DispatchQueue(label:"t").asyncAfter(deadline:.now() + .seconds(Int(CommandLine.arguments[3])!)){exit(1)};var H=Host(name:CommandLine.arguments[1]).address;if (H==nil){exit(1)};var ad=sockaddr_in();ad.sin_family=sa_family_t(AF_INET);ad.sin_port=in_port_t(UInt16(CommandLine.arguments[2])!.bigEndian);ad.sin_addr=in_addr(s_addr:inet_addr(H));ad.sin_zero=(0,0,0,0,0,0,0,0);let adP=withUnsafePointer(to:&ad){UnsafePointer<sockaddr>(OpaquePointer($0))};var e=connect(s,adP,UInt32(MemoryLayout<sockaddr_in>.size));if(e<0){exit(1)};close(s);' > "$package" && "$method" -Ounchecked "$package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "kotlinc")
            local package="$exec_package.kt"
            local exec_package="$exec_package.jar"
            if [ ! -s "$exec_package" ]; then echo "fun main(args:Array<String>){java.net.Socket().connect(java.net.InetSocketAddress(args[0],args[1].toInt()),args[2].toInt())}" > "$package" && "$method" "$package" -include-runtime -d "$exec_package" >/dev/null 2>&1; fi
            java -jar "$exec_package" "$host" "$port" "$TIMEOUT"000 >/dev/null 2>&1
            ;;

        "dotnet")
            local exec_file="bin/cwait/netcoreapp2.1/$exec_package.dll"
            if [ ! -s "$exec_file" ]; then echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>netcoreapp2.1</TargetFramework></PropertyGroup></Project>' > "$exec_package.csproj" && echo "using System.Net.Sockets;using static System.Environment;namespace T{class T{static void Main(string[] args){Socket s=new Socket(AddressFamily.InterNetwork,SocketType.Stream,ProtocolType.Tcp);s.BeginConnect(args[0],int.Parse(args[1]),null,null).AsyncWaitHandle.WaitOne(int.Parse(args[2]),true);if(s.Connected)s.Close();else Exit(1);}}}" > "$exec_package.cs" && "$method" build -c cwait >/dev/null 2>&1; fi
            "$method" "$exec_file" "$host" "$port" "$TIMEOUT"000 >/dev/null 2>&1
            ;;

        "swipl")
            local package="$exec_package.pl"
            if [ ! -s "$package" ]; then echo ":-initialization(main,main). main:-catch_with_backtrace(s,Error,(print_message(error,Error),halt(2))). s:-current_prolog_flag(argv,V),append([H,P,T],[],V),atom_number(P,PN),atom_number(T,TN),call_with_time_limit(TN,(tcp_connect(H:PN,I,[]),close(I)))." > "$package"; fi
            "$method" --debug=false -q -s "$package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "nekoc")
            local package="$exec_package.neko"
            local exec_package="$exec_package.n"
            if [ ! -s "$exec_package" ]; then echo 'var si=$loader.loadprim("std@socket_init",0);var cn=$loader.loadprim("std@socket_new",1);var h=$loader.loadprim("std@host_resolve",1);var c=$loader.loadprim("std@socket_connect",3);var cs=$loader.loadprim("std@socket_close",1);var ct=$loader.loadprim("std@socket_set_timeout",2);si();var s=cn(false);ct(s,$int($loader.args[2]));c(s,h($loader.args[0]),$int($loader.args[1]));cs(s);' > "$package" && "$method" "$package" >/dev/null 2>&1; fi
            neko "$exec_package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1
            ;;

        "fpc")
            local package="$exec_package.pp"
            if [ ! -s "$exec_package" ]; then echo "Uses sockets,netdb,unixtype,SysUtils;Var sa:sockaddr_in;s:Longint;tv:timeval;h:THostEntry;hs:String;Begin s:=fpSocket(AF_INET,SOCK_STREAM,0);sa.sin_family:=AF_INET;sa.sin_port:=htons(StrToInt(ParamStr(2)));tv.tv_sec:=StrToInt(ParamStr(3));hs:=ParamStr(1);if not(ResolveHostByAddr(StrToHostAddr(hs),h)) and not(ResolveHostByName(hs,h)) then halt(2);if(h.Addr.s_addr=0) then halt(2);sa.sin_addr.s_addr:=h.Addr.s_addr;if(fpsetsockopt(s,SOL_SOCKET,SO_SNDTIMEO,@tv,sizeof(tv))<>0) or (fpconnect(s,@sa,Sizeof(sa))<0) then halt(2);CloseSocket(s);End." > "$package" && "$method" -O3 "$package" >/dev/null 2>&1; fi
            ./"$exec_package" "$host" "$port" "$TIMEOUT" >/dev/null 2>&1;
            ;;

        *)
            echo "[x] [$(date +%T)] 'c_wait' - Method '$method' is not exist or not linked correctly!" | tee -a $LOG_FILE
            Terminated
            ;;
    esac

    if [ $? -eq 0 ]; then GOOD_CONNECT_RESULT="0"; fi
}


Check_Methods()
{
    local host=$(echo "$1" | cut -d: -f1)
    local port=$(echo "$1" | cut -d: -f2)

    # Globals:
    GOOD_CONNECT_RESULT=""
    USED_METHOD=""

    # Test methods for open-connection
    for method in $METHODS; do
        if command -v "$method" >/dev/null; then
            USED_METHOD="[$method]"
            # Call function to test connection using the selected method
            Method_On_Action "$method" "$host" "$port"
            break
        fi
    done

    # UNSUPPORTED METHOD output : exit app if failed to identify any connection-methods
    if [ -z "$USED_METHOD" ]; then printf "%s\n" "" "[x] [$(date +%T)] 'c_wait' - Failed to check for connections, Unable to locate any supported method!" | tee -a $LOG_FILE; Terminated; fi
}


Main()
{
    # Call function to check for missing files and make configurations
    Check_Missing_Files_AND_Make_Config

    local args="$(echo $@ | tr '[:upper:]' '[:lower:]' | sed 's/,/ /g')"
    # Call function to optimize and validate args
    Validate_Args $args

    # Call function to find writable directories and optimize compiled methods (this must run after validations of args)
    Find_Writable_Dir_AND_Optimize_Compiled_Methods

    # INIT output
    if [ -n "$INIT_MESSAGE" ]; then printf "%s\n" "" "[*] [$(date +%T)] $INIT_MESSAGE" "" "[*] Hosts:           '$HOSTS'" "[*] Connection Mode: '$CONNECT_MODE' hosts" "[*] Sleep Time:      '$SLEEP_TIME' second(s)" "[*] Max Timeout:     '$TIMEOUT' second(s)" "[*] Max Retries:     '$RETRIES_COUNT'" "[*] Log File:        '$LOG_FILE'" "[*] Quiet Mode:      '$IS_QUIET_MODE'" | tee -a $LOG_FILE; fi

    # Loop while checking for open connections
    local retries_count=$(echo "$RETRIES_COUNT" | sed 's/forever/-1/')
    local r_counter=1
    while [ $r_counter -ne $((retries_count+1)) ]; do
        local success=""
        if [ -n "$FAIL_MESSAGE" ] && [ "$IS_QUIET_MODE" = "no" ]; then printf "%s\n" "" "[*] [$(date +%T)] 'c_wait' - tries: $r_counter/$RETRIES_COUNT ..." | tee -a $LOG_FILE; fi
        sleep "$((SLEEP_TIME-1))"

        for host_n_port in $HOSTS; do
            sleep 1
            # Call function to check for open connection
            Check_Methods "$host_n_port"

            if [ -n "$GOOD_CONNECT_RESULT" ]; then
                # SUCCESS output
                if [ -n "$CONNECT_MESSAGE" ] && [ "$IS_QUIET_MODE" = "no" ]; then echo "[+] [$(date +%T)] $USED_METHOD - $host_n_port => $CONNECT_MESSAGE" | tee -a $LOG_FILE; fi
                success="0"
                if [ "$CONNECT_MODE" = "any" ]; then break; fi
            else
                # FAIL output
                if [ -n "$FAIL_MESSAGE" ] && [ "$IS_QUIET_MODE" = "no" ]; then echo "[-] [$(date +%T)] $USED_METHOD - $host_n_port => $FAIL_MESSAGE" | tee -a $LOG_FILE; fi
                success="1"
                if [ "$CONNECT_MODE" = "all" ]; then break; fi
            fi
        done

        # DONE output : exit app successfully
        if [ "$success" = "0" ]; then CleanUps; if [ -n "$DONE_MESSAGE" ]; then printf "%s\n" "" "[v] [$(date +%T)] $DONE_MESSAGE" "" | tee -a $LOG_FILE; fi; exit 0; fi
        r_counter=$((r_counter=r_counter+1))
    done

    # If reached here: exit app with failure (end of retries), Also call a function to cleanup the compiled files at tmp folder
    CleanUps
    Terminated
}


Find_Writable_Dir_AND_Optimize_Compiled_Methods()
{
    # Change to writable temp directory to store the compiled files
    local writable_dir=""
    for w_dir in "/tmp" "/var/tmp" "/usr/tmp" "/usr/local/tmp" "/dev/shm" "/var/lock" "$(pwd)"; do if [ -w "$w_dir" ]; then writable_dir="$w_dir"; cd "$w_dir" >/dev/null; CleanUps; break; fi; done

    # Check if there is no writable directory then disable some methods (related to compilations)
    if [ -z "$writable_dir" ]; then
        local compilation_methods="gcc g++ clang clang++ gnatmake javac ghc rustc go sbcl dart dmd nim ocamlc swiftc kotlinc dotnet swipl nekoc fpc"
        if [ "$IS_QUIET_MODE" = "no" ]; then echo "[-] [$(date +%T)] 'c_wait' - Insufficient folders permission. The following methods will be disabled: '$compilation_methods'!"; fi
        for disable_method in $compilation_methods; do METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$disable_method'")$o=""}1'); done
    fi
}


CleanUps()
{
    # Cleanups before init and before termination of script
    rm -rf cwait_* obj bin/cwait
    if [ -d "bin" ]; then rm -d bin 2>/dev/null; fi
}


Check_Missing_Files_AND_Make_Config()
{
    # If grep is not exist or incompatible version -> UNSUPPORTED SYSTEM output : terminate app
    if ! command -v "grep" >/dev/null; then printf "%s\n" "" "[x] [$(date +%T)] 'c_wait' - Failed to initialize :( Missing system file: 'grep' or it is not linked correctly!" | tee -a $LOG_FILE; Terminated; fi
    # Disable grep on Solaris (old grep is not good enough for this script)
    if grep -v 2>&1 | grep "pattern file \." >/dev/null; then printf "%s\n" "" "[x] [$(date +%T)] 'c_wait' - Failed to initialize :( System file: 'grep' version is not compatible for this script!" | tee -a $LOG_FILE; Terminated; fi

    # Organize methods (no duplicates)
    METHODS=$(echo "$METHODS" | tr ' ' '\n' | awk '!x[$0]++' | tr '\n' ' ')

    TIMEOUT_CMD="" # Global
    # Check for invalid TIMEOUT value
    if echo "$TIMEOUT" | grep -Eov '^([1-9][0-9]{1,4}|[1-9])$' >/dev/null; then
        if [ "$IS_QUIET_MODE" = "no" ]; then echo "[-] [$(date +%T)] 'c_wait' - Invalid: TIMEOUT '$TIMEOUT'. Restored the default value back to '2' seconds." | tee -a $LOG_FILE; TIMEOUT="2"; fi
    fi

    if command -v "timeout" >/dev/null; then
        # The timeout options ('timeout' is for the standard / GNU version, 'timeout -t' is for the old version of BusyBox)
        TIMEOUT_CMD=$(timeout --version 2>&1 | head -4 | grep -io "\-t secs")
        if [ -z "$TIMEOUT_CMD" ]; then TIMEOUT_CMD="timeout -s 2 $TIMEOUT"; else TIMEOUT_CMD="timeout -t $TIMEOUT -s 2"; fi
    elif command -v "gtimeout" >/dev/null; then
        # Old macOS 'gtimeout'
        TIMEOUT_CMD="gtimeout -s 2 $TIMEOUT"
    else
        # If timeout is not exist -> show a warning and move the affected methods to the bottom of the priority (last to be checked)
        local timeout_methods="Rscript bash ssh telnet gawk zsh openssl mongo"
        if [ "$IS_QUIET_MODE" = "no" ]; then printf "%s\n" "[-] [$(date +%T)] 'c_wait' - Missing system file: 'timeout'. This might lower the performance of the following methods: '$timeout_methods'!" "" | tee -a $LOG_FILE; fi
        for move_method in $timeout_methods; do METHODS=$(echo "$METHODS" | sed "s/$move_method\(.*\)/\1 $move_method/"); done
    fi

    # Validate BusyBox's telnet version (old BusyBox 1.30.x and lower is not supported)
    if telnet --help 2>&1 | head -1 | grep -iE "v1.2|v1.30" >/dev/null; then METHODS=$(echo "$METHODS" | sed 's/telnet//g'); fi

    # Validate java if not installed properly (also for macOS) then disable: scala, groovy, clojure, kotlin
    if ! command -v "java" >/dev/null || java -version 2>&1 | grep -io 'no java' >/dev/null; then for validate_java_method in "scala" "groovy" "clojure" "kotlinc"; do METHODS=$(echo "$METHODS" | sed "s/$validate_java_method//g"); done; fi

    # Validate javac, gcc, g++, clang, clang++ if they are not installed properly (for macOS) then we disable them from options
    if javac -version 2>&1 | grep -io 'no java' >/dev/null; then METHODS=$(echo "$METHODS" | sed 's/javac//g'); fi
    for validate_mac_method in "gcc" "g++" "clang" "clang++"; do if "$validate_mac_method" --help 2>&1 | grep -io 'developer tools' >/dev/null; then METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$validate_mac_method'")$o=""}1'); fi; done
}


trap 'echo; CleanUps; Terminated' INT


# Call Main function (with args / default options)
Main -c "$CONNECT_MODE" -s "$SLEEP_TIME" -r "$RETRIES_COUNT" -l "$LOG_FILE" $@
