#!/bin/bash

SUPERGROUP=hadoop
YARN_USER=yarn
HDFS_USER=hdfs
MAPRED_USER=mapred
DIR="directory"
REG_FILE="regular file"
LINK="symbolic link"
JBOD_PATH="/data"
MOUNTED_DISKS=`ls ${JBOD_PATH}| wc -l`
NN_DISKS=( 1 )
DN_DISKS=( 2 3 )
YARN_DISKS=${DN_DISKS}
ERR_COUNT=0

function usage(){
    echo "usage $0 COMMAND [OPTS]
        COMMAND:
            local: Check local filesystem. It checks path, owner, groups and permissions to run 
                propertly different hadoop services, specified in OPTS 
                OPTS:
                    namenode
                    datanode
                    resourcemanager
                    nodemanager
            hdfs: Check hdfs remote filesystem. It checks required path, owner,
                groups and permissions to run Yarn, Hdfs, HistoryServer and MapRed jobs.
                It's possible to chck both secured and unsecured hdfs clusters.
                OPTS:
                    -s,--secure: enables checks against a secured hdfs cluster. Consider that when checking a
                        secured cluster, it is required -k and -p flags
                    -k,--keytab PATH: path to keytab containing principal to use for kerberos authentication
                        in a secured cluster.
                    -p|--princ|--principal PRINCIPAL: kerberos principal to use for authentication.
    "
}

function local_checker(){
    local FILE_STATUS
    RETVAL=0
    FILE=$1
    USER=$2
    GROUP=$3
    PERMISSION=$4
    FILE_TYPE=$5
    ERR_MSG=""
    [ ! -e ${FILE} ] && ERR_MSG="\t${FILE_TYPE} does not exist" && RETVAL=1
    if [ $RETVAL == 0 ]; then
        TMP=`stat -c "%U,%G,%a,%F" ${FILE}`
        IFS=","
        FILE_STATUS=( ${TMP} )
        unset IFS
        [ "${FILE_STATUS[0]}" != "${USER}" ] && ERR_MSG+="\towner: ${FILE_STATUS[0]}, expected ${USER}\n" && RETVAL=1
        [ "${FILE_STATUS[1]}" != "${GROUP}" ] && ERR_MSG+="\tgroup: ${FILE_STATUS[1]}, expected ${GROUP}\n" && RETVAL=1
        [ "${FILE_STATUS[2]}" != "${PERMISSION}" ] && ERR_MSG+="\tpermissions: ${FILE_STATUS[2]}, expected ${PERMISSION}\n" && RETVA=1
        [ "${FILE_STATUS[3]}" != "${FILE_TYPE}" ] && ERR_MSG+="\ttype: ${FILE_STATUS[3]}, expected ${FILE_TYPE}" && RETVAL=1
    fi
    ((ERR_COUNT=ERR_COUNT+${RETVAL}))
    [ $RETVAL == 0 ] && echo -e "${FILE} \e[1;32m[OK]\e[0m"
    [ $RETVAL == 1 ] && echo -e "${FILE} \e[1;31m[FAIL]\e[0m\n${ERR_MSG}"
    return $RETVAL
}

function hdfs_checker(){
    local FILE_STATUS
    RETVAL=0
    FILE=$1
    DIRNAME=`dirname ${FILE}`
    USER=$2
    GROUP=$3
    PERMISSION=$4
    FILE_TYPE=$5
    ERR_MSG=""
    case "${FILE_TYPE}" in
        "${REG_FILE}")
            PERMISSION="-"${PERMISSION}
            ;;
        "${DIR}")        
            PERMISSION="d"${PERMISSION}
            ;;
        *)
            echo "Unavailable file type ${FILE_TYPE} in HDFS"
            ((ERR_COUNT++))
            return 1
            ;;
    esac
    hdfs dfs -stat ${FILE} > /dev/null
    [ $? != 0 ] && ERR_MSG="\t${FILE_TYPE} not found" && RETVAL=1 
    if [ $RETVAL == 0 ]; then
        FILE_STATUS=( `hdfs dfs -ls ${DIRNAME} | grep ${FILE}` )
        [ "${FILE_STATUS[0]}" != "${PERMISSION}" ] && ERR_MSG+="\tpermissions: ${FILE_STATUS[0]}, expected ${PERMISSION}" && RETVAL=1
        [ "${FILE_STATUS[2]}" != "${USER}" ] && ERR_MSG+="\towner: ${FILE_STATUS[2]}, expected ${USER}" && RETVAL=1
        [ "${FILE_STATUS[3]}" != "${GROUP}" ] && ERR_MSG+="\tgroup: ${FILE_STATUS[3]}, expected ${GROUP}" && RETVAL=1
    fi
    ((ERR_COUNT=ERR_COUNT+${RETVAL}))
    [ $RETVAL == 0 ] && echo -e "${FILE} \e[1;32m[OK]\e[0m"
    [ $RETVAL == 1 ] && echo -e "${FILE} \e[1;31m[FAIL]\e[0m\n${ERR_MSG}"
    return $RETVAL
}

