test: 
	
# Building docker image
VERSION = "v0.0.5" 
IM=matentzn/vfb-prod

docker-build:
	@docker build --no-cache -t $(IM):$(VERSION) . \
	&& docker tag $(IM):$(VERSION) $(IM):latest
	
docker-build-use-cache:
	@docker build -t $(IM):$(VERSION) . \
	&& docker tag $(IM):$(VERSION) $(IM):latest

docker-run:
	docker run -p:7474:7474 -p 7687:7687 --env-file ./env.list $(IM)

docker-clean:
	docker kill $(IM) || echo not running ;
	docker rm $(IM) || echo not made 

docker-publish-no-build:
	@docker push $(IM):$(VERSION) \
	&& docker push $(IM):latest
	
docker-publish: docker-build-use-cache
	@docker push $(IM):$(VERSION) \
	&& docker push $(IM):latest