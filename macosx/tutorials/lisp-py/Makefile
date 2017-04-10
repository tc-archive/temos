SRC=./src

run:
	python ${SRC}/lisp.py

lint:
	find ${SRC} -iname "*.py" | xargs pylint  

isort:
	bash -c "isort --skip-glob=.tox --recursive . "

test:
	python -m unittest discover -s ${SRC} -p 'test_*.py' 

clean:
	find ${SRC} -iname "*.pyc" | xargs rm  

# decompile:
#	 find ${SRC} -iname "*.pyc" | xargs uncompyle6 

help:
	@echo "lint  - Lint source files."
	@echo "isort - Order source file imports."
	@echo "test  - Run unit tests."
	@echo "run   - Run lisp"
	@echo "clean - Clean-up compiled files."
	@echo "help  - Display this help message."

.PHONY: lint isort run clean help
