server {
    listen 80;
    server_name site.dockoneal.com;

    #location / {
        #root /srv/http;
	#index index.html;
    #}
}
