set_property(GLOBAL PROPERTY USE_FOLDERS ON)

############################
# Check 32/64 bit platform #
if (${CMAKE_SIZEOF_VOID_P} MATCHES "8") # It is 64bit, otherwise 32 bit systems match 4
	set(PlatformName x64)
else (${CMAKE_SIZEOF_VOID_P} MATCHES "8")
	set(PlatformName x86)
endif(${CMAKE_SIZEOF_VOID_P} MATCHES "8")

if(ANDROID)
    set(PlatformName ${CMAKE_BUILD_TYPE}/${ANDROID_ABI})
endif(ANDROID)

if(MSVC)
	set(OUT_VERSION "${CMAKE_SYSTEM_NAME}/${CMAKE_VS_PLATFORM_TOOLSET}/${PlatformName}")
else(MSVC)
	set(OUT_VERSION "${CMAKE_SYSTEM_NAME}/${PlatformName}")
endif(MSVC)

message(STATUS "Build ${PlatformName}")

#############################
if(EMSCRIPTEN)
	option( BUILD_EMSCRIPTEN "Build EMSCRIPTEN" ON )
	option( BUILD_WASM "Build WASM" OFF )
	option( BUILD_SHARED_LIBS "Build SHARED" OFF )

	SET(CMAKE_CXX_FLAGS "-std=c++1z -fPIC")
	ADD_DEFINITIONS(-DBOOST_NO_CXX11_SCOPED_ENUMS)
	
	message("-----------------------------EMSCRIPTEN--------------------------------")
	if ("${EMSCRIPTEN_ROOT_PATH}" STREQUAL "")
		set(EMSCRIPTEN_ROOT_PATH "$ENV{EMSCRIPTEN}")
	endif()

	message("${EMSCRIPTEN_ROOT_PATH}")
	set(CMAKE_C_COMPILER "${EMSCRIPTEN_ROOT_PATH}/emcc")
	set(CMAKE_CXX_COMPILER "${EMSCRIPTEN_ROOT_PATH}/em++")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-warn-absolute-paths -s ALLOW_MEMORY_GROWTH=1 --memory-init-file 0")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-warn-absolute-paths -s ALLOW_MEMORY_GROWTH=1 --memory-init-file 0")

	include_directories(
		${EMSCRIPTEN_ROOT_PATH}/system/include
	)
else(EMSCRIPTEN)
	option( BUILD_EMSCRIPTEN "Build EMSCRIPTEN" OFF )
	option( BUILD_SHARED_LIBS "Build SHARED" ON )

	include(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("/std:c++latest" _cpp_latest_flag_supported)
    if (_cpp_latest_flag_supported)
        add_compile_options("/std:c++latest")
    endif()
endif(EMSCRIPTEN)

set (OUTPUT_DIR "${CMAKE_SOURCE_DIR}/bin/${OUT_VERSION}")
set (BIN_OUTPUT_DIR ${OUTPUT_DIR})
set (LIB_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/lib/${OUT_VERSION}")


SET(EXECUTABLE_OUTPUT_PATH ${OUTPUT_DIR})
SET(LIBRARY_OUTPUT_PATH ${OUTPUT_DIR})
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIB_OUTPUT_DIR})
set(CMAKE_PDB_OUTPUT_DIRECTORY  ${OUTPUT_DIR})	

link_directories(${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})

##############################
MACRO(SOURCE_GROUP_BY_DIR source_files)
    if(MSVC)
        set(sgbd_cur_dir ${CMAKE_CURRENT_SOURCE_DIR})
        foreach(sgbd_file ${${source_files}})
            string(REGEX REPLACE ${sgbd_cur_dir}/\(.*\) \\1 sgbd_fpath ${sgbd_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})

            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC)
ENDMACRO(SOURCE_GROUP_BY_DIR)

