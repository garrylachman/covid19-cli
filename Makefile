build:
	make clean
	mkdir dist
	bash scripts/inline.sh src/covid19-cli.sh > dist/covid19-cli.sh
	chmod +x dist/covid19-cli.sh
clean:
	rm -Rf dist
