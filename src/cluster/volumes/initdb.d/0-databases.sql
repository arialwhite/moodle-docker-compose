
# MOODLE

CREATE DATABASE IF NOT EXISTS `moodle`;
ALTER DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE USER IF NOT EXISTS moodleuser@'%' IDENTIFIED BY 'MYSQL_PASSWORD_VALUE_A';
GRANT ALL ON moodle.* TO moodleuser@'%';

# WORDPRESS

CREATE DATABASE IF NOT EXISTS `wordpress`;
ALTER DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE USER IF NOT EXISTS wordpressuser@'%' IDENTIFIED BY 'MYSQL_PASSWORD_VALUE_B';
GRANT ALL ON wordpress.* TO wordpressuser@'%';
