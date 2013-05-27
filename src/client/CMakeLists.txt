cmake_minimum_required(VERSION 2.8)

# initialize our variables
set(RENDERER_SOURCES)
set(QCOMMON_SOURCES)
set(SERVER_SOURCES)
set(PLATFORM_SOURCES)
set(CLIENT_SOURCES)
set(QVM_SOURCES)

# Used for removing from QCommon
set(ALL_QVM_SOURCES
	../qcommon/vm_interpreted.c
	../qcommon/vm_none.c
	../qcommon/vm_x86.c
)

################
# Detect the platform we're on so we can compile the QVM

list(APPEND QVM_SOURCES "../qcommon/vm_interpreted.c;../qcommon/vm_none.c")


################

## Make lists of all the sources we need
# renderer sources
file(GLOB RENDERER_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../renderer/*.c")
list(SORT RENDERER_SOURCES)

# common sources
file(GLOB QCOMMON_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../qcommon/*.c")
# Remove QVM, we add it later in CMake.
list(REMOVE_ITEM QCOMMON_SOURCES ${ALL_QVM_SOURCES})
list(SORT QCOMMON_SOURCES)


if(UNIX AND NOT APPLE)
# *nix specific sources
# We use a list to avoid the qvm stuff that fails to compile on x86_64
set(PLATFORM_SOURCES_UNIX
	${CMAKE_SOURCE_DIR}/src/unix/unix_main.c
	${CMAKE_SOURCE_DIR}/src/unix/unix_net.c
	${CMAKE_SOURCE_DIR}/src/unix/unix_shared.c
	# Linux common is a stub an should be removed..
	${CMAKE_SOURCE_DIR}/src/unix/linux_common.c
)
file(GLOB PLATFORM_SOURCES_SDL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../sdl/*.c")
list(APPEND PLATFORM_SOURCES ${PLATFORM_SOURCES_UNIX} ${PLATFORM_SOURCES_SDL})
endif(UNIX AND NOT APPLE)

if(APPLE)
	file(GLOB PLATFORM_SOURCES_C RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../macosx/*.c")
	file(GLOB PLATFORM_SOURCES_SDL RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../sdl/*.c")
	file(GLOB PLATFORM_SOURCES_M RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../macosx/*.m")
	#list(APPEND PLATFORM_SOURECS "${CMAKE_SOURCE_DIR}/unix/unix_net.c")
	list(APPEND PLATFORM_SOURCES ${PLATFORM_SOURCES_C} ${PLATFORM_SOURCES_M} ${PLATFORM_SOURCES_SDL})
	list(SORT PLATFORM_SOURCES)
endif(APPLE)

if(WIN32)
	file(GLOB PLATFORM_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../win32/*.c")
	list(APPEND PLATFORM_SOURCES "../win32/save/win_snd.c")
	list(SORT PLATFORM_SOURCES)
endif(WIN32)

# Server sources
file(GLOB SERVER_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "../server/*.c")
list(SORT SERVER_SOURCES)
# message(STATUS "SERVER_SOURCES: ${SERVER_SOURCES}")

# Get all the client .c files for compile
file(GLOB CLIENT_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.c")
list(SORT CLIENT_SOURCES)
# message(STATUS "CLIENT_SOURCES: ${CLIENT_SOURCES}")

set(ADDITONAL_SOURCES
	${CMAKE_SOURCE_DIR}/src/game/q_shared.c
	${CMAKE_SOURCE_DIR}/src/game/q_math.c
)

# Append all of our sources to one list and set it ready to compile.
list(APPEND CLIENT_SOURCES ${RENDERER_SOURCES} ${QCOMMON_SOURCES} ${PLATFORM_SOURCES}
			${ADDITONAL_SOURCES} ${SERVER_SOURCES} ${SERVER_SOURCES} ${QVM_SOURCES})

set_source_files_properties(${CLIENT_SOURCES} PROPERTIES LANGUAGE C COMPILE_FLAGS "${CXXFLAGS} -g")
# message(STATUS "CLIENT_SOURCES: ${CLIENT_SOURCES}")

# Compile our program
add_executable(${PROJECT_NAME} ${CLIENT_SOURCES})
add_dependencies(${PROJECT_NAME} botlib${CMAKE_STATIC_LIBRARY_SUFFIX} jpeg-6${CMAKE_STATIC_LIBRARY_SUFFIX} splines${CMAKE_STATIC_LIBRARY_SUFFIX})

# Our executable
if(NOT APPLE)
	set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "")
	target_link_libraries(${PROJECT_NAME} ${SDL_LIBRARY} ${SDL_IMAGE_LIBRARIES} SDL_image GL dl m botlib${CMAKE_STATIC_LIBRARY_SUFFIX} jpeg-6${CMAKE_STATIC_LIBRARY_SUFFIX} splines${CMAKE_STATIC_LIBRARY_SUFFIX})
else(NOT APPLE)
	set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C PREFIX "" SUFFIX "" LINK_FLAGS "-framework Carbon -framework GLUT -framework OpenGL -framework IOKit -framework AudioToolbox -framework CoreAudio -framework CoreServices")
	target_link_libraries(${PROJECT_NAME} ${SDL_LIBRARY} ${SDL_IMAGE_LIBRARIES} dl m botlib${CMAKE_STATIC_LIBRARY_SUFFIX} jpeg-6${CMAKE_STATIC_LIBRARY_SUFFIX} splines${CMAKE_STATIC_LIBRARY_SUFFIX})
endif(NOT APPLE)

install(
	TARGETS ${PROJECT_NAME}
	DESTINATION .
)
