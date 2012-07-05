#
# try to find GTK (and glib) and GTKGLArea
#
#
# Jan Woetzel 06/2004: added /opt/gnome/include/gtk-1.2 path and $ENV{GTK_HOME}


# GTK_INCLUDE_DIR   - Directories to include to use GTK
# GTK_LIBRARIES     - Files to link against to use GTK
# GTK_FOUND         - If false, don't try to use GTK
# GTK_GL_FOUND      - If false, don't try to use GTK's GL features

# don't even bother under WIN32
IF(UNIX)

  FIND_PATH( GTK_gtk_INCLUDE_PATH gtk/gtk.h
    $ENV{GTK_HOME}
    /usr/include/gtk-2.0
    /usr/local/include/gtk-2.0
    /opt/gnome/include/gtk-2.0  )

  # Some Linux distributions (e.g. Red Hat) have glibconfig.h
  # and glib.h in different directories, so we need to look
  # for both.
  #  - Atanas Georgiev <atanas@cs.columbia.edu>

  FIND_PATH( GTK_glibconfig_INCLUDE_PATH glibconfig.h
    /opt/gnome/lib/glib-2.0/include
    /usr/lib/glib-2.0/include
    /usr/lib64/glib-2.0/include
  )
#MESSAGE("GTK_glibconfig_INCLUDE_PATH = ${GTK_glibconfig_INCLUDE_PATH}")

  FIND_PATH( GTK_glib_INCLUDE_PATH glib.h
    /opt/gnome/include/glib-2.0
    /usr/include/glib-2.0
  )
