# alpine-nginx

Differs from other alpine nginx images because:
* nginx is build from source so the latest stable version can be used
* libgeoip is build from source and `GeoIP.dat` is included to allow use of 
[nginx's geoip](http://nginx.org/en/docs/http/ngx_http_geoip_module.html) module.
* a sane nginx configuration is used by default.
