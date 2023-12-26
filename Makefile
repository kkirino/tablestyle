# Makefile
#
# tablestyle
#


VERSION=v0.1.0


dist/tablestyle.exe: tablestyle.py requirements.txt
	docker run --rm -v "$(shell pwd)":/src cdrx/pyinstaller-windows:python3 'pyinstaller --onedir --onefile --clean tablestyle.py'


.PHONY: test clean
test: dist/tablestyle.exe test.sh
	./test.sh


release: dist/tablestyle.exe
	gh release create $(VERSION) 'dist/tablestyle.exe#tablestyle.exe'


clean:
	sudo rm -rf __pycache__/ build/ dist/
	sudo rm -f *.spec


