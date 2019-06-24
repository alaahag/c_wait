#!/bin/sh
# You can replace the above shebang line with: #!/usr/bin/env sh   (but I don't recommend it on docker-images)

# 'c_wait' ConnectionWait
# Author: Alaa H.J <MasterX>


# Features:
# * Optimized for Docker images (including full support for the most popular docker-OS-images: Alpine, Ubuntu, CentOS, Fedora, Debian, AmazonLinux, OracleLinux, ROS, CirrOS, Mageia, ClearLinux, SourceMage, openSUSE).
# * Supporting lots of test-methods (to check for open-connection).
# * You can choose to run by app using args or by the default values.
# * You can add unlimited number of hosts.
# * Allow connection-conditions
#     (1. 'all' hosts must be connected to complete the task.
#     (2. 'any' of the hosts must be connected to complete the task.
# * Custom messages (easily editable from global values below).
# * Simple, user-friendly and easy to use.

# Methods test-order (you can change the methods order here, or if you want to disable/enable some methods):
METHODS="nc ncat python python3 bash curl wget telnet socat nmap node perl ruby php scala gcc g++ tclsh javac elixirc go"
# Note: telnet & wget (the BusyBox versions only) are not supported!

# Default global values:
HOSTS="db:3306 db2:5432 0.0.0.0" # IPs/Hostnames.   example: db:3306,db2:5432,0.0.0.0,google.com
SLEEP_TIME="3" # Delay (seconds) after each set of failed connections. default is '3' second(s)
CONNECT_TYPE="all" # Options: 'all'/'any'      'all': will pass if all selected hosts are connected        'any': will pass if any of the selected hosts are connected

# Custom messages:
readonly CONNECT_MESSAGE="'c_wait' - Connection Succeed!" # Show a custom message when successfully connected to the host (you can clear the text to supress this message).
readonly FAIL_MESSAGE="'c_wait' - Connection Failed!" # Show a custom message when failed connecting to the host (you can clear the text to supress this message).
readonly INIT_MESSAGE="'c_wait' - Initializing" # Show a custom message when app is about to get started (you can clear the text to supress this message).
readonly DONE_MESSAGE="'c_wait' - Task Completed :)" # Show a custom message when app is about to get terminated after successfully connected to the hosts (you can clear the text to supress this message).
readonly UNSUPPORTED_METHOD_MESSAGE="'c_wait' - Failed to check for connections, Unable to locate any supported method :(" # show a custom message when the app fails to check for connections (non existing helper-methods).
readonly UNSUPPORTED_SYSTEM_MESSAGE="'c_wait' - Failed to initialize. Unsupported system :(" # show a custom message when failed to find "grep" in system.


Usage()
{
    echo "--------------------------------------------------------------------------"
    echo "-=-                   'c_wait' - ConnectionWait v1.0                   -=-"
    echo "--------------------------------------------------------------------------"
    echo "Usage:    $0 --connect <all/any> --sleep <seconds> <hosts:ports>"
    echo
    echo "Examples:"
    echo "          $0 192.168.1.1:22"
    echo "          $0 -s 10 myserver:8000"
    echo "          $0 -c any localhost mydb1:5432 mydb2:3306 myftp:21"
    echo "          $0 --connect all -sleep 5 google.com 0.0.0.0:443"
    echo
    echo "Default options:"
    echo "          Hosts:              '$HOSTS'"
    echo "          -c|--connect        '$CONNECT_TYPE' of the selected host(s)"
    echo "          -s|--sleep          '$SLEEP_TIME' second(s)"
    echo
    exit 1
}


Help()
{
    echo "[-] Use '$0 --help' for Usage."
    echo
    exit 1
}


Invalid_Params()
{
    # Accepts error messages or prints default error message
    echo
    if [ $# -eq 0 ]; then echo "[x] Invalid parameters / default options."; else echo "$1"; fi
    echo
    Help
}


Validate_Args()
{
    local temp_hosts=""
	until [ -z "$1" ]; do
        local param1="$1"
        local param2=""

        if ! [ -z "$2" ]; then param2="$2"; fi

	    case "$param1" in
			-c|--connect)
                if [ "$param2" = "any" ] || [ "$param2" = "all" ]; then
                    CONNECT_TYPE="$param2"
                    shift 2
                else
                    Invalid_Params "[x] Invalid --connect value (use '--connect all' or '--connect any')."
                fi
				;;

			-s|--sleep)
                if echo "$param2" | grep -Eo '^[0-9]{1,5}$' >/dev/null; then
                    SLEEP_TIME="$param2"
                    shift 2
                else
                    Invalid_Params "[x] Invalid --sleep value (must be a digit)."
                fi
				;;

			-h|--help|/\?)
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

    HOSTS="$temp_hosts"
}


