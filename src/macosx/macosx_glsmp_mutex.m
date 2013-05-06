/*
===========================================================================

Return to Castle Wolfenstein single player GPL Source Code
Copyright (C) 1999-2010 id Software LLC, a ZeniMax Media company. 

This file is part of the Return to Castle Wolfenstein single player GPL Source Code (RTCW SP Source Code).  

RTCW SP Source Code is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RTCW SP Source Code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RTCW SP Source Code.  If not, see <http://www.gnu.org/licenses/>.

In addition, the RTCW SP Source Code is also subject to certain additional terms. You should have received a copy of these additional terms immediately following the terms and conditions of the GNU General Public License which accompanied the RTCW SP Source Code.  If not, please request a copy in writing from id Software at the address below.

If you have questions concerning this license or the applicable additional terms, you may contact in writing id Software LLC, c/o ZeniMax Media Inc., Suite 120, Rockville, Maryland 20850 USA.

===========================================================================
*/

#import "macosx/macosx_glimp.h"

#include "renderer/tr_local.h"
#import "macosx/macosx_local.h"
#import "macosx/macosx_display.h"

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <pthread.h>

//
// The main Q3 SMP API
//

static pthread_mutex_t smpMutex;
static pthread_cond_t mainThreadCondition;
static pthread_cond_t renderThreadCondition;

static volatile qboolean smpDataChanged;
static volatile void     *smpData;


static void *GLimp_RenderThreadWrapper( void *arg ) {
	Com_Printf( "Render thread starting\n" );

	( ( void( * ) () )arg )();

#ifndef USE_CGLMACROS
	// Unbind the context before we die
	OSX_GLContextClearCurrent();
#endif

	Com_Printf( "Render thread terminating\n" );

	return arg;
}

qboolean GLimp_SpawnRenderThread( void ( *function )( void ) ) {
	pthread_t renderThread;
	int rc;

	pthread_mutex_init( &smpMutex, NULL );
	pthread_cond_init( &mainThreadCondition, NULL );
	pthread_cond_init( &renderThreadCondition, NULL );

	rc = pthread_create( &renderThread, NULL, GLimp_RenderThreadWrapper, function );
	if ( rc ) {
		ri.Printf( PRINT_ALL, "pthread_create returned %d: %s", rc, strerror( rc ) );
		return qfalse;
	} else {
		rc = pthread_detach( renderThread );
		if ( rc ) {
			ri.Printf( PRINT_ALL, "pthread_detach returned %d: %s", rc, strerror( rc ) );
		}
	}

	return qtrue;
}

// Called in the rendering thread to wait until a command buffer is ready.
// The command buffer returned might be NULL, indicating that the rendering thread should exit.
void *GLimp_RendererSleep( void ) {
	void *data;

	GLSTAMP( "GLimp_RendererSleep start", 0 );

#ifndef USE_CGLMACROS
	// Clear the current context while we sleep so the main thread can access it
	OSX_GLContextClearCurrent();
#endif

	pthread_mutex_lock( &smpMutex ); {
		// Clear out any data we had and signal the main thread that we are no longer busy
		smpData = NULL;
		smpDataChanged = qfalse;
		pthread_cond_signal( &mainThreadCondition );

		// Wait until we get something new to work on
		while ( !smpDataChanged )
			pthread_cond_wait( &renderThreadCondition, &smpMutex );

		// Record the data (if any).
		data = smpData;
	} pthread_mutex_unlock( &smpMutex );

#ifndef USE_CGLMACROS
	// We are going to render a frame... retake the context
	OSX_GLContextSetCurrent();
#endif

	GLSTAMP( "GLimp_RendererSleep end", 0 );

	return (void *)data;
}

// Called from the main thread to wait until the rendering thread is done with the command buffer.
void GLimp_FrontEndSleep( void ) {
	GLSTAMP( "GLimp_FrontEndSleep start", 0 );

	pthread_mutex_lock( &smpMutex ); {
		while ( smpData ) {
#if 0
			struct timespec ts;
			int result;

			ts.tv_sec = 1;
			ts.tv_nsec = 0;
			result = pthread_cond_timedwait_relative_np( &mainThreadCondition, &smpMutex, &ts );
			if ( result ) {
				Com_Printf( "GLimp_FrontEndSleep timed out.  Probably due to R_SyncRenderThread called due to Com_Error being called\n" );
				break;
			}
#else
			pthread_cond_wait( &mainThreadCondition, &smpMutex );
#endif
		}
	} pthread_mutex_unlock( &smpMutex );


#ifndef USE_CGLMACROS
	// We are done waiting for the background thread, take the current context back.
	OSX_GLContextSetCurrent();
#endif

	GLSTAMP( "GLimp_FrontEndSleep end", 0 );
}

// This is called in the main thread to issue another command
// buffer to the rendering thread.  This is always called AFTER
// GLimp_FrontEndSleep, so we know that there is no command
// pending in 'smpData'.
void GLimp_WakeRenderer( void *data ) {
	GLSTAMP( "GLimp_WakeRenderer start", data );

#ifndef USE_CGLMACROS
	// We want the background thread to draw stuff.  Give up the current context
	OSX_GLContextClearCurrent();
#endif

	pthread_mutex_lock( &smpMutex ); {
		// Store the new data pointer and wake up the rendering thread
		assert( smpData == NULL );
		smpData = data;
		smpDataChanged = qtrue;
		pthread_cond_signal( &renderThreadCondition );
	} pthread_mutex_unlock( &smpMutex );

	GLSTAMP( "GLimp_WakeRenderer end", data );
}

