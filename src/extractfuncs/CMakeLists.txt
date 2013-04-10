cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Sort the C sources into a neat list
list(SORT C_SOURCES)

add_definitions(-DSCREWUP)
# Set the compiler to use
set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -g")

# Compile our program

add_executable(extractfuncs ${C_SOURCES})
set_target_properties(extractfuncs PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "")
target_link_libraries(extractfuncs m)
