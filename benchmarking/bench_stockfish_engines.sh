#!/bin/zsh
##################################################################################################
# usage: bench_stockfish_engines.sh
#
# Expects each engine to be named stockfish-$version-$arch-$compiler in the current working directory.
# Executes each engine three times with a given hashsize, threads, and depth.
# Outputs in csv format with columns:
#         "version, architecture, compiler, hashsize, threads, depth, nps1, nps2, nps3"
##################################################################################################

VERSIONS=(640fe5b2)
ARCHS=(x86-64-vnni512 x86-64-vnni256 x86-64-avx512 x86-64-bmi2 x86-64-avx2 x86-64-sse41-popcnt x86-64-modern x86-64-ssse3 x86-64-sse3-popcnt x86-64)
COMPILERS=(gcc clang)
                                        # ( 2^15  2^16   2^17   2^18  2^19)
HASHSIZE_TO_BENCHMARK=(32768)		# (32768 65536 131072 262144 524288)
THREADS_TO_BENCHMARK=(32 64 128 192 256 320 384 448 512)	    	# (32 64 128 192 256 320 384 448 512)
FINAL_DEPTH_TO_BENCHMARK=30   		# 10, 16, 30, 40, 50, 60

fen="rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 0 6"

error()
{
  echo "benchmark testing failed on line $1"
  exit 1
}
trap 'error ${LINENO}' ERR

cat << EOF > /tmp/bench_pos.exp
	set timeout 60
	lassign \$argv engine hashsize threads depth fen

	spawn \$engine
	send "setoption name Debug Log File value /tmp/benchmark.pipe\n"
	send "setoption name Threads value \$threads\n"
	send "setoption name MultiPV value 3\n"
	send "setoption name UCI_ShowWDL value true\n"
	send "setoption name Hash value \$hashsize\n"
	send "position fen \"\$fen\"\n"

	send "isready\n"
	expect "readyok" {} timeout {exit 1}

	send "go depth \$FINAL_DEPTH_TO_BENCHMARK\n"
	expect "bestmove"
	
	send "quit\n"
	expect eof
EOF

cat << EOF > /tmp/bench.exp
	set timeout 60
	lassign \$argv engine hashsize threads depth

	spawn \$engine
	send "setoption name Debug Log File value /tmp/benchmark.pipe\n"
	send "setoption name Threads value \$threads\n"
	send "setoption name MultiPV value 3\n"
	send "setoption name UCI_ShowWDL value true\n"
	send "setoption name Hash value \$hashsize\n"

	send "isready\n"
	expect "readyok" {} timeout {exit 1}

	send "bench \$hashsize \$threads \$depth default depth NNUEn"
	expect "bestmove"
	
	send "quit\n"
	expect eof
EOF

#send "setoption name SyzygyPath value /mnt/ramfs/tablebase.lichess.ovh/tables/standard/6-wdl"

##### csv header format
echo -e "version,architecture,compiler,hashsize,threads,depth,nps"

for version in $VERSIONS; do
	for arch in $ARCHS; do
		for compiler in $COMPILERS; do
			engine=./stockfish-$version-$arch-$compiler
			for hashsize in $HASHSIZE_TO_BENCHMARK; do
				for threads in $THREADS_TO_BENCHMARK; do
					# Nodes/second data is printed to standard error.  Execute each engine and maintain only standard error output.
					# nps1=`$engine bench $hashsize $threads $depth default depth NNUE 2>&1 > /dev/null | tail -1 | grep "Nodes\/second" | sed "s/.*: \([0-9]*\)/\1/"`
					sleep 3
					nps=`expect /tmp/bench_pos.exp $engine $hashsize $threads $FINAL_DEPTH_TO_BENCHMARK $fen | tail -3 | grep "nps" | sed -e "s/^.* nps \([0-9]*\) .*/\1/g"`
					echo -e "$version, $arch, $compiler, $hashsize, $threads, $FINAL_DEPTH_TO_BENCHMARK $nps"
				done
			done
		done
	done
done

rm /tmp/bench.exp
rm /tmp/bench_pos.exp
#rm /tmp/benchmark.pipe
