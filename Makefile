IMG_NAMESPACE = asteven
IMG_NAME = alpine-openrc
IMG_FQNAME = $(IMG_NAMESPACE)/$(IMG_NAME)
IMG_VERSION = 3.10-r1

.PHONY: container push clean
all: container


container:
	sudo docker build -t $(IMG_FQNAME):$(IMG_VERSION) .
	sudo docker tag $(IMG_FQNAME):$(IMG_VERSION) $(IMG_FQNAME):latest

push:
	sudo docker push $(IMG_FQNAME):$(IMG_VERSION)
	# Also update :latest
	sudo docker push $(IMG_FQNAME):latest

clean:
	sudo docker rmi $(IMG_FQNAME):$(IMG_VERSION)

