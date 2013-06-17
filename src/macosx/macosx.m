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

#import <sys/types.h>
#import <sys/sysctl.h>

static unsigned int _Sys_ProcessorCount = 0;

unsigned int Sys_ProcessorCount() {
	if ( !_Sys_ProcessorCount ) {
		int name[] = {CTL_HW, HW_NCPU};
		size_t size;

		size = sizeof( _Sys_ProcessorCount );
		if ( sysctl( name, 2, &_Sys_ProcessorCount, &size, NULL, 0 ) < 0 ) {
			perror( "sysctl" );
			_Sys_ProcessorCount = 1;
		} else {
			Com_Printf( "System processor count is %d\n", _Sys_ProcessorCount );
		}
	}

	return _Sys_ProcessorCount;
}

// Function stub for some missing func which was not provided with
// the original source code
void Sys_PumpEvents(void)
{

}
