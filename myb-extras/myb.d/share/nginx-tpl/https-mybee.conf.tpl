upstream api {
	server 127.0.0.1:65531;
}

upstream ttyd_back {
	server unix:/var/run/ttyd.sock;
}

server {
	listen      *:80;
	listen      [::]:80;
	server_name %%API_FQDN%%;

	error_log /dev/null;
	access_log off;

	include letsencrypt.conf;

	location / {
		return 301 "https://$host$request_uri";
	}
}

server {
	listen *:443 ssl;
	listen [::]:443 ssl;
	server_name %%API_FQDN%%;
	include mime.types;

	error_log /var/log/nginx/https.err;
	access_log /var/log/nginx/https.acc;

	ssl_certificate /usr/local/etc/letsencrypt/live/%%API_FQDN%%/fullchain.pem;
	ssl_certificate_key /usr/local/etc/letsencrypt/live/%%API_FQDN%%/privkey.pem;

	location /status {
		include acl.conf;
		root /usr/local/www/status;
		try_files /status.html =404;
	}

	location /images {
		include acl.conf;
		types { }
		default_type application/json;
		proxy_pass http://api;
	}
	location /clusters {
		include acl.conf;
		types { }
		default_type application/json;
		proxy_pass http://api;
		#deny all;
		#allow <trusted>;
	}

	location /metrics {
		include acl.conf;
		types { }
		try_files $uri =404;
		root /usr/local/www/public;
	}

	location /shell/ {
		proxy_pass            http://ttyd_back/;
		proxy_read_timeout    90s;
		proxy_connect_timeout 90s;
		proxy_send_timeout    90s;
		proxy_http_version    1.1;
		proxy_set_header      Host $http_host;
		proxy_set_header      X-Forwarded-Proto $scheme;
		proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header      Upgrade $http_upgrade;
		proxy_set_header      Connection "upgrade";
	}

    # GARM
    location ~ ^/api/v1/first-run {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
       location ~ ^/api/v1/controller {
               proxy_set_header X-Forwarded-For $remote_addr;
               proxy_set_header X-Forwarded-Host $http_host;
               proxy_set_header        Host    $Host;
               proxy_redirect off;
               proxy_pass http://127.0.0.1:9997;
       }

    location ~ ^/api/v1/auth {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/providers {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/repositories {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/instances {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/pools {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/github/endpoints {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/credentials {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/github/credentials {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location /webhooks {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/callbacks {
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header        Host    $Host;
            proxy_redirect off;
            proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/metadata {
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header        Host    $Host;
            proxy_redirect off;
            proxy_pass http://127.0.0.1:9997;
    }
    location ~ ^/api/v1/callbacks/status {
	proxy_set_header X-Forwarded-For $remote_addr;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header        Host    $Host;
	proxy_redirect off;
	proxy_pass http://127.0.0.1:9997;
    }


	location ~ ^/api/v[1-9]\d*/ {
		include acl.conf;
		types { }
		default_type application/json;
		proxy_pass http://api;
		#deny all;
		#allow <trusted>;
	}

	location / {
		root /usr/local/www/public;
	}
}
