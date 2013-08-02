" Copyright (C) 2007, 2013 Michael Kapelko <kornerr@gmail.com>
" 
" This software is provided 'as-is', without any express or implied
" warranty.  In no event will the authors be held liable for any damages
" arising from the use of this software.
" 
" Permission is granted to anyone to use this software for any purpose,
" including commercial applications, and to alter it and redistribute it
" freely, subject to the following restrictions:
" 
" 1. The origin of this software must not be misrepresented; you must not
"    claim that you wrote the original software. If you use this software
"    in a product, an acknowledgment in the product documentation would be
"    appreciated but is not required.
" 2. Altered source versions must be plainly marked as such, and must not be
"    misrepresented as being the original software.
" 3. This notice may not be removed or altered from any source distribution.

" If you call "Acpp" when editing "/path/to/file/src/Window.cpp", the script:
" * sees if there's "/path/to/file/src/" directory;
" ** if so:
" *** switch to "/path/to/file/include/Window" if it exists;
" *** switch to "/path/to/file/include/Window.h" even if it doesn't exist;
" ** if not:
" *** switch to "/path/to/file/src/Window" if it exists;
" *** switch to "/path/to/file/src/Window.h" even if it doesn't exist.
"
" If you call "Acpp" when editing "/path/to/file/include/Window"
" or "/path/to/file/include/Window.h", the script:
" * sees if there's "/path/to/file/src/" directory;
" ** if so:
" *** switch to "/path/to/file/src/Window.cpp" even if it doesn't exist;
" ** if not:
" *** switch to "/path/to/file/include/Window.cpp" even if it doesn't exist.

function ComplementaryPath(fullPath, src, dst)
    let i = strridx(a:fullPath, a:src)
    if (i != -1)
        let leftPart = strpart(a:fullPath, 0, i)
        let rightPart = strpart(a:fullPath, i + strlen(a:src))
        let path = leftPart . a:dst . rightPart
        " Return complementary src directory.
        if (isdirectory(path))
            return path
        endif
    endif
    " Return current directory, because there's no complementary one.
    return a:fullPath
endfunction

function FileNameWithoutExt(fileName)
    let i = strridx(a:fileName, '.')
    if (i != -1)
        return strpart(a:fileName, 0, i)
    endif
    return a:fileName
endfunction

function IsHeader(ext)
    if (a:ext == '' || a:ext == 'h')
        return 1
    endif
    return 0
endfunction

function ComplementaryFile()
    let ext                = expand("%:e")
    let fullPath           = expand("%:p")
    let fileName           = expand("%:t")
    let fileNameWithoutExt = FileNameWithoutExt(fileName)
    let lenPath = strlen(fullPath) - strlen(fileName)
    let fullPath = strpart(fullPath, 0, lenPath)
    if (IsHeader(ext))
        return ComplementaryPath(fullPath, '/include/', '/src/') . fileNameWithoutExt . ".cpp"
    else
        let path = ComplementaryPath(fullPath, '/src/', '/include/')
        " If .h-less header exists, return it.
        let hlessHeader = path . fileNameWithoutExt
        if (filereadable(hlessHeader))
            " Force c++ syntax highlighting.
            set ft=cpp
            return hlessHeader
        endif
        " Othewise, return .h header.
        return path . fileNameWithoutExt . ".h"
    endif
endfunction

function OpenComplementaryFile()
    execute "e " . ComplementaryFile()
    execute "set ft=cpp"
endfunction

command Acpp : execute OpenComplementaryFile()