Method_On_Action()
{
    local method=$1
    local host="$2"
    local port=$3

    case $method in
        "nc")
            $method -z -v -w2 "$host" $port 2>/dev/null
            ;;

        "ncat")
            $method -w 2 "$host" $port < /dev/null 2>/dev/null
            ;;

        "python"|"python3")
            $method -c "import socket;socket.setdefaulttimeout(2);exit(0) if 0==socket.socket(socket.AF_INET,socket.SOCK_STREAM).connect_ex(('$host',$port)) else exit(1)" 2>/dev/null
            ;;

        "bash")
            $TIMEOUT_CMD 2 $method -c "echo >/dev/tcp/"$host"/$port" 2>/dev/null
            ;;

        "curl")
            case $($method -kI --connect-timeout 2 "$host":$port 2>&1 | grep -Eo '\([0-9]+\)') in
                ""|"(8)"|"(52)"|"(56)")
                    GOOD_CONNECT_RESULT="0"
                    ;;
            esac
            return
            ;;

        "wget")
            if ! [ -z $($method -t 1 --spider --connect-timeout 2 "$host":$port 2>&1 | head -4 | grep -Eo "\b(connected|header|response)\b") ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "telnet")
            if ! [ -z $($TIMEOUT_CMD 2 $method "$host" $port 2>&1 | grep -o "\bConnected\b") ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "socat")
            $method /dev/null TCP4:"$host":$port,connect-timeout=2 >/dev/null 2>&1
            ;;

        "nmap")
            if ! [ -z $($method --host-timeout 2000ms --open "$host" -p $port 2>&1 | grep -o "\bopen\b") ]; then GOOD_CONNECT_RESULT="0"; fi
            return
            ;;

        "node")
            $method -e "var net=require('net');var s=new net.Socket();s.setTimeout(2000,function(){s.destroy();});s.connect($port,'$host',function(){process.exit(0);});s.on('close',function(){process.exit(1);});" 2>/dev/null
            ;;

        "perl")
            $method -e 'use IO::Socket::INET;my $s=new IO::Socket::INET(PeerAddr=>"'$host'",PeerPort=>"'$port'",Proto=>"tcp",Timeout=>"2");if($s){$s->close;exit(0);}else{exit(1);};' 2>/dev/null
            ;;

        "ruby")
            $method -e "require 'socket';require 'timeout';begin;Timeout::timeout(2) do;begin;s=TCPSocket.new('$host',$port);s.close;exit(0);end;end;rescue Timeout::Error;exit(1);end" 2>/dev/null
            ;;

        "php")
            $method -r '$c=@fsockopen("'$host'",'$port',$errno,$errstr,2);if(is_resource($c)){fclose($c);exit(0);}else{exit(1);}' 2>/dev/null
            ;;

        "scala")
            $method -e 'object TestPort{def main(args: Array[String]){try{val s=new java.net.Socket();s.connect(new java.net.InetSocketAddress("'$host'",'$port'),2000);s.close();System.exit(0);}catch{case e: Exception=>{System.exit(1);}}}}' 2>/dev/null
            ;;

        "gcc"|"g++")
            local package="/tmp/$host,$port.c"
            local exec_package=$(echo "/tmp/$host$portc" | sed 's/\.//g')
            if [ -s "$exec_package" ]; then
                "$exec_package" 2>/dev/null
            else
                echo '''
                    #include <unistd.h>
                    #include <string.h>
                    #include <netdb.h>
                    int main(){int s;struct sockaddr_in sa;struct hostent *sv;s=socket(AF_INET,SOCK_STREAM,0);if (s<0) return 1;sv=gethostbyname("'$host'");if (sv==NULL) return 1;bzero((char *) &sa,sizeof(sa));sa.sin_family=AF_INET;bcopy((char *)sv->h_addr,(char *)&sa.sin_addr.s_addr,sv->h_length);sa.sin_port=htons('$port');struct timeval timeout={2,0};if(setsockopt(s,SOL_SOCKET,SO_SNDTIMEO,(const void*) &timeout,sizeof(timeout))!=0) return 1;if(connect(s,(struct sockaddr *) &sa,sizeof(sa))<0){close(s);return 1;}else{close(s);return 0;}}
                    ''' > "$package" && gcc "$package" -o "$exec_package" 2>/dev/null && "$exec_package" 2>/dev/null
            fi
            ;;

        "tclsh")
            echo 'if [catch {socket "'$host'" '$port'} s] {exit 1;} else {close $s;exit 0;}' | $TIMEOUT_CMD 2 tclsh 2>/dev/null
            ;;

        "javac")
            local package="M$host,$port.java"
            local class_package=$(echo "M$host$portjava" | sed 's/\.//g')
            cd /tmp >/dev/null
            if [ -s "$class_package" ]; then
                java "$class_package" 2>/dev/null
            else
                echo 'import java.net.Socket;import java.net.InetSocketAddress;class '$class_package' {public static void main(String[] args){{try{Socket s=new Socket();s.connect(new InetSocketAddress("'$host'",'$port'),2000);s.close();System.exit(0);}catch(Exception e){System.exit(1);}}}}' > "$package" && $method "$package" 2>/dev/null && java "$class_package" 2>/dev/null
            fi
            if [ $? -eq 0 ]; then GOOD_CONNECT_RESULT="0"; fi
            cd - >/dev/null
            return
            ;;

        "elixirc")
            local package="/tmp/$host,$port.ex"
            if [ -s "$package" ]; then
                $method "$package" 2>/dev/null
            else
                echo "case :gen_tcp.connect('$host',$port,[],2000)do{:ok,s}->:gen_tcp.close(s);System.halt(0);{:error,_}->System.halt(1);end">"$package" && $method "$package" 2>/dev/null
            fi
            ;;

        "go")
            local package="/tmp/$host,$port.go"
            if [ -s "$package" ]; then
                $method run "$package" 2>/dev/null
            else
                echo 'package main;import("net";"os";"time";);func main(){c,e:=net.DialTimeout("tcp","'$host:$port'",time.Duration(2)*time.Second);if e,ok:=e.(*net.OpError);ok && e.Timeout(){os.Exit(1);};if e!=nil{os.Exit(1);};defer c.Close();os.Exit(0);}' > "$package" && $method run "$package" 2>/dev/null
            fi
            ;;
        
        *)
            return
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

    # Check methods for open-connection
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
    if [ -z "$USED_METHOD" ]; then echo; echo "[x] [$(date +%T)] $UNSUPPORTED_METHOD_MESSAGE"; echo; exit 1; fi
}


