#!/bin/sh

# 'c_wait' ConnectionWait v1.2
# Author: Alaa H.J <MasterX>


# DO NOT TOUCH THE METHODS BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING!
# Methods order (health-check) [if X method exists and installed on this machine] (you can change the methods order, or if you want to disable/enable some methods):
METHODS="nc ssh python python3 bash curl wget telnet socat node ruby perl php tclsh openssl gawk ncat nmap zsh mongo erl clojure groovy scala Rscript pwsh gcc clang elixirc javac rustc go dart dmd nim ocaml dotnet"
# Netcat, SSH, Python, Python3, Bash, cURL, Wget, Telnet, Socat, NodeJS, Ruby, Perl, PHP, Tcl, OpenSSL, Gawk, Ncat, Nmap, Zsh, MongoDB-Client, Erlang, Clojure, Groovy, Scala, R, PowerShell, GCC, Clang, Elixir, Java-JDK, Rust, Go, Dart, D, Nim, OCaml, .NET

# Default global values [args]:
HOSTS="8.8.8.8:53 db:3306" # IPs / HostNames.           Example: db:3306,db2:5432,0.0.0.0,google.com [default *:80]
SLEEP_TIME="3" # Sleep for X seconds.
RETRIES_COUNT="inf" # Max-retries for health-check.     '0' | 'inf' | 'infinity': For infinity connection-retries.
CONNECT_MODE="all" # Options: 'all' / 'any'.            'all': It will pass if all selected hosts are connected. | 'any': It will pass if any of the selected hosts are connected.
IS_QUIET_MODE="false" # Options: 'true' / 'false'.      Hide / show output messages (but always alert when the app is about to get started or terminated).

# Timeout [not arg] (You can modify the connection-timeout if you have a very slow internet connection [default: '2' seconds]):
TIMEOUT="2"

# Custom messages:
readonly INIT_MESSAGE="'c_wait' - Initializing" # Show a custom message when app is about to get started (you can clear the text to suppress this message).
readonly CONNECT_MESSAGE="'c_wait' - Connection Succeed!" # Show a custom message when successfully connected to the host (you can clear the text to suppress this message).
readonly FAIL_MESSAGE="'c_wait' - Connection Failed!" # Show a custom message when failed connecting to the host (you can clear the text to suppress this message).
readonly DONE_MESSAGE="'c_wait' - Task Completed :)" # Show a custom message when app is about to get terminated after successfully connected to the hosts (you can clear the text to suppress this message).


Terminated()
{
    echo "('c_wait' terminated)"
    exit 1
}


Usage()
{
    echo "[ 'c_wait' - ConnectionWait v1.2 ]"
    echo
    echo "Usage:"
    echo "  $0 --connect <'all'/'any'>"
    echo "     --sleep <secs> --retry <num/'inf'>"
    echo "     <hosts:ports ...>"
    echo
    echo "Examples:"
    echo "  $0 --sleep 4 ftp:21 192.168.1.1:22"
    echo "  $0 --quiet -s 10 -r 3 myserver:8000"
    echo "  $0 -c any -q localhost myftp:21"
    echo "  $0 --connect all --retry 4 srv:86"
    echo
    echo "Options and default values:"
    echo "  <hosts:ports ...>"
    echo "     ('$HOSTS')"
    echo
    echo "  -c | --connect <'all'/'any'>"
    echo "     ('$CONNECT_MODE' of the selected hosts)"
    echo
    echo "  -s | --sleep <seconds>"
    echo "     ('$SLEEP_TIME' seconds)"
    echo
    echo "  -r | --retry <number/'infinity'>"
    echo "     ('$RETRIES_COUNT' connection-retries)"
    echo
    echo "  -q | --quiet"
    echo "     (minimal output? '$IS_QUIET_MODE')"
    echo
    echo "Info:"
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
    echo
    Terminated
}


