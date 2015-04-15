# These are the compilation flags that will be used in case there's no
# compilation database set.
flags = [
    '-Wall',
    '-Wextra',
    '-std=c++14',
    '-stdlib=libc++',
    '-x', 'c++',
    '-I', '.',
    '-I', 'include',
    '-isystem', '/usr/include/c++/v1',
    '-isystem', '/usr/include'
]


def FlagsForFile(filename):
    return {
        'flags': flags,
        'do_cache': True
    }
