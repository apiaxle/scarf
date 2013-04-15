JS=lib/application.js lib/controller.js lib/validate.js

all: $(JS)

clean:
	-rm -f $(JS)

%.js: %.coffee
	coffee -b -c $<

test: $(JS)
	twerp test/*.coffee

watch:
	while /bin/true; do inotifywait -qre close_write --format "%w %f" .; make test; done

.PHONY: clean test

