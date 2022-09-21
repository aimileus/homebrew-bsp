class MulticorebspC < Formula
  desc "Library for multicore programming in C"
  homepage "http://multicorebsp.com"
  url "http://multicorebsp.com/downloads/c/2.0.4/MulticoreBSP-for-C.tar.xz"
  sha256 "fad70180163bf3fdb9f02b45696f30de0b1b0d9be72686ce79e20c41a3f9b95c"
  license "LGPL-3.0-or-later"

  patch :DATA

  def install
    system "make"

    inreplace "tools/bspcc", /MCBSP_PATH=".*"/, "MCBSP_PATH=#{prefix}/"
    inreplace "tools/bspcxx", /MCBSP_PATH=".*"/, "MCBSP_PATH=#{prefix}/"

    bin.install Dir.glob("tools/*")
    include.install Dir.glob("include/*")
    lib.install Dir.glob("lib/*")
    lib.install Dir.glob("*.shared.o")
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test multicorebsp-c`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
--- a/include.default	2019-03-30 23:21:47
+++ b/include.default	2022-09-21 07:16:27
@@ -1,3 +1,4 @@
+OS := $(shell uname -s)

 #Uncomment the below to enable checkpointing under Linux, using http://dmtcp.sourceforge.net
 #WITH_DMTCP=yes
@@ -11,11 +12,15 @@

 #Linkage flags for shared library build
 #Linux:
-SHARED_LINKER_FLAGS=-shared -Wl,-soname,libmcbsp.so.${MAJORVERSION} -o lib/libmcbsp.so.${VERSION}
-C_STANDARD_FLAGS=-D_POSIX_C_SOURCE=200112L
+ifeq ($(OS), Linux)
+	SHARED_LINKER_FLAGS=-shared -Wl,-soname,libmcbsp.so.${MAJORVERSION} -o lib/libmcbsp.so.${VERSION}
+	C_STANDARD_FLAGS=-D_POSIX_C_SOURCE=200112L
+endif
 #OS X:
-#SHARED_LINKER_FLAGS=-Wl,-U,_main -dynamiclib -install_name "libmcbsp.${MAJORVERSION}.dylib" -current_version ${VERSION} -compatibility_version ${MAJORVERSION}.0 -o libmcbsp.${MAJORVERSION}.dylib
-#C_STANDARD_FLAGS=
+ifeq ($(OS), Darwin)
+	SHARED_LINKER_FLAGS=-Wl,-U,_main -dynamiclib -install_name "libmcbsp.${MAJORVERSION}.dylib" -current_version ${VERSION} -compatibility_version ${MAJORVERSION}.0 -o libmcbsp.${MAJORVERSION}.dylib
+	C_STANDARD_FLAGS=
+endif

 #add -fPIC when we compile with DMTCP
 ifdef WITH_DMTCP
@@ -39,15 +44,17 @@
 AR=ar

 #clang LLVM compiler:
-#CCEXEC=clang
-#CPPEXEC=clang++
-#CFLAGS:=${LLVMFLAGS} -I.
-#CC=${CCEXEC} ${C_STANDARD_FLAGS} -std=c99
-#CPPFLAGS:=${LLVMFLAGS} -I.
-#CPP=${CPPEXEC} -std=c++98
-#CPP11=${CPPEXEC} -std=c++11 -Wno-c++98-compat
-#LFLAGS:=`${RELPATH}deplibs.sh ${CC}`
-#AR=ar
+ifeq ($(OS), Darwin)
+	CCEXEC=clang
+	CPPEXEC=clang++
+	CFLAGS:=${LLVMFLAGS} -I.
+	CC=${CCEXEC} ${C_STANDARD_FLAGS} -std=c99
+	CPPFLAGS:=${LLVMFLAGS} -I.
+	CPP=${CPPEXEC} -std=c++98
+	CPP11=${CPPEXEC} -std=c++11 -Wno-c++98-compat
+	LFLAGS:=`${RELPATH}deplibs.sh ${CC}`
+	AR=ar
+endif

 #Intel C++ Compiler:
 #CCEXEC=icc
@@ -137,4 +144,3 @@

 %.cpp11.shared.o: %.cpp
 	${CPP11} -fPIC ${OPT} ${CPPFLAGS} -c -o $@ $^
-
