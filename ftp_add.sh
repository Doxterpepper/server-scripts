USER_FILE=/var/ftp_users
FTP_GROUP=ftp
LOGIN_SHELL=/bin/nologin
FTP_DIR=/srv/ftp

function user_exists() {
    cat /etc/passwd | grep $1 && echo "User $1 exists! Aborting."
}

if [ $# -lt 1 ]
then
    echo "Please specify a username"
else
    echo "Adding user $1"
    user_exists $1 && exit 1
    useradd -G $FTP_GROUP -s $LOGIN_SHELL -d $FTP_DIR $1 || exit 1
    passwd $1
    echo "$1:$(openssl passwd -apr1 $password)" >> $USER_FILE
fi
