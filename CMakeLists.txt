# required cmake version
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
# SDL generates a cmake file with no policy requirement, this is likely a bug but make cmake ignore it for now
cmake_policy(SET CMP0000 OLD)

# I do not like building from source in the same directory as the source tree
# force the user to build somewhere else like build/
if(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR} AND NOT WIN32)
	message(FATAL_ERROR "You can not use CMake to build RTCW from the root of it's source tree! Remove the CMakeCache.txt file from this directory, then create a separate directory (either below this directory or elsewhere), and then re-run CMake from there.")
endif(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR} AND NOT WIN32)

# Project name and the languages we're using
project(WolfSP C)
enable_language(CXX)

message(STATUS "Static Library suffix: ${CMAKE_STATIC_LIBRARY_SUFFIX}")

# Project version
SET(${PROJECT_NAME}_MAJOR_VERSION 0)
SET(${PROJECT_NAME}_MINOR_VERSION 0)
SET(${PROJECT_NAME}_PATCH_LEVEL 0)
message(STATUS ${WolfSP_SOURCE_DIR})

# Get the git revision location for the branch we're on
if(EXISTS "${${PROJECT_NAME}_SOURCE_DIR}/.git/HEAD")
	file(READ ${${PROJECT_NAME}_SOURCE_DIR}/.git/HEAD GIT_HEAD_LOC)
	string(LENGTH ${GIT_HEAD_LOC} HEAD_LEN)
	math(EXPR LEN "${HEAD_LEN} - 5")
	string(SUBSTRING ${GIT_HEAD_LOC} 5 ${LEN} GIT_HEAD)
endif(EXISTS "${${PROJECT_NAME}_SOURCE_DIR}/.git/HEAD")
	
# Get the git revision we're on for the version string
if(EXISTS "${${PROJECT_NAME}_SOURCE_DIR}/.git/${GIT_HEAD}")
	file(READ ${${PROJECT_NAME}_SOURCE_DIR}/.git/${GIT_HEAD} VERSION_STR)
	# Get the length of the string
	string(LENGTH ${VERSION_STR} VERSION_LEN)
	# Subtract 7 from the string's length
	math(EXPR VERSION_NUM_LEN "${VERSION_LEN} - ${VERSION_LEN} + 7")
	# Extract the value from the string
	string(SUBSTRING ${VERSION_STR} 0 ${VERSION_NUM_LEN} VERSION_GIT)
endif(EXISTS "${${PROJECT_NAME}_SOURCE_DIR}/.git/${GIT_HEAD}")

# Set our version strings
SET(VERSION_SIMPLE "${${PROJECT_NAME}_MAJOR_VERSION}.${${PROJECT_NAME}_MINOR_VERSION}.${${PROJECT_NAME}_PATCH_LEVEL}")
SET(VERSION_FULL "${${PROJECT_NAME}_MAJOR_VERSION}.${${PROJECT_NAME}_MINOR_VERSION}.${${PROJECT_NAME}_PATCH_LEVEL}-${VERSION_GIT}")


set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(APPLE)
	add_definitions(-DMACOS_X -D__MACOS__ -D__APPLE__ -D__MACH__)
endif(APPLE)


# include cmake stuff for checking various system specific defines
include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)
include(TestBigEndian)
include(TargetArch)

target_architecture(CMAKE_ARCH)
message(STATUS "Architecture: ${CMAKE_ARCH}")

# Check if we're using Big Endian
test_big_endian(BIGENDIAN)
if(${BIGENDIAN})
	add_definitions(-DBIGENDIAN -DQ3_BIG_ENDIAN)
else(${BIGENDIAN})
	add_definitions(-DLITTLEENDIAN -DQ3_LITTLE_ENDIAN)
endif(${BIGENDIAN})

# Check type sizes since we need them
check_type_size(int8_t INT8_T)
check_type_size(uint8_t UINT8_T)
check_type_size(int16_t INT16_T)
check_type_size(uint16_t UINT16_T)
check_type_size(int32_t INT32_T)
check_type_size(uint32_t UINT32_T)
check_type_size(int64_t INT64_T)
check_type_size(uint64_t UINT64_T)


