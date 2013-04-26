JS=lib/application.js \
   lib/controller.js \
   lib/validate.js \
   index.js

all: $(JS)

clean:
	-rm -f $(JS)

%.js: %.coffee
	coffee -b -c $<

test: $(JS)
	twerp test/*.coffee

publish: $(JS)
	npm publish

watch:
	while /bin/true; do inotifywait -qre close_write --format "%w %f" .; make test clean; done

.PHONY: clean test

