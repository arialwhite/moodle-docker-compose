# moodle-docker-compose

moodle-docker-compose is a the localhost/development version of my moodle website

*Features:*
- Tested only on a Linux/Debian host
- php-fpm 7.2
- Moodle 3.5
- mysql:5.7
- phpmyadmin

## Why using moodle on docker?
  - Not having to repeat each operations each migration/upgrade
  - Reuse existing moodle website and customize it a lot
  - Not having to install libraries on host machine
  - Easier moodle upgrade (rebuild image)

## Security consideration

Passwords are stored in Docker image in moodle configuration file

This is not considered a good practice, but is the easy way

## Usage: Import an existing moodle website

### 1- Configuration
 
Creates a ".secrets" file at the root containing MySQL passwords:
```
MYSQL_PASSWORD=XXYYZZ
MYSQL_ROOT_PASSWORD=XXYYZZ
```

### 2- Build 

In terminal:

```
make clean
make install
``` 

This will build a docker-compose directory in `dist/` from localhost template in `src/`

### 3- Run

In terminal:

```
make docker-up
``` 

It does a `docker-compose up` in `dist/`

Now you can open http://localhost/info.php to check the php status

### 4- Restore database

You can use phpmyadmin to import a dump
http://localhost/phpmyadmin/

Creates user `moodleuser` 
with access granted to database `moodle`
with password MYSQL_PASSWORD that is in `.secrets`

### 5- Restore moodledata 

Stop docker-compose

Copy existing content of moodledata in the new
`./dist/volumes/moodle/moodledata`

### 3- Moodle upgrade

In terminal

```
make docker-up
``` 

Now go to http://localhost/moodle/
