cmake_minimum_required(VERSION 2.8)

# Get all C source files
file(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")
file(GLOB AI_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../botai/*.c")

# Make a second list copying the first
set(GAME_SOURCES ${C_SOURCES})
set(SOURCE_FILES)

# Remove g_save.c of course, it is genned by extractfuncs.
#list(REMOVE_ITEM GAME_SOURCES "g_save.c")

# Additional source files
list(APPEND C_SOURCES ${AI_SOURCES})

# Sort the C sources into a neat list
list(SORT C_SOURCES)
list(SORT GAME_SOURCES)

# Generate the required headers
# but we depend on extractfuncs so that must be built prior
add_custom_command(
	OUTPUT g_funcs.h g_func_decs.h
	COMMAND extractfuncs -o ${CMAKE_CURRENT_BINARY_DIR}/g_funcs.h ${CMAKE_CURRENT_BINARY_DIR}/g_func_decs.h ${GAME_SOURCES}
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	DEPENDS extractfuncs
) 

# Make the heads a target to depend on
add_custom_target(
	game_func_headers
	ALL DEPENDS
	${CMAKE_CURRENT_BINARY_DIR}/g_funcs.h
	${CMAKE_CURRENT_BINARY_DIR}/g_func_decs.h
)

# Include those headers
include_directories(${CMAKE_CURRENT_BINARY_DIR})

if(NOT WIN32)
	# Set the compiler to use
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -fPIC")
else(NOT WIN32)
	set_source_files_properties(${C_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS}")
endif(NOT WIN32)

# use the OS suffix instead of .dll, things get confusing when that happens
# the variable name is `SO` because I am on linux
set(SO qagame-rtcw${CMAKE_SHARED_LIBRARY_SUFFIX})

# Add to our library. 
add_library(${SO} MODULE ${C_SOURCES})
set_target_properties(${SO} PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "" COMPILE_DEFINITIONS GAMEDLL)
# depend on the headers
add_dependencies(${SO} game_func_headers)

if(NOT WIN32)
	target_link_libraries(${SO} dl m)
else(NOT WIN32)
	target_link_libraries(${SO} winmm.lib)
endif(NOT WIN32)

install(
	TARGETS ${SO}
	DESTINATION ${BASEGAME}
)
