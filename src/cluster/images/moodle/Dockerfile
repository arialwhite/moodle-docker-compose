FROM debian:9.1
MAINTAINER Julian Guillotel julian.guillotel@live.fr

EXPOSE 80

ENV DEBIAN_FRONTEND noninteractive
ENV MOODLE_RELEASE MOODLE_36_STABLE

# Setup apt-get
RUN apt-get update \
 && apt-get install wget gnupg apt-transport-https lsb-release ca-certificates -y

# Add PHP repos
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Install all dependencies
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install curl unzip zip bzip2 supervisor apache2 apache2-utils mysql-client gettext-base -y \
 && apt-get install libmagick++-dev --no-install-recommends -y \
 && apt-get install php7.2-fpm php7.2-xml php7.2-mysql php7.2-curl php7.2-zip php7.2-gd php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-intl php7.2-xsl -y \
 && apt-get install git -y \
 && apt-get install cron -y

 # Install Composer
RUN mkdir -p /usr/lib/composer \
 && cd /usr/lib/composer \
 && wget https://raw.githubusercontent.com/composer/getcomposer.org/d3a6ed2ed96ff423fb1991f22e4bcabd3db662f8/web/installer -O - -q | php -- --quiet

  # Install Phpmyadmin
RUN mkdir -p /var/www/SITENAME /var/upload/phpmyadmin \
 && git clone --single-branch --depth=1 -b STABLE https://github.com/phpmyadmin/phpmyadmin.git /var/www/SITENAME/phpmyadmin \
 && cd /var/www/SITENAME/phpmyadmin \
 && php /usr/lib/composer/composer.phar install --no-dev

 # Copy additionals www files
COPY www/info.php /var/www/SITENAME/info.php

  # Copy scripts files
COPY scripts/download-mdl-plugin /usr/local/bin/
COPY scripts/download-mdl-theme /usr/local/bin/
COPY scripts/download-mdl-atto /usr/local/bin/

# Install Moodle
RUN mkdir -p /var/www/SITENAME /var/moodle/moodledata \
 && git clone --single-branch --depth=1 -b $MOODLE_RELEASE git://git.moodle.org/moodle.git /var/www/SITENAME/moodle

# Install Moodle plugins
RUN chmod a+x /usr/local/bin/download-mdl-* \
 && sync \
 && download-mdl-plugin 'https://moodle.org/plugins/download.php/19256/mod_taskchain_moodle36_2019033079.zip' \
 && download-mdl-plugin 'https://moodle.org/plugins/download.php/19257/mod_hotpot_moodle36_2019033036.zip' \
 && download-mdl-plugin 'https://moodle.org/plugins/download.php/16518/mod_quizgame_moodle35_2018042900.zip' \
 && download-mdl-atto 'https://moodle.org/plugins/download.php/17025/atto_wordimport_moodle36_2018060401.zip' \
 && download-mdl-atto 'https://moodle.org/plugins/download.php/17255/atto_morebackcolors_moodle35_2018050202.zip' \
 && download-mdl-atto 'https://moodle.org/plugins/download.php/17907/atto_styles_moodle35_2018092600.zip' \
 && download-mdl-atto 'https://moodle.org/plugins/download.php/16628/atto_sketch_moodle35_2018051000.zip' \
 && download-mdl-theme 'https://moodle.org/plugins/download.php/18821/theme_academi_moodle36_2019012601.zip' \
 && download-mdl-theme 'https://moodle.org/plugins/download.php/17286/theme_degrade_moodle35_2018070108.zip' \
 && download-mdl-theme 'https://moodle.org/plugins/download.php/19068/theme_classic_moodle36_2018120700.zip' \
 && download-mdl-theme 'https://moodle.org/plugins/download.php/19377/theme_essential_moodle36_2018121704.zip' \
 && download-mdl-theme 'https://moodle.org/plugins/download.php/19083/theme_moove_moodle36_2019022800.zip' \
 && download-mdl-plugin 'https://moodle.org/plugins/download.php/19174/mod_hvp_moodle36_2019031301.zip' \
 && download-mdl-plugin 'https://moodle.org/plugins/download.php/19106/block_mymindmap_overview_moodle36_2019022100.zip'

COPY theme/adaptable /var/www/SITENAME/moodle/theme/adaptable

# Moodle files permissions
#
# warning: prevent live install of plugins
#
RUN groupadd php-fpm \
 && useradd -s /bin/false -d /dev/null -g php-fpm -l -M -u 20880 php-fpm \
 && chown -R php-fpm:www-data /var/www/SITENAME /var/moodle/moodledata /var/upload \
 && chmod -R 0755 /var/www/SITENAME \
 && chmod -R 0750 /var/moodle/moodledata /var/upload \
 && find /var/www/SITENAME -type f -exec chmod 0644 {} \; \
 && find /var/www/SITENAME -name '*.php' -type f -exec chown php-fpm:php-fpm {} \; -exec chmod 0400 {} \; \
 && sync

# Create lock/pid files and remove php-fpm default pool
RUN mkdir -p /run/php /var/run/apache2 \
 && chmod 0755 /run/php /var/run/apache2 \
 && chown www-data:www-data /var/run/apache2 \
 && chown www-data:php-fpm /run/php \
 && sync \
 && rm /etc/php/7.2/fpm/pool.d/www.conf \
 && mkdir -p /etc/apache2/auth

# Copy config
COPY config/php-fpm/www0.conf /etc/php/7.2/fpm/pool.d/
COPY config/moodle/moodle-config.php /var/www/SITENAME/moodle/config.php
COPY config/phpmyadmin/config.inc.php /var/www/SITENAME/phpmyadmin/
COPY config/apache2/SITENAME.conf /etc/apache2/sites-available/
COPY config/cron.d/moodle /etc/cron.d/moodle

# Config files permissions
RUN chown php-fpm:php-fpm /var/www/SITENAME/moodle/config.php \
 && chmod 0400 /var/www/SITENAME/moodle/config.php \
 && chown php-fpm:php-fpm /var/www/SITENAME/phpmyadmin/config.inc.php \
 && chmod 0400 /var/www/SITENAME/phpmyadmin/config.inc.php \
 && chmod +x /etc/cron.d/*

# Setup apache2
RUN a2ensite SITENAME.conf \
 && a2dissite 000-default \
 && a2enmod proxy \
 && a2enmod proxy_fcgi \
 && a2dismod mpm_prefork \
 && a2dismod mpm_worker \
 && a2enmod mpm_event \
 && a2enmod autoindex \
 && a2enmod rewrite \
 && chown -R php-fpm:www-data /var/moodle/moodledata

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD /usr/bin/supervisord -n
