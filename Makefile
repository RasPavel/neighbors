# simple makefile to simplify repetitive build env management tasks under posix

# caution: testing won't work on windows, see README

PYTHON ?= python
CYTHON ?= cython
NOSETESTS ?= nosetests
CTAGS ?= ctags

# skip doctests on 32bit python
BITS := $(shell python -c 'import struct; print(8 * struct.calcsize("P"))')

ifeq ($(BITS),32)
  NOSETESTS:=$(NOSETESTS) -c setup32.cfg
endif


all: clean inplace

clean-ctags:
	rm -f tags

clean: clean-ctags
	$(PYTHON) setup.py clean
	rm -rf dist

in: inplace # just a shortcut
inplace:
	# to avoid errors in 0.15 upgrade
	$(PYTHON) setup.py build_ext -i

trailing-spaces:
	find gawml -name "*.py" -exec perl -pi -e 's/[ \t]*$$//' {} \;

cython:
	python build_tools/cythonize.py gawml

ctags:
	# make tags for symbol based navigation in emacs and vim
	# Install with: sudo apt-get install exuberant-ctags
	$(CTAGS) --python-kinds=-i -R gawml

doc: inplace
	$(MAKE) -C doc html

doc-noplot: inplace
	$(MAKE) -C doc html-noplot

code-analysis:
	flake8 gaw | grep -v __init__ | grep -v external
	pylint -E -i y gaw/ -d E1103,E0611,E1101
