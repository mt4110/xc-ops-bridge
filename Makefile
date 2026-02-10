.PHONY: bootstrap doctor clean build test open

bootstrap:
	bash ./ops/bootstrap.sh

doctor:
	bash ./ops/xc doctor

clean:
	bash ./ops/xc clean $(ARGS)

build:
	bash ./ops/xc build $(ARGS)

test:
	bash ./ops/xc test $(ARGS)

open:
	bash ./ops/xc open
