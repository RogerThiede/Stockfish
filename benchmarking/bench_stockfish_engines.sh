#!/bin/zsh
##################################################################################################
# usage: bench_stockfish_engines.sh VERSION
#
# Expects each engine to be named stockfish-$version-$arch-$compiler in the current working directory.
# Executes each engine three times with a given hashsize, threads, and depth.
# Outputs in csv format with columns:
#         "version, architecture, compiler, hashsize, threads, depth, nps1, nps2, nps3"
##################################################################################################

VERSION=${argv[1]} 

ARCHS=(x86-64-vnni512 x86-64-vnni256 x86-64-avx512 x86-64-bmi2 x86-64-avx2 x86-64-sse41-popcnt x86-64-modern x86-64-ssse3 x86-64-sse3-popcnt x86-64)
COMPILERS=(gcc clang)
                                        # ( 2^16  2^16   2^17   2^18)
HASHSIZE_TO_BENCHMARK=(262144)		# (32768 65536 131072 262144)
THREADS_TO_BENCHMARK=(128)	    	# (32 64 128 192 256 320 384 448 512)
DEPTH_TO_BENCHMARK=(5)	    		# (10 16 32 48)


##### csv header line
echo -e "version,architecture,compiler,hashsize,threads,depth,nps1,nps2,nps3"

for arch in $ARCHS; do
	for compiler in $COMPILERS; do
		engine=./stockfish-$VERSION-$arch-$compiler
		for hashsize in $HASHSIZE_TO_BENCHMARK; do
			for threads in $THREADS_TO_BENCHMARK; do
				for depth in $DEPTH_TO_BENCHMARK; do	
					# echo -e "Benchmarking for $engine bench $hashsize $threads $depth default depth NNUE"
					# Nodes/second data is printed to standard error.  Execute each engine and maintain only standard error output.
					sleep 3
					nps1=`$engine bench $hashsize $threads $depth default depth NNUE 2>&1 > /dev/null | tail -1 | grep "Nodes\/second" | sed "s/.*: \([0-9]*\)/\1/"`
					sleep 3
					nps2=`$engine bench $hashsize $threads $depth default depth NNUE 2>&1 > /dev/null | tail -1 | grep "Nodes\/second" | sed "s/.*: \([0-9]*\)/\1/"`
					sleep 3
					nps3=`$engine bench $hashsize $threads $depth default depth NNUE 2>&1 > /dev/null | tail -1 | grep "Nodes\/second" | sed "s/.*: \([0-9]*\)/\1/"`
					sleep 3
					echo -e "$VERSION, $arch, $compiler, $hashsize, $threads, $depth, $nps1, $nps2, $nps3"
				done
			done
		done
	done
done

