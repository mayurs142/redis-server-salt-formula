{% from "redis-server/map.jinja" import redis with context %}
{% from "redis-server/map.jinja" import sentinel with context %}

## Add ppa repository
redis_ppa_repo:
  pkgrepo.managed:
    - ppa: chris-lea/redis-server
    - require_in:
      - pkg: {{ redis.pkg_name }}

## Install redis-server
install_redis:
  pkg.installed:
    - name: {{ redis.pkg_name }}
    - version: {{ redis.version }}

## Redis configuration
redis_config:
  file.managed:
    - name: {{ redis.cfg_name }}
    - source: salt://redis-server/files/redis-3.0.7.conf
    - mode: 644
    - user: redis
    - group: redis
    - template: jinja
    - require:
      - pkg: {{ redis.pkg_name }}

## Sentinel configuration
sentinel_config:
  file.managed:
    - name: {{ sentinel.cfg_name }}
    - source: salt://redis-server/files/sentinel-3.0.7.conf
    - mode: 644
    - user: redis
    - group: redis
    - template: jinja
    - require:
      - pkg: {{ redis.pkg_name }}

## Redis service configuration
redis_service:
  service.running:
    - name: {{ redis.svc_name }}
    - enable: True
    - watch:
      - file: {{ redis.cfg_name }}
    - require:
      - pkg: {{ redis.pkg_name }}

## Add sentinel service file to /etc/init.d
sentinel_service_file:
  file.managed:
    - name: /etc/init.d/redis-sentinel
    - source: salt://redis-server/files/redis-sentinel
    - mode: 755
    - user: root
    - group: root
    - require:
      - pkg: {{ redis.pkg_name }}

## Enable sentinel service on boot
sentinel_service_onboot:
  cmd.run:
    - name: update-rc.d redis-sentinel defaults
    - require:
      - file: /etc/init.d/redis-sentinel 

## Sentinel service configuration
sentinel_service:
  service.running:
    - name: {{ sentinel.svc_name }}
    - enabled: True
    - watch:
      - file: {{ sentinel.cfg_name }}
    - require:
      - pkg: {{ redis.pkg_name }}
