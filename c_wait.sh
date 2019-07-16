#!/bin/sh

# 'c_wait' ConnectionWait v1.1.0
# Author: Alaa H.J <MasterX>

# DO NOT TOUCH THE METHODS BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING!
# Methods health-check order [if X method exists in the machine] (you can change the methods order, or if you want to disable/enable some methods):
METHODS="nc ncat python python3 bash curl wget telnet socat node perl ruby php tclsh erl gawk nmap scala Rscript pwsh gcc clang javac elixirc rustc go dart dmd nim dotnet"
# Netcat, Ncat, Python2, Python3, Bash, cURL, Wget, Telnet, Socat, NodeJS, Perl, Ruby, PHP, TCL, Erlang, Gawk, Nmap, Scala, R, PowerShell, GCC, LLVM Clang, JavaJDK, Elixir, Rust, Go, Dart, D, Nim, .NET
# @ The BusyBox version of wget & telnet is not supported.

# Default global values:
HOSTS="8.8.8.8:53 db:3306" # IPs / HostNames.           Example: db:3306,db2:5432,0.0.0.0,google.com
SLEEP_TIME="3" # Sleep for X seconds.
RETRIES_COUNT="inf" # Max-retries for health-check.     '0' | 'inf' | 'infinity': For infinity connection-retries.
CONNECT_MODE="all" # Options: 'all' / 'any'.            'all': It will pass if all selected hosts are connected. | 'any': It will pass if any of the selected hosts are connected.
IS_QUIET_MODE="false" # Options: 'true' / 'false'.      Hide / show output messages (but always alert when the app is about to get started or terminated).

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
    echo "['c_wait' - ConnectionWait v1.1.0]"
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
    echo "     (minimal output messages? '$IS_QUIET_MODE')"
    echo
    echo "  -h | --help | /?"
    echo "     (show this usage)"
    echo
    Terminated
}


Help()
{
    echo "[*] Use '$0 --help' for Usage."
    echo
    Terminated
}


Invalid_Params()
{
    # Accepts error messages or prints default error message
    if [ $# -eq 0 ]; then echo "[x] [$(date +%T)] 'c_wait' - Invalid parameters / default options."; else echo "$1"; fi
    Help
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
                    Invalid_Params "[x] [$(date +%T)] 'c_wait' - Invalid --connect value (use '--connect all' or '--connect any')."
                fi
                ;;

            -s|--sleep)
                if echo "$param2" | grep -Eo '^[0-9]{1,5}$' >/dev/null; then
                    SLEEP_TIME="$param2"
                    shift 2
                else
                    Invalid_Params "[x] [$(date +%T)] 'c_wait' - Invalid --sleep value (must be a number)."
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
                    Invalid_Params "[x] [$(date +%T)] 'c_wait' - Invalid --retries value (must be a number or 'inf'|'infinity')."
                fi
                ;;

            -q|--quiet)
                IS_QUIET_MODE="true"
                shift
                ;;

            -h|--help|/?)
                Usage
                ;;

            -*)
                Invalid_Params
                ;;

            *)
                # Hosts:Ports, default port is 80 if not set with hosts (example: google.com <- port 80)
                if echo "$param1" | grep -Eo "^[a-zA-Z0-9._-]+(:([1-9]{1}|[0-9]{2,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]))?$" >/dev/null; then
                    local temp_host=$(echo "$param1" | cut -d: -f1)
                    local temp_port=$(echo "$param1" | cut -d: -f2)
                    if [ -z "$temp_port" ] || [ "$temp_port" = "$param1" ]; then temp_port="80"; fi
                    temp_hosts="$temp_hosts $temp_host:$temp_port"
                    shift
                else
                    Invalid_Params
                fi
                ;;
        esac
    done

    if [ -z "$temp_hosts" ]; then
        # Missing hosts message : terminate app
        if [ -z "$HOSTS" ]; then echo "[x] [$(date +%T)] 'c_wait' - Missing hosts!"; Terminated; fi
        # Recursive to validate hosts string (if no args there to check)
        Validate_Args $HOSTS
    else
        HOSTS="$temp_hosts"
    fi
}


