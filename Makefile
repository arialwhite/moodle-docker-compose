#!make

SRC_DIR := ./src
DIST_DIR := ./dist
BACKUP_DIR := ./backup

HOSTNAME := localhost
SITENAME := dev

MOODLE_CONFIG_FILE := $(DIST_DIR)/images/moodle/config/moodle-config.php
MOODLE_DIRECTORY := $(DIST_DIR)/images/moodle
DOCKER_COMPOSE_FILE := $(DIST_DIR)/docker-compose.yml

# Load passwords
include .secrets
export

.PHONY: dist secrets clean docker-build docker-up backup

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
	@sed -i 's/MYSQL_PASSWORD_VALUE/'"$(MYSQL_PASSWORD)"'/g' "$(MOODLE_CONFIG_FILE)"
	@sed -i 's/MYSQL_PASSWORD_VALUE/'"$(MYSQL_PASSWORD)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@sed -i 's/MYSQL_ROOT_PASSWORD_VALUE/'"$(MYSQL_ROOT_PASSWORD)"'/g' "$(DOCKER_COMPOSE_FILE)"
	@find "$(MOODLE_DIRECTORY)" -type f -exec sed -i 's/SITENAME/'"$(SITENAME)"'/g' {} \;

install: dist secrets
	echo "installing.."

docker-up:
	cd "$(DIST_DIR)"; docker-compose up
	
docker-build:
	cd "$(DIST_DIR)"; docker-compose build

clean:
	rm -rf "$(DIST_DIR)/images" "$(DIST_DIR)/docker-compose.yml"

backup:
	mkdir -p "$(BACKUP_DIR)"
	cp -r "$(DIST_DIR)/volumes/." "$(BACKUP_DIR)/"