Print_Installed_Methods()
{
    echo "[*] Installed and supported methods:"
    for method in $METHODS; do
        if command -v "$method" >/dev/null; then
            case $method in
                nc) printf "Netcat "            ;;
                ssh) printf "SSH "              ;;
                curl) printf "cURL "            ;;
                node) printf "NodeJS "          ;;
                php) printf "PHP "              ;;
                tclsh) printf "Tcl "            ;;
                openssl) printf "OpenSSL "      ;;
                mongo) printf "MongoDB-Client " ;;
                erl) printf "Erlang "           ;;
                Rscript) printf "R "            ;;
                pwsh) printf "PowerShell "      ;;
                gcc) printf "GCC "              ;;
                elixirc) printf "Elixir "       ;;
                javac) printf "Java-JDK "       ;;
                rustc) printf "Rust "           ;;
                dmd) printf "D "                ;;
                ocaml) printf "OCaml "          ;;
                dotnet) printf ".NET "          ;;
                *)
                    # Else, capitalize first letter and print
                    local fLetter=$(echo $method | cut -c1 | tr [a-z] [A-Z])
                    local restLetters=$(echo $method | cut -c2-)
                    printf "$fLetter$restLetters "
                    ;;
            esac
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
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid --connect [value] (value must be 'all' or 'any')!"
                    # Call function to display usage and terminate app
                    Help
                fi
                ;;

            -s|--sleep)
                if echo "$param2" | grep -Eo '^[0-9]{1,5}$' >/dev/null; then
                    SLEEP_TIME="$param2"
                    shift 2
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid: --sleep [value] (value must be a number)!"
                    Help
                fi
                ;;

            -r|--retry)
                if echo "$param2" | grep -Eo '^([1-9][0-9]{1,4}|[1-9])$' >/dev/null; then
                    RETRIES_COUNT="$param2"
                    shift 2
                elif echo "$param2" | grep -Eo '^(0|inf|infinity)$' >/dev/null; then
                    RETRIES_COUNT="infinity"
                    shift 2
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid: --retries [value] (value must be a number or 'inf'|'infinity')!"
                    Help
                fi
                ;;

            -q|--quiet)
                IS_QUIET_MODE="true"
                shift
                ;;

            -i|--installed)
                # Call function to print installed and supported methods
                Print_Installed_Methods
                ;;

            -h|--help|/?)
                Usage
                ;;

            -*)
                echo "[x] [$(date +%T)] 'c_wait' - Invalid parameters: '$1'!"
                Help
                ;;

            *)
                # Hosts:Ports [default *:80]
                if echo "$param1" | grep -Eo "^[a-zA-Z0-9._-]+(:([1-9]{1}|[0-9]{2,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$" >/dev/null; then
                    local temp_host=$(echo "$param1" | cut -d: -f1)
                    local temp_port=$(echo "$param1" | cut -d: -f2)
                    if [ -z "$temp_port" ] || [ "$temp_port" = "$param1" ]; then temp_port="80"; fi
                    temp_hosts="$temp_hosts $temp_host:$temp_port"
                    shift
                else
                    echo "[x] [$(date +%T)] 'c_wait' - Invalid host values!"
                    Help
                fi
                ;;
        esac
    done

    if [ -z "$temp_hosts" ]; then
        # Missing hosts message : terminate app
        if [ -z "$HOSTS" ]; then echo "[x] [$(date +%T)] 'c_wait' - Missing hosts!"; Terminated; fi
        # Call function to recursively validate host values (if there are no args from input)
        Validate_Args $HOSTS
    else
        # Remove trailing spaces
        HOSTS="$(echo "$temp_hosts" | awk '{$1=$1};1')"
    fi
}


Generate_Exec_Package()
{
    # Args: $1 will contain "MethodHostPort"
    # Global
    EXEC_PACKAGE=$(echo "cwait_$1" | sed 's/\./dot/g')
}