function check_local_datanode(){
    FILE="/var/log/hadoop-hdfs"
    local_checker ${FILE} ${HDFS_USER} ${HDFS_USER} 775 "${DIR}"

    for i in ${DN_DISKS};do
        FILE="${JBOD_PATH}/${i}/dfs/dn"
        local_checker ${FILE} ${HDFS_USER} ${HDFS_USER} 700 "${DIR}"
    done
}

function check_local_namenode(){
    FILE="/var/log/hadoop-hdfs"
    local_checker ${FILE} ${HDFS_USER} ${HDFS_USER} 775 "${DIR}"

    for i in ${NN_DISKS};do
        FILE="${JBOD_PATH}/${i}/dfs/nn"
        local_checker ${FILE} ${HDFS_USER} ${HDFS_USER} 700 "${DIR}"
    done
}

function check_local_nodemanager(){
    FILE="/var/log/hadoop-yarn"
    local_checker ${FILE} ${YARN_USER} ${YARN_USER} 775 "${DIR}"

    for i in ${YARN_DISKS};do
        FILE="${JBOD_PATH}/${i}/yarn"
        local_checker ${FILE}/local ${YARN_USER} ${YARN_USER} 775 "${DIR}"
        local_checker ${FILE}/log ${YARN_USER} ${YARN_USER} 775 "${DIR}"
    done

    FILE="/usr/lib/hadoop-yarn/bin/container-executor"
    local_checker ${FILE} root ${YARN_USER} 6050 "${REG_FILE}"

    FILE="/usr/lib/hadoop-yarn/etc/hadoop"
    local_checker ${FILE} root root 777 "${LINK}"

    FILE="/etc/hadoop/conf/container-executor.cfg"
    local_checker ${FILE} root ${YARN_USER} 400 "${REG_FILE}"

    FILE="/usr/lib/jsvcdaemon/jsvc"
    local_checker ${FILE} root root 755 "${REG_FILE}"
    [ $? == 1 ] && echo "Secure Datanades can not be enabled"
}

function check_local_resourcemanager(){
    FILE="/var/log/hadoop-yarn"
    local_checker ${FILE} ${YARN_USER} ${YARN_USER} 775 "${DIR}"
}

function check_local_commons(){
    FILE="/etc/hadoop/conf/"
    local_checker ${FILE} root ${SUPERGROUP} 755 "${DIR}"

    FILE="/etc/hadoop/conf/security"
    local_checker ${FILE} root ${SUPERGROUP} 750 "${DIR}"
    [ $? == 1 ] && echo "Security can not enabled"
}

function check_hdfs_auth(){
    while test -n "$1"; do
        case $1 in 
            -k|--keytab)
                KEYTAB="${2}"
                shift
                ;;
            -p|--principal|--princ)
                PRINCIPAL="${2}"
                shift
                ;;
            -s|--secure)
                SECURE=true
                ;;
            *)
                usage
                exit 1
            ;;
        esac
        shift
    done
    if [ -n "$SECURE" ]; then
        if  [ -z "${KEYTAB}" ] || [ -z "${PRINCIPAL}" ]; then
            usage && exit 1
        else
            kinit -kt ${KEYTAB} ${PRINCIPAL}
        fi
    fi
}

function check_hdfs_files(){
    FILE="/user"    
    hdfs_checker ${FILE} ${HDFS_USER} ${SUPERGROUP} "rwxr-xr-x" "${DIR}"

    FILE="/user/history"
    hdfs_checker ${FILE} ${MAPRED_USER} ${SUPERGROUP} "rwxrwxrwt" "${DIR}"

    FILE="/user/history/done"
    hdfs_checker ${FILE} ${MAPRED_USER} ${SUPERGROUP} "rwxr-x---" "${DIR}"

    FILE="/user/history/done_intermediate"
    hdfs_checker ${FILE} ${MAPRED_USER} ${SUPERGROUP} "rwxrwxrwt" "${DIR}"

    FILE="/var"
    hdfs_checker ${FILE} ${HDFS_USER} ${SUPERGROUP} "rwxr-xr-x" "${DIR}"

    FILE="/var/log"
    hdfs_checker ${FILE} ${HDFS_USER} ${SUPERGROUP} "rwxr-xr-x" "${DIR}"

    FILE="/var/log/hadoop-yarn"
    hdfs_checker ${FILE} ${MAPRED_USER} ${MAPRED_USER} "rwxr-xr-x" "${DIR}"

    FILE="/var/log/hadoop-yarn/apps"
    hdfs_checker ${FILE} ${MAPRED_USER} ${MAPRED_USER} "rwxrwxrwt" "${DIR}"

    FILE="/tmp"
    hdfs_checker ${FILE} ${HDFS_USER} ${SUPERGROUP} "rwxrwxrwt" "${DIR}"
}

case "$1" in
    "local")
        shift
        check_local_commons    
        case "$1" in
            "datanode")
                check_local_datanode
                ;;
            "namenode")
                check_local_namenode
                ;;
            "nodemanager")
                check_local_nodemanager
                ;;
            "resourcemanager")
                check_local_resourcemanager
                ;;
        esac
        ;;
    "hdfs")
        shift
        check_hdfs_auth $@
        check_hdfs_files
        ;;
    *)
        usage
        exit 1
        ;;
esac
exit $ERR_COUNT
