# from http://mhungerford.blogspot.com/2010/10/cmake-and-clangllvm-fun.html
#include using cmake -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake
INCLUDE(CMakeForceCompiler) #Disables checks
#SET(CMAKE_SYSTEM_NAME Generic)
#Generic removes -rdynamic from linker, which llvm-ld doesn't support

find_program(CLANG clang)
find_program(CLANGXX clang++)
find_program(LLVMLD NAMES llvm-ld llvm-ld-3.1 llvm-ld-3.2 llvm-ld-3.3 llvm-ld-3.4 ld)
find_program(LLVMAR NAMES llvm-ar llvm-ar-3.1 llvm-ar-3.2 llvm-ar-3.3 llvm-ar-3.4)
find_program(LLVMRANLIB NAMES llvm-ranlib llvm-ranlib-3.1 llvm-ranlib-3.2 llvm-ranlib-3.3 llvm-ranlib-3.4)

CMAKE_FORCE_C_COMPILER( ${CLANG} CLang )
CMAKE_FORCE_CXX_COMPILER ( ${CLANGXX} CLang )
SET(CMAKE_RANLIB "${LLVMRANLIB}" CACHE INTERNAL STRING)
SET(CMAKE_AR "${LLVMAR}" CACHE INTERNAL STRING)

SET(CMAKE_LINKER "${LLVMLD}" CACHE INTERNAL STRING)
#SET(CMAKE_C_LINKER "${LLVMLD}")
#SET(CMAKE_CXX_LINKER "${LLVMLD}")

SET(CMAKE_C_LINK_EXECUTABLE "${LLVMLD} <OBJECTS> -o  <TARGET> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>")
SET(CMAKE_CXX_LINK_EXECUTABLE "${LLVMLD} <OBJECTS> -o  <TARGET> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>")

#SET(CMAKE_FIND_ROOT_PATH /usr/bin)
#SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
