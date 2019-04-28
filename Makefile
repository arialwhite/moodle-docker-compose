#!make

SRC_DIR := ./src
DIST_DIR := ./dist
BACKUP_DIR := ./backup

HOSTNAME := cluster
SITENAME := fls-explorateur

MOODLE_CONFIG_FILE := $(DIST_DIR)/images/moodle/config/moodle/moodle-config.php
MOODLE_DIRECTORY := $(DIST_DIR)/images/moodle
DOCKER_COMPOSE_FILE := $(DIST_DIR)/docker-compose.yml
DB_FILE := $(DIST_DIR)/volumes/initdb.d/0-databases.sql

# Load passwords
include .secrets
export

.PHONY: dist secrets clean purge docker-build docker-up backup deploy deployfull

dist:
	mkdir -p "$(DIST_DIR)"
	mkdir -p "$(DIST_DIR)/volumes/moodle/moodledata"
	mkdir -p "$(DIST_DIR)/volumes/mysql-conf.d"
	mkdir -p "$(DIST_DIR)/volumes/mysql-data"
	mkdir -p "$(DIST_DIR)/volumes/tmp"
	mkdir -p "$(DIST_DIR)/volumes/letsencrypt"
	cp -r -n "$(SRC_DIR)/common/." "$(DIST_DIR)/"
	cp -r -n "$(SRC_DIR)/$(HOSTNAME)/." "$(DIST_DIR)/"

secrets:
	@sed -i 's/MYSQL_PASSWORD_VALUE_A/'"$(MYSQL_PASSWORD_A)"'/g' "$(DB_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE_B/'"$(MYSQL_PASSWORD_B)"'/g' "$(DB_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE_A/'"$(MYSQL_PASSWORD_A)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE_B/'"$(MYSQL_PASSWORD_B)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE_A/'"$(MYSQL_PASSWORD_A)"'/g' "$(MOODLE_CONFIG_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE/'"$(MYSQL_PASSWORD)"'/g' "$(MOODLE_CONFIG_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE/'"$(MYSQL_PASSWORD)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@sed -i 's/MYSQL_ROOT_PASSWORD_VALUE/'"$(MYSQL_ROOT_PASSWORD)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@sed -i 's/SITENAME/'"$(SITENAME)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@find "$(MOODLE_DIRECTORY)" -type f -exec sed -i 's/SITENAME/'"$(SITENAME)"'/g' {} \;

install: dist secrets
	echo "installing.."

docker-up:
	cd "$(DIST_DIR)"; docker-compose up
	
docker-build:
	cd "$(DIST_DIR)"; docker-compose build

clean:
	rm -rf "$(DIST_DIR)/images" "$(DIST_DIR)/docker-compose.yml"

purge: clean
	rm -rf "$(DIST_DIR)/volumes"

backup:
	mkdir -p "$(BACKUP_DIR)"
	cp -r "$(DIST_DIR)/volumes/." "$(BACKUP_DIR)/"

deploy:
	sshpass -p "$(SSH_PWD)" rsync -rzP --exclude="volumes" "$(DIST_DIR)/" "root@$(remote_host):$(remote_dir)"

deployfull:
	sshpass -p "$(SSH_PWD)" rsync -rzP "$(DIST_DIR)/" "root@$(remote_host):$(remote_dir)"
