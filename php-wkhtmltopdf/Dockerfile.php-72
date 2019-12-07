FROM factorial/drupal-docker:php-72
MAINTAINER stephan@factorial.io

RUN apt-get update && apt-get install -y wget xfonts-base xfonts-75dpi pdftk xz-utils
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb

