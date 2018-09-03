#check for root

username=wordpress
password=`openssl rand -base64 16`



#download wordpress and unpack it
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
mv wordpress/wp-config-sample.php wordpress/wp-config.php


#replace wordpress.sql variables

sed -i "s/varDBName/${username}_DB/g" "wordpress.sql"
sed -i "s/varWPUser/${username}/g" "wordpress.sql"
sed -i "s/varPassword/${password}/g" "wordpress.sql"


mysql -u root < /home/ec2-user/wordpress.sql



sed -i "s/database_name_here/${username}_DB/g" "wordpress/wp-config.php"
sed -i "s/username_here/${username}/g" "wordpress/wp-config.php"
sed -i "s/password_here/${password}/g" "wordpress/wp-config.php"

mv wordpress/* /var/www/html/
