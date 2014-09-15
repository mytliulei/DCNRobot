##################################################################################
# Version 4.10    $Revision: 3 $
# $Author: Mgithens $
#
# $Workfile: ixFileUtils.tcl $
#
#    Copyright © 1997 - 2005 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    09-05-2002    MG    Genesis
#
# Description: Contains miscellaneous file commands.
#
##################################################################################


namespace eval ixFileUtils {
    variable filesToClose ""
}


########################################################################
# Procedure:   ixFileUtils::closeOpenFiles
#
# Description: Either close all open file handles or close all file handles opened by Ixia routines
#              The advanced test parameter closeAllFilesInCleanUp controls which one is done
#
# Arguments:   None
#
# Returns:     Nothing
########################################################################
proc ixFileUtils::closeAll {} \
{
    variable filesToClose

    if {[info tclversion] >= 8.3} {
        set closeAllFiles [advancedTestParameter cget -closeAllFilesInCleanUp]
        set listOfFiles ""
        if {$closeAllFiles} {
            set listOfFiles $filesToClose
        } else {
            foreach fileId [file channels file*] {
                set index [lsearch -exact $filesToClose $fileId]
                if {$index >= 0} {
                    lappend listOfFiles $fileId
                }
            }
        }
        foreach fileId $listOfFiles {
            close $fileId
        }        
    }
}


########################################################################
# Procedure:   ixFileUtils::addFileToList
#
# Description: Add a file handle to the list of handles to be closed during the cleanUp procedure
#
# Arguments:   fileId - the file handle to add
#
# Returns:     Nothing
########################################################################
proc ixFileUtils::addFileToList { fileId } \
{
    variable filesToClose

    lappend filesToClose $fileId
}


########################################################################
# Procedure:   ixFileUtils::removeFileFromList
#
# Description: Remove a file handle from the list of handles to be closed during the cleanUp procedure
#
# Arguments:   fileId - the file handle to remove
#
# Returns:     Nothing
########################################################################
proc ixFileUtils::removeFileFromList { fileId } \
{
    variable filesToClose

    set index [lsearch -exact $filesToClose $fileId]
    if {$index >= 0} {
        set filesToClose [lreplace $filesToClose $index $index]
    }
}


########################################################################
# Procedure:   ixFileUtils::open
#
# Description: This command opens a file
#
# Arguments:   filename - full path to filename
#              access - file access parameter to use
#              permission - file permission parameter to use
#
# Returns:     fileID if successful, or "" if unsuccessful
########################################################################
proc ixFileUtils::open {filename {access ""} {permission ""}} \
{
    if {[catch {eval ::open [list $filename] $access $permission} fileID]} {
        set fileID ""
    } else {
        ixFileUtils::addFileToList $fileID
    }
    return $fileID
}


########################################################################
# Procedure:   ixFileUtils::close
#
# Description: This command closes a file
#
# Arguments:   fileId - channel id of the file to be closed
#
# Returns:     Nothing
########################################################################
proc ixFileUtils::close {fileId} \
{
    catch {::close $fileId}
    ixFileUtils::removeFileFromList $fileId
}
