CC=gfortran
CFLAGS=-Wall -O0 -fcheck=all -fimplicit-none -fdefault-real-8
LDFLAGS=-llapack
PYTHON=python

.PHONY: clean default run

default: run

clean:
	rm -rf *.mod *.o \
		phys395_hw3_optimization \
		results*.csv \
		plot*.svg

run: phys395_hw3_optimization data.dat
	./$<
	$(PYTHON) plot.py

data.dat:
	curl -L https://www.dropbox.com/s/s3cccki89u7whqx/phys395-data.dat -o data.dat

phys395_hw3_optimization: q1_roots.o q3_minima.o q5_fit.o phys395_hw3_optimization.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

phys395_hw3_optimization.o: phys395_hw3_optimization.f90
	$(CC) $(CFLAGS) $(LDFLAGS) -c $< -o $@

q1_roots.o: q1_roots.f90
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<

q3_minima.o: q3_minima.f90
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<

q5_fit.o: q5_fit.f90 solver.o
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<
	ld -r solver.o $@ -o $@.1
	mv $@.1 $@

solver.o: solver.f90
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<