Method_On_Action()
{
    local method="$1"
    local host="$2"
    local port="$3"

    case $method in
        "nc")
            "$method" -zvw"$TIMEOUT" "$host" "$port" >/dev/null 2>&1
            ;;

        "ssh")
            local ssh_res=$($TIMEOUT_CMD "$method" -o BatchMode=yes -p "$port" "$host" 2>&1 | grep -iEo "exchange_identification|Permission denied|verification failed")
            if [ -n "$ssh_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "python"|"python3")
            "$method" -c 'exec("""\nimport socket;socket.setdefaulttimeout('$TIMEOUT');\nif socket.socket(socket.AF_INET,socket.SOCK_STREAM).connect(("'$host'",'$port'))==1:exit(1)\n""")' 2>/dev/null
            ;;

        "bash")
            $TIMEOUT_CMD "$method" -c "echo >/dev/tcp/$host/$port" 2>/dev/null
            ;;

        "curl")
            case $("$method" -kI --connect-timeout "$TIMEOUT" "$host":"$port" 2>&1 | grep -Eo '\([0-9]+\)') in
                ""|"(8)"|"(52)"|"(56)")
                    GOOD_CONNECT_RESULT="0"
                    ;;
            esac
            return
            ;;

        "wget")
            local wget_res=$("$method" -t 1 --spider -S -T "$TIMEOUT" "$host":"$port" 2>&1 | grep -iEo "\<connected\>|\<header\>|\<response\>|http/")
            if [ -n "$wget_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "telnet")
            local telnet_res=$($TIMEOUT_CMD "$method" "$host" "$port" </dev/null 2>/dev/null | grep -io "\<connected\>")
            if [ -n "$telnet_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "socat")
            "$method" /dev/null TCP4:"$host":"$port",connect-timeout="$TIMEOUT" >/dev/null 2>&1
            ;;

        "node")
            "$method" -e "var net=require('net');var s=new net.Socket();s.setTimeout("$TIMEOUT"000,function(){s.destroy()});s.connect($port,'$host',function(){process.exit(0)});s.on('close',function(){process.exit(1)})" 2>/dev/null
            ;;

        "ruby")
            "$method" -e "require 'socket';require 'timeout';Timeout::timeout("$TIMEOUT") do;s=TCPSocket.new('$host',$port);s.close;end" 2>/dev/null
            ;;

        "perl")
            "$method" -e 'use IO::Socket::INET;my $s=new IO::Socket::INET(PeerAddr=>"'$host'",PeerPort=>"'$port'",Proto=>"tcp",Timeout=>"'$TIMEOUT'");if($s){$s->close}else{exit(1)}' 2>/dev/null
            ;;

        "php")
            "$method" -r '$c=@fsockopen("'$host'",'$port',$errno,$errstr,'$TIMEOUT');if(is_resource($c)){fclose($c);}else{exit(1);}' 2>/dev/null
            ;;

        "tclsh")
            echo 'if [catch {socket -async "'$host'" '$port'} s] {exit 1};fileevent $s writable {set c 1};after '$TIMEOUT'000 set c 0;vwait c;if {$c} {close $s;exit 0};catch {exit 1}' | tclsh 2>/dev/null
            ;;

        "openssl")
            local openssl_res=$($TIMEOUT_CMD "$method" s_client -connect "$host":"$port" </dev/null 2>/dev/null | head -1 | grep -io "\<connected\>")
            if [ -n "$openssl_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "gawk")
            $TIMEOUT_CMD "$method" 'BEGIN {S="/inet/tcp/0/'$host'/'$port'";print |& S;x=close(S);exit x}' 2>/dev/null
            ;;

        "ncat")
            "$method" -w "$TIMEOUT" "$host" "$port" </dev/null 2>/dev/null
            ;;

        "nmap")
            local nmap_res=$("$method" --host-timeout "$TIMEOUT"000ms --open "$host" -p "$port" 2>&1 | grep -io "\<open\>")
            if [ -n "$nmap_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "zsh")
            $TIMEOUT_CMD "$method" -c 'zmodload zsh/net/tcp;ztcp '$host' '$port'' 2>/dev/null
            ;;

        "mongo")
            local mongo_res=$($TIMEOUT_CMD "$method" --host "$host" --port "$port" --verbose </dev/null 2>&1 | head -4 | grep -io "\<connected\>")
            if [ -n "$mongo_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "erl")
            "$method" -noshell -eval 'case gen_tcp:connect("'$host'",'$port',[],'$TIMEOUT'000) of {ok,S}->gen_tcp:close(S),init:stop();{error,_}->erlang:halt(1)end.' 2>/dev/null
            ;;

        "clojure")
            "$method" -e '(def s (java.net.Socket.)) (.connect s (java.net.InetSocketAddress. "'$host'" '$port')'$TIMEOUT'000)(.close s)' >/dev/null 2>&1
            ;;

        "groovy")
            "$method" -e 'Socket s=new Socket();s.connect(new InetSocketAddress("'$host'",'$port'),'$TIMEOUT'000);s.close()' 2>/dev/null
            ;;

        "scala")
            "$method" -nobootcp -nc -e 'object T{def main(args:Array[String]){val s=new java.net.Socket();s.connect(new java.net.InetSocketAddress("'$host'",'$port'),'$TIMEOUT'000);s.close()}}' 2>/dev/null
            ;;

        "Rscript")
            $TIMEOUT_CMD "$method" -e 'options(warn=-2);{s<-socketConnection(host="'$host'",port='$port');close(s)}' 2>/dev/null
            ;;

        "pwsh")
            "$method" -Command '$t=New-Object Net.Sockets.TcpClient;$c=$t.BeginConnect("'$host'",'$port',$null,$null);$w=$c.AsyncWaitHandle.WaitOne('$TIMEOUT'000,$false);if(!$w){$t.Close();exit 1}else{if($t.Connected){$t.EndConnect($c);$t.Close()}else{exit 1}}' 2>/dev/null
            ;;

        "gcc"|"clang")
            # Call function to generate exec filename into variable
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.c"
            if [ -s "$EXEC_PACKAGE" ]; then
                ./"$EXEC_PACKAGE" 2>/dev/null
            else
                printf "%s\n" "#include<unistd.h>" "#include<string.h>" "#include<netdb.h>" "#include<sys/socket.h>" "#include<netinet/in.h>" "#include <sys/time.h>" "int main(){int s;struct sockaddr_in sa;struct hostent *sv;s=socket(AF_INET,SOCK_STREAM,0);sv=gethostbyname(\"$host\");if (sv==NULL) return 1;bzero((char *) &sa,sizeof(sa));sa.sin_family=AF_INET;bcopy((char *)sv->h_addr,(char *)&sa.sin_addr.s_addr,sv->h_length);sa.sin_port=htons($port);struct timeval timeout={$TIMEOUT,0};if(setsockopt(s,SOL_SOCKET,SO_SNDTIMEO,(const void*) &timeout,sizeof(timeout))!=0 || connect(s,(struct sockaddr *) &sa,sizeof(sa))<0) return 1;else close(s);}" > "$package" && "$method" "$package" -o "$EXEC_PACKAGE" >/dev/null 2>&1 && ./"$EXEC_PACKAGE" 2>/dev/null
            fi
            ;;

        "elixirc")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.ex"
            if [ -s "$package" ]; then
                "$method" "$package" 2>/dev/null
            else
                echo "case :gen_tcp.connect('$host',$port,[],"$TIMEOUT"000)do{:ok,s}->:gen_tcp.close(s);{:error,_}->System.halt(1);end" > "$package" && "$method" "$package" 2>/dev/null
            fi
            ;;

        "javac")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.java"
            if [ -s "$EXEC_PACKAGE" ]; then
                java "$EXEC_PACKAGE" 2>/dev/null
            else
                echo 'import java.net.Socket;import java.net.InetSocketAddress;class '$EXEC_PACKAGE'{public static void main(String[] args){try{Socket s=new Socket();s.connect(new InetSocketAddress("'$host'",'$port'),'$TIMEOUT'000);s.close();}catch(Exception e){System.exit(1);}}}' > "$package" && "$method" "$package" >/dev/null 2>&1 && java "$EXEC_PACKAGE" 2>/dev/null
            fi
            ;;

        "rustc")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.rs"
            if [ -s "$EXEC_PACKAGE" ]; then
                ./"$EXEC_PACKAGE" 2>/dev/null
            else
                echo 'use std::net::TcpStream;use std::time::Duration;use std::process::exit;use std::net::ToSocketAddrs;use std::net::SocketAddr;fn r_ad()->Result<SocketAddr,String>{let mut ad=match "'$host:$port'".to_socket_addrs(){Ok(ad)=>ad,Err(_e)=>exit(1),};match ad.next(){None=>exit(1),Some(ad)=>Ok(ad),}}fn main(){if let Err(_e)=TcpStream::connect_timeout(&r_ad().unwrap(),Duration::from_secs('$TIMEOUT')){exit(1)}}' > "$package" && "$method" "$package" -o "$EXEC_PACKAGE" >/dev/null 2>&1 && ./"$EXEC_PACKAGE" 2>/dev/null
            fi
            ;;

        "go")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.go"
            if [ -s "$package" ]; then
                "$method" run "$package" 2>/dev/null
            else
                echo 'package main;import("net";"os";"time";);func main(){c,e:=net.DialTimeout("tcp","'$host:$port'",time.Duration('$TIMEOUT')*time.Second);if e,ok:=e.(*net.OpError);ok && e.Timeout(){os.Exit(1)};if e!=nil{os.Exit(1)};defer c.Close()}' > "$package" && "$method" run "$package" 2>/dev/null
            fi
            ;;

        "dart")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.dart"
            if [ -s "$package" ]; then
                "$method" "$package" 2>/dev/null
            else
                echo 'import "dart:io";void main(){new Future.delayed(new Duration(seconds:'$TIMEOUT'),(){exit(1);});Socket.connect("'$host'",'$port').then((socket){socket.destroy();exit(0);});}' > "$package" && "$method" "$package" 2>/dev/null
            fi
            ;;

        "dmd")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.d"
            if [ -s "$EXEC_PACKAGE" ]; then
                ./"$EXEC_PACKAGE" 2>/dev/null
            else
                echo 'import std.socket;import std.datetime;void main(){auto s=new Socket(AddressFamily.INET,SocketType.STREAM,ProtocolType.TCP);s.setOption(SocketOptionLevel.SOCKET,SocketOption.SNDTIMEO,'$TIMEOUT'.seconds);scope(exit){s.close();}auto addresses=getAddress("'$host'",'$port');s.connect(addresses[0]);}' > "$package" && "$method" -of="$EXEC_PACKAGE" "$package" >/dev/null 2>&1 && ./"$EXEC_PACKAGE" 2>/dev/null
            fi
            ;;

        "nim")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.nim"
            if [ -s "$EXEC_PACKAGE" ]; then
                ./"$EXEC_PACKAGE" 2>/dev/null
            else
                printf "%s\n" "from threadpool import spawn;from os import sleep;import net;" "proc sum():void=" "    let s:Socket=newSocket();s.connect(\"$host\",Port($port));s.close();system.quit(QuitSuccess);" "spawn sum();sleep("$TIMEOUT"000);system.quit(QuitFailure);" > "$package" && "$method" c --opt:speed --threads:on -d:release -o:"$EXEC_PACKAGE" "$package" >/dev/null 2>&1 && ./"$EXEC_PACKAGE" 2>/dev/null
            fi
            ;;

        "ocaml")
            Generate_Exec_Package "$method$host$port"
            local package="$EXEC_PACKAGE.ml"
            if [ -s "$package" ]; then
                "$method" unix.cma "$package" 2>/dev/null
            else
                echo 'open Unix;;let ad=ADDR_INET((gethostbyname "'$host'").h_addr_list.(0),'$port') in let s=socket PF_INET SOCK_STREAM 0 in setsockopt_float s SO_SNDTIMEO '$TIMEOUT'.0;connect s ad;shutdown s SHUTDOWN_ALL' > "$package" && "$method" unix.cma "$package" 2>/dev/null
            fi
            ;;

        "dotnet")
            local project="$method.csproj"
            if ! [ -s "$project" ]; then echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>netcoreapp2.1</TargetFramework></PropertyGroup></Project>' > "$project"; fi
            echo 'using System.Net.Sockets;using static System.Environment;namespace T{class T{static void Main(){Socket s=new Socket(AddressFamily.InterNetwork,SocketType.Stream,ProtocolType.Tcp);s.BeginConnect("'$host'",'$port',null,null).AsyncWaitHandle.WaitOne('$TIMEOUT'000,true);if(s.Connected)s.Close();else Exit(1);}}}' > "$method.cs" && "$method" run -c cwait >/dev/null 2>&1
            ;;

        *)
            echo "[x] [$(date +%T)] 'c_wait' - Method '$method' is not exist or not linked correctly!"
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
            # Call function to try-connect using the selected method
            Method_On_Action "$method" "$host" "$port"
            break
        fi
    done

    # UNSUPPORTED METHOD message : exit app if failed to identify any connection-methods
    if [ -z "$USED_METHOD" ]; then echo; echo "[x] [$(date +%T)] 'c_wait' - Failed to check for connections, Unable to locate any supported method :("; Terminated; fi
}


