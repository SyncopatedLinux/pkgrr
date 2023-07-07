#

```bash
-- Check if compiler accepts -pthread - no
CMake Error at /usr/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
  Could NOT find Threads (missing: Threads_FOUND)
Call Stack (most recent call first):
  /usr/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:600 (_FPHSA_FAILURE_MESSAGE)
  /usr/share/cmake/Modules/FindThreads.cmake:226 (FIND_PACKAGE_HANDLE_STANDARD_ARGS)
  CMakeLists.txt:204 (INCLUDE)


-- Configuring incomplete, errors occurred!
==> ERROR: A failure occurred in build().
    Aborting...
==> ERROR: Build failed, check /mnt/chroots/arch/b08x/build
```

https://github.com/alicevision/geogram/issues/2