Main()
{
    # Optimize args + call function to validate args
    local args="$(echo $@ | tr '[:upper:]' '[:lower:]' | sed 's/,/ /g')" 
    Validate_Args $args

    # The timeout options (timeout / timeout -t)
    TIMEOUT_CMD=$(timeout --version 2>&1 | head -2 | grep -o "\bGNU\b") # Global
    if [ -z "$TIMEOUT_CMD" ]; then TIMEOUT_CMD="timeout -t"; else TIMEOUT_CMD="timeout"; fi;

    # Validate telnet & wget versions (BusyBox versions are not supported)
    for busybox_method in "telnet" "wget"; do if ! [ -z $($busybox_method --help 2>&1 | head -1 | grep -o "\bBusyBox\b") ]; then METHODS=$(echo "$METHODS" | sed 's/'$busybox_method'//g'); fi; done

    # INIT message
    if ! [ -z "$INIT_MESSAGE" ]; then echo "[+] [$(date +%T)] $INIT_MESSAGE [ --connect $CONNECT_TYPE --sleep $SLEEP_TIME $HOSTS ] ..."; fi

    # Loop and check for open connections
    while [ true ]
    do
        local success=""
        sleep $(expr $SLEEP_TIME - 1)
        echo

        for host_n_port in $HOSTS; do
            # Call function to check for open connection
            Check_Methods "$host_n_port"
            sleep 1

            if ! [ -z "$GOOD_CONNECT_RESULT" ]; then
                # SUCCESS message
                if ! [ -z "$CONNECT_MESSAGE" ]; then echo "[v] [$(date +%T)] $host_n_port - $USED_METHOD $CONNECT_MESSAGE"; fi
                success="0"
                if [ "$CONNECT_TYPE" = "any" ]; then break; fi
            else
                # FAIL message
                if ! [ -z "$FAIL_MESSAGE" ]; then echo "[x] [$(date +%T)] $host_n_port - $USED_METHOD $FAIL_MESSAGE"; fi
                success="1"
                if [ "$CONNECT_TYPE" = "all" ]; then break; fi
            fi
        done

        if [ "$success" = "0" ]; then
            # COMPLETE message : exit app successfully
            if ! [ -z "$DONE_MESSAGE" ]; then echo; echo "[v] [$(date +%T)] $DONE_MESSAGE"; echo; fi
            exit 0
        fi
    done
}


# If grep is not exist -> UNSUPPORTED SYSTEM message : terminate app
if ! command -v "grep" >/dev/null; then echo; echo "[x] [$(date +%T)] $UNSUPPORTED_SYSTEM_MESSAGE"; echo; exit 1; fi

# MAIN
if [ -z $1 ]; then
    # Call Main function, passing default values
    Main $HOSTS "--connect" $CONNECT_TYPE "--sleep" $SLEEP_TIME
else
    # Call Main function, passing args
    Main $@
fi