Main()
{
    # Call function to check for missing files and make some configurations
    Check_Missing_Files_AND_Make_Config

    # Optimize args + call function to validate args
    local args="$(echo $@ | tr '[:upper:]' '[:lower:]' | sed 's/,/ /g')"
    Validate_Args $args

    # INIT message
    if [ -n "$INIT_MESSAGE" ]; then echo "[*] [$(date +%T)] $INIT_MESSAGE [hosts: '$HOSTS' # connection-mode: '$CONNECT_MODE' # sleep: '$SLEEP_TIME' second(s) # max-retries: '$RETRIES_COUNT' # quiet-mode: '$IS_QUIET_MODE'] ..."; fi

    # Loop while checking for open connections
    local retries_count=$(echo "$RETRIES_COUNT" | sed 's/infinity/-1/')
    local r_counter=1
    while [ $r_counter -ne $((retries_count+1)) ]; do
        local success=""
        sleep "$((SLEEP_TIME-1))"
        if [ -n "$FAIL_MESSAGE" ] && [ "$IS_QUIET_MODE" != "true" ]; then echo; echo "[*] [$(date +%T)] 'c_wait' - tries ($r_counter/$RETRIES_COUNT) ..."; fi

        for host_n_port in $HOSTS; do
            # Call function to check for open connection
            Check_Methods "$host_n_port"
            sleep 1

            if [ -n "$GOOD_CONNECT_RESULT" ]; then
                # SUCCESS message
                if [ -n "$CONNECT_MESSAGE" ] && [ "$IS_QUIET_MODE" != "true" ]; then echo "[+] [$(date +%T)] $USED_METHOD - $host_n_port - $CONNECT_MESSAGE"; fi
                success="0"
                if [ "$CONNECT_MODE" = "any" ]; then break; fi
            else
                # FAIL message
                if [ -n "$FAIL_MESSAGE" ] && [ "$IS_QUIET_MODE" != "true" ]; then echo "[-] [$(date +%T)] $USED_METHOD - $host_n_port - $FAIL_MESSAGE"; fi
                success="1"
                if [ "$CONNECT_MODE" = "all" ]; then break; fi
            fi
        done

        # DONE message : exit app successfully
        if [ "$success" = "0" ]; then if [ -n "$DONE_MESSAGE" ]; then echo; echo "[v] [$(date +%T)] $DONE_MESSAGE"; echo; fi; exit 0; fi

        r_counter=$((r_counter=r_counter+1))
    done

    # If reached here: exit app with failure (end of retries)
    Terminated
}


