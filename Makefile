build-data:
	docker build -t data:latest -f docker/data/Dockerfile ./docker/data
	docker tag data:latest xxxxxxxxxxxxxxxxxxx.amazonaws.com/data:latest
	docker push xxxxxxxxxxxxxxxxxxx.amazonaws.com/data:latest

build-fpm:
	docker build -t fpm:latest -f docker/fpm/Dockerfile ./docker/fpm
	docker tag fpm:latest xxxxxxxxxxxxxxxxxxx.amazonaws.com/fpm:latest
	docker push xxxxxxxxxxxxxxxxxxx.amazonaws.com/fpm:latest

build-nginx:
	docker build -t nginx-test:latest -f docker/nginx/Dockerfile ./docker/nginx
	docker tag nginx-test:latest xxxxxxxxxxxxxxxxxxx.amazonaws.com/nginx:latest
	docker push xxxxxxxxxxxxxxxxxxx.amazonaws.com/nginx:latest
