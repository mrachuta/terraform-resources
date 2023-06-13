server {
        # HTTP configuration
        listen ${http_port} default_server;
        listen [::]:${http_port} default_server;
        %{ if https_port != "null" }
        # SSL configuration
        listen ${https_port} ssl default_server;
        listen [::]:${https_port} ssl default_server;
        ssl_certificate /etc/ssl/${site_name}/${site_name}.crt;
        ssl_certificate_key /etc/ssl/${site_name}/${site_name}.key;
        %{ endif }
        root /var/www/html/${site_name};

        index index.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
}