Check_Missing_Files_AND_Make_Config()
{
    # If grep is not exist or incompatible version -> UNSUPPORTED SYSTEM message : terminate app
    if ! command -v "grep" >/dev/null; then echo; echo "[x] [$(date +%T)] 'c_wait' - Failed to initialize :( Missing system file: 'grep' or not linked correctly."; Terminated; fi
    # Disable grep on Solaris (old grep is not good enough for this script)
    if grep -v 2>&1 | grep "pattern file \." >/dev/null; then echo; echo "[x] [$(date +%T)] 'c_wait' - Failed to initialize :( System file: 'grep' is incompatible for this script."; Terminated; fi

    # Organize methods (no duplicates)
    METHODS=$(echo "$METHODS" | tr ' ' '\n' | awk '!x[$0]++' | tr '\n' ' ')

    TIMEOUT_CMD="" # Global
    if command -v "timeout" >/dev/null; then
        # The timeout options ('timeout' is for the standard / GNU version, 'timeout -t' is for the old version of BusyBox)
        TIMEOUT_CMD=$(timeout --version 2>&1 | head -2 | grep -io "\-t secs")
        if [ -z "$TIMEOUT_CMD" ]; then TIMEOUT_CMD="timeout -s 2 $TIMEOUT"; else TIMEOUT_CMD="timeout -t $TIMEOUT -s 2"; fi
    elif command -v "gtimeout" >/dev/null; then
        # Old macOS 'gtimeout'
        TIMEOUT_CMD="gtimeout -s 2 $TIMEOUT"
    else
        # If timeout is not exist -> show a warning and move the affected methods to the bottom of the priority (last to be checked)
        local timeout_methods="bash ssh telnet openssl gawk zsh mongo Rscript"
        if [ "$IS_QUIET_MODE" != "true" ]; then echo "[-] [$(date +%T)] 'c_wait' - Missing system file: 'timeout'. This might lower the performance of the following methods: '$timeout_methods'."; fi
        for move_method in $timeout_methods; do METHODS=$(echo "$METHODS" | sed 's/'$move_method'\(.*\)/\1 '$move_method'/'); done
    fi

    # Validate javac & gcc & clang if they are installed properly (for macOS)
    if [ -n "$(javac --version 2>&1 | grep -io 'no java')" ]; then METHODS=$(echo "$METHODS" | sed 's/javac//g'); fi
    for validate_mac_method in "gcc" "clang"; do if [ -n "$($validate_mac_method --help 2>&1 | grep -io 'developer tools')" ]; then METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$validate_mac_method'")$o=""}1'); fi; done

    # Check and change to writable tmp directory to store the compiled files
    local writable_dir=""
    for w_dir in "/tmp" "/var/tmp" "/usr/tmp" "/usr/local/tmp" "/dev/shm" "/var/lock" "$(pwd)"; do if [ -w "$w_dir" ]; then writable_dir="$w_dir"; cd "$w_dir" >/dev/null; rm -rf cwait_* obj bin/cwait*; break; fi; done

    # Check if there is no writable directory then disable some methods (related to compilations)
    if [ -z "$writable_dir" ]; then
        local compilation_methods="gcc clang elixirc javac rustc go dart dmd nim ocaml dotnet"
        if [ "$IS_QUIET_MODE" != "true" ]; then echo "[-] [$(date +%T)] 'c_wait' - Insufficient folders permission. The following methods will be disabled: '$compilation_methods'."; fi
        for disable_method in $compilation_methods; do METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$disable_method'")$o=""}1'); done
    fi
}



Main -c "$CONNECT_MODE" -s "$SLEEP_TIME" -r "$RETRIES_COUNT" $@
