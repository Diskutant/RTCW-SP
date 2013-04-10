cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")

# Additional source files -- ### Find a better way of doing this.
list(APPEND C_SOURCES
	../botai/ai_chat.c
	../botai/ai_cmd.c
	../botai/ai_dmnet.c
	../botai/ai_dmq3.c
	../botai/ai_main.c
	../botai/ai_team.c 
)

# Sort the C sources into a neat list
list(SORT C_SOURCES)

add_definitions(-DCGAMEDLL)

# Set the compiler to use
set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -fPIC")

# use the OS suffix instead of .dll, things get confusing when that happens
# the variable name is `SO` because I am on linux
set(SO qagame-rtcw${CMAKE_SHARED_LIBRARY_SUFFIX})

# Add to our library. 
add_library(${SO} MODULE ${C_SOURCES})
set_target_properties(${SO} PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "")
target_link_libraries(${SO} dl m)

install(
	TARGETS ${SO}
	DESTINATION ${BASEGAME}
)
