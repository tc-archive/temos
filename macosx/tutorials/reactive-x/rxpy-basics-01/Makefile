# simple Makefile for RxPY library examples

SRC := ./src
VENV_DIR := venv
PYTHON_CC := /usr/local/bin/python

.PHONY: default
default: run clean

all:
	init, run, clean

# create virtual environment
init:
	@if [[ ! -e $(VENV_DIR) ]]; then \
		virtualenv -p $(PYTHON_CC) $(VENV_DIR); \
		source ./venv/bin/activate; \
		pip install -r requirements.txt; \
	fi

# run example
run: init
	@source $(VENV_DIR)/bin/activate; python $(SRC)/main.py

# clean resources
clean:
	@rm -Rf venv
	@rm -f $(SRC)/*.pyc