#MESSAGE(" = ${}")

  FIND_PATH( GTK_gtkgl_INCLUDE_PATH gtkgl/gtkglarea.h
    /usr/include
    /usr/local/include
    /usr/openwin/share/include
    /opt/gnome/include
  )

  FIND_PATH( GTK_pango_INCLUDE_PATH pango/pango.h
  /opt/gnome/include/pango-1.0
  /usr/include/pango-1.0
  )

  FIND_PATH( GTK_gdkconfig_INCLUDE_PATH gdkconfig.h
    /opt/gnome/lib/gtk-2.0/include
    /usr/lib/gtk-2.0/include
    /usr/lib64/gtk-2.0/include
  )

  FIND_PATH( GTK_cairo_INCLUDE_PATH cairo.h
    /opt/gnome/include/cairo
    /usr/include
    /usr/include/cairo )
  #MESSAGE("GTK_cairo_INCLUDE_PATH = ${GTK_cairo_INCLUDE_PATH}")

  FIND_PATH( GTK_atk_INCLUDE_PATH atk/atk.h
    /opt/gnome/include/atk-1.0
    /usr/include/atk-1.0
  )
  #MESSAGE("GTK_atk_INCLUDE_PATH = ${GTK_atk_INCLUDE_PATH}")

  FIND_LIBRARY( GTK_gtkgl_LIBRARY gtkgl
    /usr/lib
    /usr/local/lib
    /usr/openwin/lib
    /usr/X11R6/lib
    /opt/gnome/lib
  )

  #
  # The 12 suffix is thanks to the FreeBSD ports collection
  #

  FIND_LIBRARY( GTK_gtk_LIBRARY
    NAMES  gtk-x11-2.0 
    PATHS /usr/lib
          /usr/local/lib
          /usr/openwin/lib
          /usr/X11R6/lib
          /opt/gnome/lib
  )

  FIND_LIBRARY( GTK_gdk_LIBRARY
    NAMES  gdk-x11-2.0
    PATHS  /usr/lib
           /usr/local/lib
           /usr/openwin/lib
           /usr/X11R6/lib
           /opt/gnome/lib
  )

  FIND_LIBRARY( GTK_gmodule_LIBRARY
    NAMES  gmodule-2.0
    PATHS  /usr/lib
           /usr/local/lib
           /usr/openwin/lib
           /usr/X11R6/lib
           /opt/gnome/lib
  )

  FIND_LIBRARY( GTK_glib_LIBRARY
    NAMES  glib-2.0
    PATHS  /usr/lib
           /usr/local/lib
           /usr/openwin/lib
           /usr/X11R6/lib
           /opt/gnome/lib
  )

  FIND_LIBRARY( GTK_Xi_LIBRARY 
    NAMES Xi 
    PATHS /usr/lib 
    /usr/local/lib 
    /usr/openwin/lib 
    /usr/X11R6/lib 
    /opt/gnome/lib 
    ) 

  FIND_LIBRARY( GTK_gthread_LIBRARY
    NAMES  gthread-2.0
    PATHS  /usr/lib
           /usr/local/lib
           /usr/openwin/lib
           /usr/X11R6/lib
           /opt/gnome/lib
  )

  FIND_LIBRARY( GTK_gobject_LIBRARY
    NAMES  gobject-2.0
    PATHS 
           /opt/gnome/lib
  )

  IF(GTK_gtk_INCLUDE_PATH)
  IF(GTK_glibconfig_INCLUDE_PATH)
  IF(GTK_glib_INCLUDE_PATH)
  IF(GTK_gtk_LIBRARY)
  IF(GTK_glib_LIBRARY)
  IF(GTK_pango_INCLUDE_PATH)
    IF(GTK_atk_INCLUDE_PATH)
      IF(GTK_cairo_INCLUDE_PATH)
	# Assume that if gtk and glib were found, the other
	# supporting libraries have also been found.
	
	SET( GTK_FOUND "YES" )
	SET( GTK_INCLUDE_DIR  ${GTK_gtk_INCLUDE_PATH}
          ${GTK_glibconfig_INCLUDE_PATH}
          ${GTK_glib_INCLUDE_PATH} 
	  ${GTK_pango_INCLUDE_PATH}
	  ${GTK_gdkconfig_INCLUDE_PATH}
	  ${GTK_atk_INCLUDE_PATH}
	  ${GTK_cairo_INCLUDE_PATH})
	SET( GTK_LIBRARIES  ${GTK_gtk_LIBRARY}
          ${GTK_gdk_LIBRARY}
          ${GTK_glib_LIBRARY} )
	#			${GTK_gobject_LIBRARY})
    
      IF(GTK_gmodule_LIBRARY)
	SET(GTK_LIBRARIES ${GTK_LIBRARIES} ${GTK_gmodule_LIBRARY})
      ENDIF(GTK_gmodule_LIBRARY)
      IF(GTK_gthread_LIBRARY)
        SET(GTK_LIBRARIES ${GTK_LIBRARIES} ${GTK_gthread_LIBRARY})
      ENDIF(GTK_gthread_LIBRARY)
    ELSE(GTK_cairo_INCLUDE_PATH)
      MESSAGE("Can not find cairo")
    ENDIF(GTK_cairo_INCLUDE_PATH)
  ELSE(GTK_atk_INCLUDE_PATH)
    MESSAGE("Can not find atk")
  ENDIF(GTK_atk_INCLUDE_PATH)

  ELSE(GTK_pango_INCLUDE_PATH)
       MESSAGE("Can not find pango includes")
  ENDIF(GTK_pango_INCLUDE_PATH)
  ELSE(GTK_glib_LIBRARY)
       MESSAGE("Can not find glib lib")
  ENDIF(GTK_glib_LIBRARY)
  ELSE(GTK_gtk_LIBRARY)
       MESSAGE("Can not find gtk lib")
  ENDIF(GTK_gtk_LIBRARY)
  ELSE(GTK_glib_INCLUDE_PATH) 
   MESSAGE("Can not find glib includes")
  ENDIF(GTK_glib_INCLUDE_PATH) 
  ELSE(GTK_glibconfig_INCLUDE_PATH)
   MESSAGE("Can not find glibconfig")
  ENDIF(GTK_glibconfig_INCLUDE_PATH)
  ELSE(GTK_gtk_INCLUDE_PATH)
   MESSAGE("Can not find gtk includes")
  ENDIF(GTK_gtk_INCLUDE_PATH)

  MARK_AS_ADVANCED(
    GTK_gdk_LIBRARY
    GTK_glib_INCLUDE_PATH
    GTK_glib_LIBRARY
    GTK_glibconfig_INCLUDE_PATH
    GTK_gmodule_LIBRARY
    GTK_gthread_LIBRARY
    GTK_Xi_LIBRARY
    GTK_gtk_INCLUDE_PATH
    GTK_gtk_LIBRARY
    GTK_gtkgl_INCLUDE_PATH
    GTK_gtkgl_LIBRARY
    GTK_atk_INCLUDE_PATH
    GTK_gdkconfig_INCLUDE_PATH
#    GTK_gobject_LIBRARY
    GTK_pango_INCLUDE_PATH 
  )

ELSE(UNIX)
  # MESSAGE("FindGTK2 is working on UNIX/LINUX, only!")
ENDIF(UNIX)