# Standard C/C++ headers, they should exist on every platform
check_include_file(stdarg.h HAVE_STDARG_H REQUIRED)
check_include_file(ctype.h HAVE_CTYPE_H)
check_include_file(stdio.h HAVE_STDIO_H)
check_include_file(float.h HAVE_FLOAT_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(time.h HAVE_TIME_H)
check_include_file(limits.h HAVE_LIMITS_H)
check_include_file(math.h HAVE_MATH_H)
check_include_file(assert.h HAVE_ASSERT_H)
check_include_file(file.h HAVE_FILE_H)
check_include_file(errno.h HAVE_ERRNO_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(malloc.h HAVE_MALLOC_H)
check_include_file(setjmp.h HAVE_SETJMP_H)


# check the following system specific functions/files needed by the game
if(UNIX OR APPLE)
	check_include_file(gl.h HAVE_GL_H)
	check_include_file(sys/time.h HAVE_SYS_TIME_H)
	check_include_file(sys/types.h HAVE_SYS_TYPES_H)
	check_include_file(sys/mman.h HAVE_SYS_MMAN_H)
	check_include_file(sys/vt.h HAVE_SYS_VT_H)
	check_include_file(sys/stat.h HAVE_SYS_STAT_H)
	check_include_file(sys/ioctl.h HAVE_SYS_IOCTL_H)
	check_include_file(sys/socket.h HAVE_SYS_SOCKET_H)
	check_include_file(sys/param.h HAVE_SYS_PARAM_H)
	check_include_file(sys/uio.h HAVE_SYS_UIO_H)
	check_include_file(sys/wait.h HAVE_SYS_WAIT_H)
	check_include_file(sys/ipc.h HAVE_SYS_IPC_H)
	check_include_file(sys/shm.h HAVE_SYS_SHM_H)
	check_include_file(sys/soundcard.h HAVE_SYS_SOUNDCARD_H)
	check_include_file(sys/prctl.h HAVE_SYS_PRCTL_H)
	check_include_file(arpa/inet.h HAVE_ARPA_INET_H)
	check_include_file(netdb.h HAVE_NETDB_H)
	check_include_file(netinet/in.h HAVE_NETINET_IN_H)
	check_include_file(dlfcn.h HAVE_DLFCN_H)
	check_include_file(semaphore.h HAVE_SEMAPHORE_H)
	check_include_file(signal.h HAVE_SIGNAL_H)
	check_include_file(pthread.h HAVE_PTHREAD_H)
	check_include_file(termios.h HAVE_TERMIOS_H)
	check_include_file(dirent.h HAVE_DIRENT_H)
	check_include_file(pwd.h HAVE_PWD_H)
	check_include_file(fpu_control.h HAVE_FPU_CONTROL_H)
	check_include_file(mntent.h HAVE_MNTENT_H)
	check_include_file(fcntl.h HAVE_FCNTL_H)
	check_include_file(glob.h HAVE_GLOB_H)
	check_include_file(abi_mutex.h HAVE_ABI_MUTEX_H)
	check_include_file(task.h HAVE_TASK_H)
	check_include_file(libc.h HAVE_LIBC_H)
	check_include_file(unistd.h HAVE_UNISTD_H)
	check_include_file(io.h HAVE_IO_H)
	check_include_file(lmcons.h HAVE_LMCONS_H)
	check_include_file(lmwksta.h HAVE_LMWKSTA_H)
	check_include_file(lmerr.h HAVE_LMERR_H)
	check_include_file(stdint.h HAVE_STDINT_H)
	check_include_file(mmsystem.h HAVE_MMSYSTEM_H)
	check_include_file(mmreg.h HAVE_MMREG_H)
	check_include_file(X11/keysym.h HAVE_X11_KEYSYM_H)
	check_include_file(X11/cursorfont.h HAVE_X11_CURSORFONT_H)
	check_include_file(X11/extensions/Xxf86dga.h HAVE_X11_EXTENSIONS_XXF86DGA_H)
	check_include_file(X11/extensions/xf86vmode.h HAVE_X11_EXTENSIONS_XF86VMODE_H)
	
	check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
	check_function_exists(strcasecmp HAVE_STRCASECMP)
	check_function_exists(stricmp HAVE_STRICMP)
	check_function_exists(strlcat HAVE_STRLCAT)
	check_function_exists(strlcpy HAVE_STRLCPY)
	check_function_exists(umask HAVE_UMASK)
	
	# OS X exclusive
	if(APPLE)
		check_include_file(CoreServices/CoreServices.h HAVE_CORESERVICES_CORESERVICES_H)
		check_include_file(CoreAudio/AudioHardware.h HAVE_COREAUDIO_AUDIOHARDWARE_H)
		check_include_file(QuickTime/QuickTime.h HAVE_QUICKTIME_QUICKTIME_H)
		check_include_file(Carbon/Carbon.h HAVE_CARBON_CARBON_H)
		check_include_file(ApplicationServices/ApplicationServices.h HAVE_APPLICATIONSERVICES_APPLICATIONSERVICES_H)
		check_include_file(MacTypes.h HAVE_MACTYPES_H)
		check_include_file(OpenGL/CGLTypes.h HAVE_OPENGL_CGLTYPES_H)
		check_include_file(OpenGL/gl.h HAVE_OPENGL_GL_H)
		check_include_file(OpenGL/glu.h HAVE_OPENGL_GLU_H)
		check_include_file(OpenGL/glext.h HAVE_OPENGL_GLEXT_H)
		check_include_file(OpenGL/CGLMacro.h HAVE_OPENGL_CGLMACRO_H)
	elseif(NOT APPLE)
		check_include_file(linux/joystick.h HAVE_LINUX_JOYSTICK_H)
		check_include_file(linux/soundcard.h HAVE_LINUX_SOUNDCARD_H)
		check_include_file(GL/gl.h HAVE_GL_gl_H)
		check_include_file(GL/glx.h HAVE_GL_glx_H)
		check_include_file(GL/fxmesa.h HAVE_GL_fxmesa_H)
	endif(APPLE)
elseif(WIN32)
	check_include_file(Windows.h HAVE_WINDOWS_H)
	check_include_file(dsound.h HAVE_DSOUND_H)
	check_include_file(direct.h HAVE_DIRECT_H)
	check_include_file(dinput.h HAVE_DINPUT_H)
	check_include_file(winsock.h HAVE_WINSOCK_H)
	check_include_file(wsipx.h HAVE_WSIPX_H)
	check_include_file(gl/gl.h HAVE_gl_gl_H)
	check_include_file(conio.h HAVE_CONIO_H)
	#if(MSVC)
		# msvc shit later
	#elseif(CYGWIN)
		# cygwin shit later
	#endif(MSVC)
endif(UNIX OR APPLE)

# Various options we could use
option(USE_LLVM_GOLD "If clang is specified, use LLVM Gold optimizations" OFF)

# Set the install directory for the .so's
set(BASEGAME "main")

# If we're using clang..
if(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND ${USE_LLVM_GOLD})
	#SET (CMAKE_C_COMPILER             "/usr/bin/clang")
	SET (CMAKE_C_FLAGS                "-Wall -std=c99")
	SET (CMAKE_C_FLAGS_DEBUG          "-g")
	SET (CMAKE_C_FLAGS_MINSIZEREL     "-Os -DNDEBUG")
	SET (CMAKE_C_FLAGS_RELEASE        "-O4 -DNDEBUG")
	SET (CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g")

	#SET (CMAKE_CXX_COMPILER             "/usr/bin/clang++")
	SET (CMAKE_CXX_FLAGS                "-Wall -std=c++11 -stdlib=c++11")
	SET (CMAKE_CXX_FLAGS_DEBUG          "-g")
	SET (CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")
	SET (CMAKE_CXX_FLAGS_RELEASE        "-O4 -DNDEBUG")
	SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")

	find_program(LLVM_AR llvm-ar REQUIRED)
	find_program(LLVM_LD llvm-ld REQUIRED)
	find_program(LLVM_NM llvm-nm REQUIRED)
	find_program(LLVM_OBJDUMP llvm-objdump REQUIRED)
	find_program(LLVM_RANLIB llvm-ranlib REQUIRED)
	message(STATUS "llvm-ar: ${LLVM_AR}")
	message(STATUS "llvm-ld: ${LLVM_LD}")
	message(STATUS "llvm-nm: ${LLVM_NM}")
	message(STATUS "llvm-objdump: ${LLVM_OBJDUMP}")
	message(STATUS "llvm-ranlib: ${LLVM_RANLIB}")

	SET (CMAKE_AR      "${LLVM_AR}")
	if(LLVM_LD-NOTFOUND)
		find_program(NORMAL_LD NAMES ld.gold ld)
		SET (CMAKE_LINKER  "${NORMAL_LD} -use-gold-plugin")
	endif(LLVM_LD-NOTFOUND)
	SET (CMAKE_NM      "${LLVM_NM}")
	SET (CMAKE_OBJDUMP "${LLVM_OBJDUMP}")
	SET (CMAKE_RANLIB  "${LLVM_RANLIB}")
endif(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND ${USE_LLVM_GOLD})

# windows crap
if(WIN32)
	add_definitions(-DWIN32 -D_WIN32)
endif(WIN32)


if(NOT WIN32)
	# Set the basic build types, there's debug, release, and demo
	if(CMAKE_BUILD_TYPE STREQUAL "DEBUG" OR CMAKE_BUILD_TYPE STREQUAL "RELWITHDEBINFO")
		set(DEBUG_BUILD TRUE)
		set(CXXFLAGS "${CXXFLAGS} -g -Wall -O")
		if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
			add_definitions(-D__extern_always_inline=inline)
		endif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
	endif(CMAKE_BUILD_TYPE STREQUAL "DEBUG" OR CMAKE_BUILD_TYPE STREQUAL "RELWITHDEBINFO")
endif(NOT WIN32)

if(CMAKE_BUILD_TYPE STREQUAL "DEMO" OR CMAKE_BUILD_TYPE STREQUAL "RELEASE")
	set(DEMO_BUILD TRUE)
	add_definitions(-DNDEBUG)

	# Flags to make clang happy and compatible
	if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
		if(${USE_LLVM_GOLD})
			# Attempt to use LLVM Gold and optimize the fuck out of this code
			set(CXXFLAGS "${CXXFLAGS} -O4 -ffast-math -fsigned-char -emit-llvm")
		else(${USE_LLVM_GOLD})
			# Use normal optimizations that clang offers
			set(CXXFLAGS "${CXXFLAGS} -O3 -ffast-math -fsigned-char")
		endif(${USE_LLVM_GOLD})
		# llvm fails with some of the inlining used in math.h, this fixes it
		add_definitions(-D__extern_always_inline=inline)
	else(CMAKE_C_COMPILER_ID STREQUAL "Clang")
		if(NOT MSVC)
			set(CXXFLAGS "${CXXFLAGS} -O3 -ffast-math -fno-strict-aliasing -fstrength-reduce -fsigned-char")
		endif(NOT MSVC)
	endif(CMAKE_C_COMPILER_ID STREQUAL "Clang")

	# Demo mode only has a second definition from release
	if(CMAKE_BUILD_TYPE STREQUAL "DEMO")
		add_definitions(-DWOLF_SP_DEMO)
		set(BASEGAME "demomain")
	endif(CMAKE_BUILD_TYPE STREQUAL "DEMO")
endif(CMAKE_BUILD_TYPE STREQUAL "DEMO" OR CMAKE_BUILD_TYPE STREQUAL "RELEASE")


# If we are not using Visual Studio, we'll run the following checks
if(NOT MSVC)
	# Check if the C++ compiler can accept the -pipe flag, and add it to the compile flags if it works
	check_c_compiler_flag(-pipe HAVE_PIPE_FLAG)
	check_cxx_compiler_flag(-pipe HAVE_PIPE_FLAG)
	# If the flag was accepted, add it to the list of flags
	if(HAVE_PIPE_FLAG)
		set(CXXFLAGS "${CXXFLAGS} -pipe")
	endif(HAVE_PIPE_FLAG)

	# The following are additional library checks, they are not required for Windows
	if(NOT WIN32)
		# Check if socket is within the socket library (if the library exists), and add it to the linker flags if needed
		check_library_exists(socket socket "" HAVE_SOCKET_LIB)
		if(HAVE_SOCKET_LIB)
			list(APPEND LINK_LIBS socket)
		endif(HAVE_SOCKET_LIB)
		# Check if inet_addr is within the nsl library (if the library exists), and add it to the linker flags if needed
		check_library_exists(nsl inet_addr "" HAVE_NSL_LIB)
		if(HAVE_NSL_LIB)
			list(APPEND LINK_LIBS nsl)
		endif(HAVE_NSL_LIB)
		# Check if pthread_create is within the pthread library (if the library exists), and add it to the linker flags if needed
		check_library_exists(pthread pthread_create "" HAVE_PTHREAD)
		if(HAVE_PTHREAD)
			set(LDFLAGS "${LDFLAGS} -pthread")
		else(HAVE_PTHREAD)
			message(FATAL_ERROR "The pthread library is required to build ${PROJECT_NAME}")
		endif(HAVE_PTHREAD)
	endif(NOT WIN32)
else(NOT MSVC)
	# If using Visual Studio, set the C++ flags accordingly
	# Remove the default exception handling flags, also remove default warning level flag
	string(REPLACE "/EHsc " "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
	string(REPLACE "/GX " "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
	string(REPLACE "/W3 " "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
	# Set the compile flags to have warnings on the max setting (but disable a few annoying ones), exception handling turned on, the proper defines
	set(CXXFLAGS "${CXXFLAGS} /W4 /wd4100 /wd4127 /wd4250 /wd4251 /wd4355 /wd4706 /wd4800 /wd4996 /EHs")
	if(DEBUG_BUILD)
		add_definitions(-D_DEBUG -D_WINDOWS -D__USEA3D -D__A3D_GEOM -DWIN32 -D_CRT_SECURE_NO_WARNINGS)
	else(DEBUG_BUILD)
		add_definitions(-DNDEBUG -D_WINDOWS -D__USEA3D -D__A3D_GEOM -DWIN32 -D_CRT_SECURE_NO_WARNINGS)
	endif(DEBUG_BUILD)
endif(NOT MSVC)

# detect what package manager we have and if it is usable
# This is so that if we have a missing lib on the system (e.g. libSDL, libjpeg)
# we can prompt the user to install the lib or not.
# This will work for most distros but some oddballers wont work (and usually the 
# user will probably know what they're doing)
## Debian based systems, check for apt-get or aptitude
find_program(APT apt-get NAMES apt-get aptitude)
## REHL systems, look for yum.
find_program(YUM yum)
## BSD systems, pkg_add --- Add ports possibly?
find_program(PKG NAMES pkg_add pkg)
## Arch Linux and their stupid name for a package manager, pacman
find_program(PACMAN pacman)
## Gentoo package manager, emerge
find_program(EMERGE emerge)
## Find sudo in case we need it
find_program(SUDO sudo)
if(NOT SUDO_FOUND)
	set(SUDO FALSE)
endif(NOT SUDO_FOUND)

# The game was designed for windows, SDL is not required for the moment
# maybe in the future it will be but I would rather it not so SDL does
# not need to be included into the build via CMake download or something
if(NOT WIN32)
	# Find the required SDL libraries
	find_package(SDL REQUIRED)
	find_package(SDL_sound REQUIRED)
	find_package(SDL_image REQUIRED)
endif(NOT WIN32)

# Begin the madness!
#############################################################################################
set(SDL_Libs)
set(PACKAGECOMMAND)
# Pacman is annoying in that they use all lowercase
# whereas most other package managers use whatever the
# package name is.
if(NOT SDL_FOUND)
	if(NOT PACMAN)
		set(SDL_Libs "${SDL_Libs} SDL")
	else(NOT PACMAN)
		set(SDL_Libs "${SDL_Libs} sdl")
	endif(NOT PACMAN)
endif(NOT SDL_FOUND)

if(NOT SDL_SOUND_FOUND)
	if(NOT PACMAN)
		set(SDL_Libs "${SDL_Libs} SDL_sound")
	else(NOT PACMAN)
		if(NOT APT)
			set(SDL_Libs "${SDL_Libs} sdl_sound")
		else(NOT APT)
			set(SDL_Libs "${SDL_Libs} libsdl-sound1.2")
		endif(NOT APT)
	endif(NOT PACMAN)
endif(NOT SDL_SOUND_FOUND)

if(NOT SDL_IMAGE_FOUND)
	if(NOT PACMAN)
		set(SDL_Libs "${SDL_Libs} SDL_image")
	else(NOT PACMAN)
		if(NOT APT)
			set(SDL_Libs "${SDL_Libs} sdl_image")
		else(NOT APT)
			set(SDL_Libs "${SDL_Libs} libsdl-image1.2")
		endif(NOT APT)
	endif(NOT PACMAN)
endif(NOT SDL_IMAGE_FOUND)

if(SDL_Libs)
	if(PACMAN)
		set(PACKAGECOMMAND "${PACMAN} -S ${SDL_Libs}")
	else(PACMAN)
		if(YUM)
			set(PACKAGECOMMAND "${YUM} install ${SDL_Libs}")
		else(YUM)
			if(APT)
				set(PACKAGECOMMAND "${APT} install ${SDL_Libs}")
			else(APT)
				if(PKG)
					set(PACKAGECOMMAND "${PKG} -r ${SDL_Libs}")
				else(PKG)
					if(EMERG)
						# Untested as of 05/07/13
						set(PACKAGECOMMAND "${EMERG} ${SDL_Libs}")
					else(EMERG)
						if(NOT WIN32)
							message(FATAL_ERROR "Could not find a suitable package manager. Please install ${SDL_Libs} and re-run cmake (or ./configure)")
						endif(NOT WIN32)
					endif(EMERG)
				endif(PKG)
			endif(APT)
		endif(YUM)
	endif(PACMAN)
	
	if(SUDO)
		message(STATUS "Your sudoers password is required to run the following command:")
		message(STATUS "${SUDO} ${PACKAGECOMMAND}")
	endif(SUDO)
	
	# Install!
	execute_process(COMMAND "${SUDO} ${PACKAGECOMMAND}")
endif(SDL_Libs)
#############################################################################################

include_directories(include)

SET(CMAKE_C_FLAGS)
SET(CMAKE_CXX_FLAGS)
SET(CMAKE_C_FLAGS ${CXXFLAGS})
SET(CMAKE_CXX_FLAGS ${CXXFLAGS})

# Find perl
find_program(PERL perl)

set(USE_RUN_CC_PL TRUE)
if(PERL AND USE_RUN_CC_PL AND NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")
	# C++ compiles
	set(CMAKE_CXX_COMPILE_OBJECT "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_CXX_COMPILE_OBJECT}")
	set(CMAKE_CXX_LINK_EXECUTABLE "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_CXX_LINK_EXECUTABLE}")
	set(CMAKE_CXX_CREATE_SHARED_MODULE "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_CXX_CREATE_SHARED_MODULE}")
	# C compiles
	set(CMAKE_C_COMPILE_OBJECT "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_C_COMPILE_OBJECT}")
	set(CMAKE_C_LINK_EXECUTABLE "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_C_LINK_EXECUTABLE}")
	set(CMAKE_C_CREATE_SHARED_MODULE "${PERL} ${CMAKE_SOURCE_DIR}/run-cc.pl -q ${CMAKE_C_CREATE_SHARED_MODULE}")
endif(PERL AND USE_RUN_CC_PL AND NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")


# Add all the sub directories for compile
# jpeg-6 sources, this will likely go away soon
add_subdirectory(src/jpeg-6)
add_subdirectory(src/botlib)
add_subdirectory(src/splines)
add_subdirectory(src/cgame)
add_subdirectory(src/game)
add_subdirectory(src/extractfuncs)
add_subdirectory(src/ui)
add_subdirectory(src/client)

# If we have the GtkRadiant subdirectory from the git submodule
if(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/GtkRadiant/include/")
	add_subdirectory(src/bspc)
endif(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/GtkRadiant/include/")

# according to the original cons build system, bspc was not built.
# a cmake file exists anyway -- though untested.
# You will need GtkRadiant, you can find it here: https://github.com/TTimo/GtkRadiant
#add_subdirectory(src/bspc)

# If a INSTDIR was passed in to CMake, use it as the install prefix, otherwise set the default install prefix to the bots directory under the user's home directory
#if(NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr/local/" AND INSTDIR)
#	set(CMAKE_INSTALL_PREFIX "${INSTDIR}")
#else(NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr/local/" AND INSTDIR)
#	set(CMAKE_INSTALL_PREFIX "/opt/wolfsp")
#endif(NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr/local/" AND INSTDIR)
