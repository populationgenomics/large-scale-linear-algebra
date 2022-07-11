# LT 3/06

# bigmemory package capabilities exploration
# for CellRegMap and gnomAD v4 relatedness
library(bigmemory)
library(bigalgebra)
library(irlba)
library(parallel)

# size of square matrix
# N = 1e5
N = 1e6

# create disk matrix on scratch
# TODO: if the matrix file exists, use it, otherwise create matrix and fill it
# with random numbers
M = big.matrix(N,N, type='double', backingfile='test', backingpath = '/mnt/disk/ssd')

# fill matrix with unit Gaussian rnandom numbers. 
# keep 2 CPUS for housekeeping
mclapply(seq_len(N), function(i) {M[i,] = rnorm(N); return()}, mc.cores=detectCores()-2)

# that would be how to load an existing disk matrix
#M = attach.big.matrix('test.desc')

# set hooks to acticate transparency
setMethod("%*%", signature(x = "big.matrix", y = "numeric"),
          function(x, y) x %*% as.matrix(y))
setMethod("%*%", signature(x = "numeric", y = "big.matrix"),
          function(x, y) t(x) %*% y)
mult <- function(A, B) (A %*% B)[]

# run the SVD
start =proc.time(); irlbaObject <- irlba(M, nv = 10, mult = mult); print(proc.time()-start)

