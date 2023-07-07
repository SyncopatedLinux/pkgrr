# qmidiarp


# making with qmake

```bash
src/main.cpp: In function ‘int main(int, char**)’:
src/main.cpp:96:11: error: ‘getpid’ was not declared in this scope; did you mean ‘getpt’?
   96 |     srand(getpid());
      |           ^~~~~~
```

can be resolved by adding:
```bash
#include <unistd.h>
#include <iostream>
```
to src/main.cpp

```bash
usr/bin/ld: /tmp/ccPnyJKE.ltrans5.ltrans.o: in function `JackDriver::deactivateJack()':
<artificial>:(.text+0x75d): undefined reference to `jack_deactivate'
/usr/bin/ld: /tmp/ccPnyJKE.ltrans5.ltrans.o: in function `JackDriver::callJack(int, QString const&)':
<artificial>:(.text+0xfcd): undefined reference to `jack_client_open'
/usr/bin/ld: <artificial>:(.text+0x1014): undefined reference to `jack_on_shutdown'
/usr/bin/ld: <artificial>:(.text+0x102a): undefined reference to `jack_set_process_callback'
/usr/bin/ld: <artificial>:(.text+0x107c): undefined reference to `jack_activate'
/usr/bin/ld: <artificial>:(.text+0x109e): undefined reference to `jack_transport_query'
/usr/bin/ld: <artificial>:(.text+0x10b0): undefined reference to `jack_get_sample_rate'
/usr/bin/ld: <artificial>:(.text+0x111c): undefined reference to `jack_client_open'
/usr/bin/ld: <artificial>:(.text+0x1163): undefined reference to `jack_on_shutdown'
/usr/bin/ld: <artificial>:(.text+0x1179): undefined reference to `jack_set_process_callback'
/usr/bin/ld: <artificial>:(.text+0x11dc): undefined reference to `jack_port_register'
/usr/bin/ld: <artificial>:(.text+0x1231): undefined reference to `jack_port_register'
/usr/bin/ld: <artificial>:(.text+0x1261): undefined reference to `jack_set_session_callback'
/usr/bin/ld: <artificial>:(.text+0x12b6): undefined reference to `jack_client_close'
/usr/bin/ld: /tmp/ccPnyJKE.ltrans5.ltrans.o: in function `JackDriver::~JackDriver()':
<artificial>:(.text+0x5728): undefined reference to `jack_client_close'
/usr/bin/ld: /tmp/ccPnyJKE.ltrans6.ltrans.o: in function `JackDriver::session_callback(_jack_session_event*, void*)':
<artificial>:(.text+0x5a2): undefined reference to `jack_session_reply'
/usr/bin/ld: <artificial>:(.text+0x5b7): undefined reference to `jack_session_event_free'
/usr/bin/ld: /tmp/ccPnyJKE.ltrans6.ltrans.o: in function `JackDriver::process_callback(unsigned int, void*)':
<artificial>:(.text+0x481f): undefined reference to `jack_transport_query'
/usr/bin/ld: <artificial>:(.text+0x4d1b): undefined reference to `jack_port_get_buffer'
/usr/bin/ld: <artificial>:(.text+0x4d5c): undefined reference to `jack_port_get_buffer'
/usr/bin/ld: <artificial>:(.text+0x4d88): undefined reference to `jack_midi_clear_buffer'
/usr/bin/ld: <artificial>:(.text+0x4d99): undefined reference to `jack_midi_get_event_count'
/usr/bin/ld: <artificial>:(.text+0x4db1): undefined reference to `jack_midi_event_get'
/usr/bin/ld: <artificial>:(.text+0x4e79): undefined reference to `jack_midi_event_reserve'
/usr/bin/ld: <artificial>:(.text+0x4f0b): undefined reference to `jack_midi_event_get'
/usr/bin/ld: <artificial>:(.text+0x53ba): undefined reference to `jack_midi_event_reserve'
collect2: error: ld returned 1 exit status
make: *** [Makefile:385: qmidiarp] Error 1
```
can be resolved by replacing:
```bash

