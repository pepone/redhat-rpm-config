Name: brp-llvm-compile-lto-elf-test
Version: 1
Release: 1
Summary: Library package for testing brp-llvm-compile-lto-elf
License: MIT

BuildRequires: gcc
BuildRequires: brp-llvm-compile-lto-elf-test-lib

Source0: %{name}.c

%global debug_package %{nil}

# FIXME: I'm not sure why this doesn't work
%undefine _package_note_file


%description
%{summary}

%build
gcc ${CFLAGS} -c %{SOURCE0} -o %{name}.o
gcc ${LDFLAGS} %{name}.o %{_libdir}/%{name}-lib.a -o %{name}-ar
gcc ${LDFLAGS} %{name}.o %{_libdir}/%{name}-lib.o -o %{name}-obj

%check
./%{name}-ar | grep "Hello, world!"
./%{name}-obj | grep "Hello, world!"