Method_On_Action()
{
    local method="$1"
    local host="$2"
    local port="$3"

    case $method in
        "nc")
            "$method" -zvw2 "$host" "$port" >/dev/null 2>&1
            ;;

        "ncat")
            "$method" -w 2 "$host" "$port" < /dev/null 2>/dev/null
            ;;

        "python"|"python3")
            "$method" -c 'exec("""\nimport socket;socket.setdefaulttimeout(2);\ntry:exit(0) if 0 == socket.socket(socket.AF_INET,socket.SOCK_STREAM).connect_ex(("'$host'",'$port')) else exit(1)\nexcept socket.error:exit(1)\n""")' 2>/dev/null
            ;;

        "bash")
            $TIMEOUT_CMD "$method" -c "echo >/dev/tcp/$host/$port" 2>/dev/null
            ;;

        "curl")
            case $("$method" -kI --connect-timeout 2 "$host":"$port" 2>&1 | grep -Eo '\([0-9]+\)') in
                ""|"(8)"|"(52)"|"(56)")
                    GOOD_CONNECT_RESULT="0"
                    ;;
            esac
            return
            ;;

        "wget")
            local wget_res=$("$method" -t 1 --spider --connect-timeout 2 "$host":"$port" 2>&1 | grep -iEo "\<connected\>|\<header\>|\<response\>")
            if [ -n "$wget_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "telnet")
            local telnet_res=$($TIMEOUT_CMD "$method" "$host" "$port" 2>&1 | grep -io "\<connected\>")
            if [ -n "$telnet_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "socat")
            "$method" /dev/null TCP4:"$host":"$port",connect-timeout=2 >/dev/null 2>&1
            ;;

        "node")
            "$method" -e "var net=require('net');var s=new net.Socket();s.setTimeout(2000,function(){s.destroy();});s.connect($port,'$host',function(){process.exit(0);});s.on('close',function(){process.exit(1);});s.on('error',function(){process.exit(1);});" 2>/dev/null
            ;;

        "perl")
            "$method" -e 'use IO::Socket::INET;my $s=new IO::Socket::INET(PeerAddr=>"'$host'",PeerPort=>"'$port'",Proto=>"tcp",Timeout=>"2");if($s){$s->close;exit(0);}else{exit(1);};' 2>/dev/null
            ;;

        "ruby")
            "$method" -e "require 'socket';require 'timeout';begin;Timeout::timeout(2) do;begin;s=TCPSocket.new('$host',$port);s.close;exit(0);end;end;rescue;exit(1);end" 2>/dev/null
            ;;

        "php")
            "$method" -r '$c=@fsockopen("'$host'",'$port',$errno,$errstr,2);if(is_resource($c)){fclose($c);exit(0);}else{exit(1);}' 2>/dev/null
            ;;

        "tclsh")
            echo 'if [catch {socket -async "'$host'" '$port'} s] {exit 1;};fileevent $s writable {set c 1};after 2000 set c 0;vwait c;if {$c} {exit 0};catch {close $s;exit 1}' | tclsh 2>/dev/null
            ;;

        "erl")
            "$method" -noshell -eval 'case gen_tcp:connect("'$host'",'$port',[],2000) of {ok,S}->gen_tcp:close(S),init:stop();{error,_}->erlang:halt(1)end.' 2>/dev/null
            ;;

        "gawk")
            $TIMEOUT_CMD "$method" 'BEGIN {S="/inet/tcp/0/'$host'/'$port'";print |& S;x=close(S);exit x}' 2>/dev/null
            ;;

        "nmap")
            local nmap_res=$("$method" --host-timeout 2000ms --open "$host" -p "$port" 2>&1 | grep -io "\<open\>")
            if [ -n "$nmap_res" ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "scala")
            "$method" -e 'object TestPort{def main(args: Array[String]){try{val s=new java.net.Socket();s.connect(new java.net.InetSocketAddress("'$host'",'$port'),2000);s.close();System.exit(0);}catch{case e: Exception=>{System.exit(1);}}}}' 2>/dev/null
            ;;

        "Rscript")
            $TIMEOUT_CMD "$method" -e 'options(warn=-2);tryCatch({s<-socketConnection(host="'$host'",port='$port');close(s);quit(status=0)},error=function(e){quit(status=1)})' 2>/dev/null
            ;;

        "pwsh")
            "$method" -Command '$t=New-Object Net.Sockets.TcpClient;$c=$t.BeginConnect("'$host'",'$port',$null,$null);$w=$c.AsyncWaitHandle.WaitOne(2000,$false);if(!$w){$t.Close();exit 1;}else{if($t.Connected){$t.EndConnect($c);$t.Close();exit 0;}else{$t.Close();exit 1;}}' 2>/dev/null
            ;;

        "gcc"|"clang")
            local package="cwait_$host$port.cpp"
            local exec_package=$(echo "cwait_cpp_$host$port" | sed 's/\./dot/g')
            if [ -s "$exec_package" ]; then
                ./"$exec_package" 2>/dev/null
            else
                echo '''
                    #include<unistd.h>
                    #include<string.h>
                    #include<netdb.h>
                    #include<sys/socket.h>
                    #include<netinet/in.h>
                    int main(){int s;struct sockaddr_in sa;struct hostent *sv;s=socket(AF_INET,SOCK_STREAM,0);if (s<0) return 1;sv=gethostbyname("'$host'");if (sv==NULL) return 1;bzero((char *) &sa,sizeof(sa));sa.sin_family=AF_INET;bcopy((char *)sv->h_addr,(char *)&sa.sin_addr.s_addr,sv->h_length);sa.sin_port=htons('$port');struct timeval timeout={2,0};if(setsockopt(s,SOL_SOCKET,SO_SNDTIMEO,(const void*) &timeout,sizeof(timeout))!=0) return 1;if(connect(s,(struct sockaddr *) &sa,sizeof(sa))<0)return 1;else{close(s);return 0;}}
                    ''' > "$package" && "$method" "$package" -o "$exec_package" >/dev/null 2>&1 && ./"$exec_package" 2>/dev/null
            fi
            ;;

        "javac")
            local package="cwait_$host$port.java"
            local class_package=$(echo "cwait_java_$host$port" | sed 's/\./dot/g')
            if [ -s "$class_package" ]; then
                java "$class_package" 2>/dev/null
            else
                echo 'import java.net.Socket;import java.net.InetSocketAddress;class '$class_package'{public static void main(String[] args){try{Socket s=new Socket();s.connect(new InetSocketAddress("'$host'",'$port'),2000);s.close();System.exit(0);}catch(Exception e){System.exit(1);}}}' > "$package" && "$method" "$package" >/dev/null 2>&1 && java "$class_package" 2>/dev/null
            fi
            ;;

        "elixirc")
            local package="cwait_$host$port.ex"
            if [ -s "$package" ]; then
                "$method" "$package" 2>/dev/null
            else
                echo "case :gen_tcp.connect('$host',$port,[],2000)do{:ok,s}->:gen_tcp.close(s);System.halt(0);{:error,_}->System.halt(1);end" > "$package" && "$method" "$package" 2>/dev/null
            fi
            ;;

        "rustc")
            local package="$(echo "cwait_$host$port" | sed 's/\./dot/g').rs"
            local exec_package=$(echo "cwait_rs_$host$port" | sed 's/\./dot/g')
            if [ -s "$exec_package" ]; then
                ./"$exec_package" 2>/dev/null
            else
                echo 'use std::net::TcpStream;use std::time::Duration;use std::process::exit;use std::net::ToSocketAddrs;use std::net::SocketAddr;fn r_ad()->Result<SocketAddr,String>{let mut ad=match "'$host:$port'".to_socket_addrs(){Ok(ad)=>ad,Err(_e)=>exit(1),};match ad.next(){None=>exit(1),Some(ad)=>Ok(ad),}}fn main(){if let Ok(_s)=TcpStream::connect_timeout(&r_ad().unwrap(),Duration::from_secs(2)){exit(0);}else{exit(1);}}' > "$package" && "$method" "$package" -o "$exec_package" >/dev/null 2>&1 && ./"$exec_package" 2>/dev/null
            fi
            ;;

        "go")
            local package="cwait_$host$port.go"
            if [ -s "$package" ]; then
                "$method" run "$package" 2>/dev/null
            else
                echo 'package main;import("net";"os";"time";);func main(){c,e:=net.DialTimeout("tcp","'$host:$port'",time.Duration(2)*time.Second);if e,ok:=e.(*net.OpError);ok && e.Timeout(){os.Exit(1);};if e!=nil{os.Exit(1);};defer c.Close();os.Exit(0);}' > "$package" && "$method" run "$package" 2>/dev/null
            fi
            ;;

        "dart")
            local package="cwait_$host$port.dart"
            if [ -s "$package" ]; then
                "$method" "$package" 2>/dev/null
            else
                echo 'import "dart:io";void main(){new Future.delayed(new Duration(seconds:2),(){exit(1);});Socket.connect("'$host'",'$port').then((socket){socket.destroy();exit(0);}).catchError((e){exit(1);});}' > "$package" && "$method" "$package" 2>/dev/null
            fi
            ;;

        "dmd")
            local package="$(echo "cwait_$host$port" | sed 's/\./dot/g').d"
            local exec_package=$(echo "cwait_d_$host$port" | sed 's/\./dot/g')
            if [ -s "$exec_package" ]; then
                ./"$exec_package" 2>/dev/null
            else
                echo 'import std.socket;import std.datetime;int main(){auto s=new Socket(AddressFamily.INET,SocketType.STREAM,ProtocolType.TCP);s.setOption(SocketOptionLevel.SOCKET,SocketOption.SNDTIMEO,2.seconds);scope(exit){s.close();}try{auto addresses=getAddress("'$host'",'$port');s.connect(addresses[0]);return(0);}catch(SocketException){return(1);}}' > "$package" && "$method" -of="$exec_package" "$package" >/dev/null 2>&1 && ./"$exec_package" 2>/dev/null
            fi
            ;;

        "nim")
            local package="$(echo "cwait_$host$port" | sed 's/\./dot/g').nim"
            local exec_package=$(echo "cwait_nim_$host$port" | sed 's/\./dot/g')
            if [ -s "$exec_package" ]; then
                ./"$exec_package" 2>/dev/null
            else
                # DO NOT TOUCH
                printf "%s\n" "from threadpool import spawn;from os import sleep;import net;" "proc sum():void=" "    let s:Socket=newSocket();try:" "        s.connect(\"$host\",Port($port));s.close();system.quit(QuitSuccess);" "    except:" "        system.quit(QuitFailure);" "spawn sum();sleep(2000);system.quit(QuitFailure);" > "$package" && "$method" c --run --opt:speed --threads:on -d:release -o:"$exec_package" "$package" >/dev/null 2>&1
            fi
            ;;

        "dotnet")
            local project="cwait_csharp.csproj"
            if ! [ -s "$project" ]; then echo '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>netcoreapp2.1</TargetFramework></PropertyGroup></Project>' > "$project"; fi
            echo 'using System.Net.Sockets;using static System.Environment;namespace TestPort{class TestPort{static void Main(){Socket s=new Socket(AddressFamily.InterNetwork,SocketType.Stream,ProtocolType.Tcp);s.BeginConnect("'$host'",'$port',null,null).AsyncWaitHandle.WaitOne(2000,true);if (s.Connected){s.Close();Exit(0);}else Exit(1);}}}' > cwait_csharp.cs && "$method" run -c cwait >/dev/null 2>&1
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
    for method in $METHODS
    do
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
    # Optimize args + call function to validate args
    local args="$(echo $@ | tr '[:upper:]' '[:lower:]' | sed 's/,/ /g')"
    Validate_Args $args

    # Call function to check for missing files and make some configurations
    Check_Missing_Files_AND_Make_Config

    local r_counter=1
    local retries_count=$(echo "$RETRIES_COUNT" | sed 's/infinity/-1/')

    # INIT message
    if [ -n "$INIT_MESSAGE" ]; then echo "[*] [$(date +%T)] $INIT_MESSAGE [hosts: '$HOSTS' # connection-mode: '$CONNECT_MODE' # sleep: '$SLEEP_TIME' second(s) # max-retries: '$RETRIES_COUNT' # quiet-mode: '$IS_QUIET_MODE'] ..."; fi

    # Loop while checking for open connections
    while [ $r_counter -ne $((retries_count+1)) ]
    do
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
    # If grep is not exist -> UNSUPPORTED SYSTEM message : terminate app
    if ! command -v "grep" >/dev/null; then echo; echo "[x] [$(date +%T)] 'c_wait' - Failed to initialize :( Missing system file: 'grep' or not linked correctly."; Terminated; fi

    # Organize methods (no duplicates)
    METHODS=$(echo "$METHODS" | tr ' ' '\n' | awk '!x[$0]++' | tr '\n' ' ')

    TIMEOUT_CMD="" # Global
    if command -v "timeout" >/dev/null; then
        # The timeout options (timeout / timeout -t)
        TIMEOUT_CMD=$(timeout --version 2>&1 | head -2 | grep -io "\<busybox\>")
        if [ -z "$TIMEOUT_CMD" ]; then TIMEOUT_CMD="timeout 2"; else TIMEOUT_CMD="timeout -t 2"; fi
    elif command -v "gtimeout" >/dev/null; then
        # macOS gtimeout
        TIMEOUT_CMD="gtimeout 2"
    else
        # If timeout is not exist -> show a warning and move the affected methods to the bottom of the priority (last to be checked)
        local timeout_methods="bash telnet Rscript gawk"
        if [ "$IS_QUIET_MODE" != "true" ]; then echo "[-] [$(date +%T)] 'c_wait' - Missing system file: 'timeout'. This might lower the performance of the following methods: '$timeout_methods'."; fi
        for move_method in $timeout_methods; do METHODS=$(echo "$METHODS" | sed 's/'$move_method'\(.*\)/\1 '$move_method'/'); done
    fi

    # Validate telnet & wget versions (BusyBox version is supported)
    for busybox_method in "telnet" "wget"; do if [ -n "$($busybox_method --help 2>&1 | head -1 | grep -io '\<busybox\>')" ]; then METHODS=$(echo "$METHODS" | sed 's/'$busybox_method'//g'); fi; done

    # Validate javac & gcc & clang if they are installed properly (for macOS)
    if [ -n "$(javac --version 2>&1 | grep -io 'no java')" ]; then METHODS=$(echo "$METHODS" | sed 's/javac//g'); fi
    for validate_mac_method in "gcc" "clang"; do if [ -n "$($validate_mac_method --help 2>&1 | grep -io 'developer tools')" ]; then METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$validate_mac_method'")$o=""}1'); fi; done

    # Check and change to writable tmp directory to store the compiled files
    local writable_dir=""
    for w_dir in "/tmp" "/var/tmp" "/usr/tmp" "/var/lock" "$(pwd)"; do if [ -w "$w_dir" ]; then writable_dir="$w_dir"; cd "$w_dir" >/dev/null; rm -rf cwait_* obj bin/cwait*; break; fi; done

    # Check if there is no writable directory then disable some methods (related to compilations)
    if [ -z "$writable_dir" ]; then
        local compilation_methods="gcc clang javac elixirc rustc go dart dmd nim dotnet"
        if [ "$IS_QUIET_MODE" != "true" ]; then echo "[-] [$(date +%T)] 'c_wait' - Insufficient folders permission. The following methods will be disabled: '$compilation_methods'."; fi
        for disable_method in $compilation_methods; do METHODS=$(echo "$METHODS" | awk '{for(o=1;o<=NF;o++)if($o=="'$disable_method'")$o=""}1'); done
    fi
}


Main -c "$CONNECT_MODE" -s "$SLEEP_TIME" -r "$RETRIES_COUNT" $@