CONFIG += link_pkgconfig
PKGCONFIG += jack
#LIBS += c:/Qt/Tools/mingw492_32/lib/libjack.lib
#INCLUDEPATH = c:/Qt/Tools/mingw492_32/include c:/Qt/5.6/mingw49_32/include/QtWidgets
```


autoreconf -fiv

## Without additional flags


```bash
g++ -std=c++11 -Wall -Wextra -Wno-deprecated-copy -D_REENTRANT  -DHAVE_CONFIG_H  -I.    -I/usr/include/qt/QtCore -I/usr/include/qt -I/usr/include/qt/QtGui -DQT_WIDGETS_LIB -I/usr/include/qt/QtWidgets -DQT_GUI_LIB -DQT_CORE_LIB  -fPIC -DAPPBUILD -Wno-deprecated-copy -g -O2 -MT qmidiarp-modulewidget_moc.o -MD -MP -MF .deps/qmidiarp-modulewidget_moc.Tpo -c -o qmidiarp-modulewidget_moc.o `test -f 'modulewidget_moc.cpp' || echo './'`modulewidget_moc.cpp
```



## With additional flags

```bash
export CFLAGS="-march=native -O3 -pipe -fno-plt -fexceptions \\n        -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security \\n        -fstack-clash-protection -fcf-protection"

export CFLAGS="-march=native -O2 -pipe -fno-plt -fexceptions \\n        -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security \\n        -fstack-clash-protection -fcf-protection"

export CFLAGS="-march=x86-64 -O2 -pipe -fno-plt -fexceptions \\n        -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security \\n        -fstack-clash-protection -fcf-protection"

export CFLAGS="-march=x86-64 -mtune=sandybridge -O2 -pipe -fno-plt -fexceptions \\n        -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security \\n        -fstack-clash-protection -fcf-protection"

export CFLAGS="-march=x86-64-v2 -mtune=sandybridge -O2 -pipe -fno-plt -fexceptions -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fstack-clash-protection -fcf-protection"

export MAKEFLAGS="-ffast-math -msse -msse2 -mfpmath=sse -fPIC"

export CFLAGS="-march=x86-64-v2 -mtune=sandybridge -O2 -pipe -fno-plt -fexceptions -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fstack-clash-protection -fcf-protection -ffast-math -msse -fPIC"

CXXFLAGS="$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"
```

```bash
g++ -std=c++11 -Wall -Wextra -Wno-deprecated-copy -D_REENTRANT  -DHAVE_CONFIG_H  -I.    -I/usr/include/qt/QtCore -I/usr/include/qt -I/usr/include/qt/QtGui -DQT_WIDGETS_LIB -I/usr/include/qt/QtWidgets -DQT_GUI_LIB -DQT_CORE_LIB  -fPIC -DAPPBUILD -Wno-deprecated-copy -march=x86-64-v2 -mtune=sandybridge -O2 -pipe -fno-plt -fexceptions -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fstack-clash-protection -fcf-protection -ffast-math -msse -msse2 -mfpmath=sse -fPIC -Wp,-D_GLIBCXX_ASSERTIONS -MT qmidiarp-parstore_moc.o -MD -MP -MF .deps/qmidiarp-parstore_moc.Tpo -c -o qmidiarp-parstore_moc.o `test -f 'parstore_moc.cpp' || echo './'`parstore_moc.cpp
```

Regardless of what flags are applied, the application will crash when a button is pressed...

```bash
[ninjabot][~/Workspace/syncopated/packages/pkgbuilds/qmidiarp-git/code](master) qmidiarp 
Internal Transport stopped
jack process callback registered
Session callback registered
/usr/include/c++/12.2.1/bits/stl_vector.h:1123: std::vector<_Tp, _Alloc>::reference std::vector<_Tp, _Alloc>::operator[](size_type) [with _Tp = Sample; _Alloc = std::allocator<Sample>; reference = Sample&; size_type = long unsigned int]: Assertion '__n < this->size()' failed.
[1]    98187 IOT instruction (core dumped)  qmidiarp
```
