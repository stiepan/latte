all:
	ghc --make -isrc/:src/grammar src/LatcLlvm.hs -o latc_llvm

clean:
	-find . -type f -name '*.o' -delete
	-find . -type f -name '*.hi' -delete

distclean: clean
	-rm -f latc_llvm
	

