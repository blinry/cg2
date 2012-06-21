# - Try to find FFMPEG
# Once done this will define
#  
#  FFMPEG_FOUND        - system has FFMPEG
#  FFMPEG_INCLUDE_DIR  - the include directory
#  FFMPEG_LIBRARY_DIR  - the directory containing the libraries
#  FFMPEG_LIBRARIES    - Link these to use FFMPEG
#   

SET( FFMPEG_HEADERS avformat.h avcodec.h avutil.h avdevice.h swscale.h )
if( WIN32 )
   SET( FFMPEG_LIBRARIES avformat.lib avcodec.lib avutil.lib avdevice.lib swscale.lib )
   FIND_PATH( FFMPEG_INCLUDE_DIR ${FFMPEG_HEADERS}
              PATHS $ENV{FFMPEGDIR}/include/ffmpeg )
   FIND_PATH( FFMPEG_LIBRARY_DIR ${FFMPEG_LIBRARIES}
              PATHS $ENV{FFMPEGDIR}/lib )
else( WIN32 )
    INCLUDE(FindPkgConfig)

    #FindAvformat
    if ( PKG_CONFIG_FOUND )
       pkg_check_modules( AVFORMAT libavformat )
    endif ( PKG_CONFIG_FOUND )
  
    FIND_PATH( AVFORMAT_INCLUDE_DIR avformat.h
               PATHS ${AVFORMAT_INCLUDE_DIRS}
                     /usr/include/
                     /usr/include/ffmpeg/
               PATH_SUFFIXES libavformat )

    FIND_LIBRARY( AVFORMAT_LIBRARY avformat
                  PATHS ${AVFORMAT_LIBRARY_DIRS}
                        /usr/lib/
                        /usr/lib/ffmpeg/ )
    #FindAvcodec
    if ( PKG_CONFIG_FOUND )
       pkg_check_modules( AVCODEC libavcodec )
    endif ( PKG_CONFIG_FOUND )
  
    FIND_PATH( AVCODEC_INCLUDE_DIR avcodec.h
               PATHS ${AVCODEC_INCLUDE_DIRS}
                     /usr/include/
                     /usr/include/ffmpeg/
               PATH_SUFFIXES libavcodec )

    FIND_LIBRARY( AVCODEC_LIBRARY avcodec
                  PATHS ${AVCODEC_LIBRARY_DIRS}
                        /usr/lib/
                        /usr/lib/ffmpeg/ )
    #FindAvutil
    if ( PKG_CONFIG_FOUND )
       pkg_check_modules( AVUTIL libavutil )
    endif ( PKG_CONFIG_FOUND )

    FIND_PATH( AVUTIL_INCLUDE_DIR avutil.h
               PATHS ${AVUTIL_INCLUDE_DIRS}
                     /usr/include/
                     /usr/include/ffmpeg/
               PATH_SUFFIXES libavutil )

    FIND_LIBRARY( AVUTIL_LIBRARY avutil
                  PATHS ${AVUTIL_LIBRARY_DIRS}
                        /usr/lib/
                        /usr/lib/ffmpeg/ )

    #FindAvdevice
#    if ( PKG_CONFIG_FOUND )
#      pkg_check_modules( AVDEVICE libavdevice )
#    endif ( PKG_CONFIG_FOUND )

#    FIND_PATH( AVDEVICE_INCLUDE_DIR avdevice.h
#               PATHS ${AVDEVICE_INCLUDE_DIRS}
#                     /usr/include/
#                     /usr/include/ffmpeg/
#               PATH_SUFFIXES libavdevice )
#
#    FIND_LIBRARY( AVDEVICE_LIBRARY avdevice
#                  PATHS ${AVDEVICE_LIBRARY_DIRS}        
#                        /usr/lib/
#                        /usr/lib/ffmpeg/ )
#    #FindSwscale
#    if ( PKG_CONFIG_FOUND )
#       pkg_check_modules( SWSCALE libswscale )
#    endif ( PKG_CONFIG_FOUND )
#
#    FIND_PATH( SWSCALE_INCLUDE_DIR swscale.h
#               PATHS ${SWSCALE_INCLUDE_DIRS}
#                     /usr/include/
#                     /usr/include/ffmpeg/
#               PATH_SUFFIXES libswscale )

#    FIND_LIBRARY( SWSCALE_LIBRARY swscale
#                  PATHS ${SWSCALE_LIBRARY_DIRS}
#                        /usr/lib/
#                        /usr/lib/ffmpeg/ )

endif( WIN32 )

SET( FFMPEG_FOUND FALSE )

IF ( AVFORMAT_INCLUDE_DIR AND AVFORMAT_LIBRARY )
    SET ( AVFORMAT_FOUND TRUE )
ENDIF ( AVFORMAT_INCLUDE_DIR AND AVFORMAT_LIBRARY )

IF ( AVCODEC_INCLUDE_DIR AND AVCODEC_LIBRARY ) 
    SET ( AVCODEC_FOUND TRUE )
ENDIF ( AVCODEC_INCLUDE_DIR AND AVCODEC_LIBRARY )

IF ( AVUTIL_INCLUDE_DIR AND AVUTIL_LIBRARY )
    SET ( AVUTIL_FOUND TRUE )
ENDIF ( AVUTIL_INCLUDE_DIR AND AVUTIL_LIBRARY )

IF ( AVDEVICE_INCLUDE_DIR AND AVDEVICE_LIBRARY ) 
    SET ( AVDEVICE_FOUND TRUE )
ENDIF ( AVDEVICE_INCLUDE_DIR AND AVDEVICE_LIBRARY )

IF ( SWSCALE_INCLUDE_DIR AND SWSCALE_LIBRARY )
    SET ( SWSCALE_FOUND TRUE )
ENDIF ( SWSCALE_INCLUDE_DIR AND SWSCALE_LIBRARY )


IF ( WIN32 )
    IF ( FFMPEG_INCLUDE_DIR AND FFMPEG_LIBRARY_DIR )
        SET( FFMPEG_FOUND TRUE )
    ENDIF ( FFMPEG_INCLUDE_DIR AND FFMPEG_LIBRARY_DIR )
ELSE ( WIN32 )
    IF ( AVFORMAT_INCLUDE_DIR OR AVCODEC_INCLUDE_DIR OR AVUTIL_INCLUDE_DIR OR AVDEVICE_FOUND OR SWSCALE_FOUND )
        SET ( FFMPEG_FOUND TRUE )

        SET ( FFMPEG_INCLUDE_DIR
              ${AVFORMAT_INCLUDE_DIR}
              ${AVCODEC_INCLUDE_DIR}
              ${AVUTIL_INCLUDE_DIR}
              #${AVDEVICE_INCLUDE_DIR}
              #${SWSCALE_INCLUDE_DIR} 
	      )
        
        SET ( FFMPEG_LIBRARIES 
              ${AVFORMAT_LIBRARY}
              ${AVCODEC_LIBRARY}
              ${AVUTIL_LIBRARY}
              #${AVDEVICE_LIBRARY}
              #${SWSCALE_LIBRARY} 
	      )
    ENDIF ( AVFORMAT_INCLUDE_DIR OR AVCODEC_INCLUDE_DIR OR AVUTIL_INCLUDE_DIR OR AVDEVICE_FOUND OR SWSCALE_FOUND )
ENDIF ( WIN32 )

