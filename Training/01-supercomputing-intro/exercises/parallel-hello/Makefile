CC=mpicc
OMPFLAGS=-fopenmp
LIBS=-lm

all: hello hello-omp

hello: parallel-hello.c
	mpicc  -o $@ $< $(LIBS)

hello-omp: parallel-hello.c
	mpicc  -o $@ $< $(LIBS) $(OMPFLAGS)

clean:
	rm -f hello hello-omp