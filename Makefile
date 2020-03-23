build:
	make clean
	mkdir dist
	bash scripts/inline.sh covid19-cli.sh > dist/covid19-cli.sh
clean:
	rm -Rf dist
