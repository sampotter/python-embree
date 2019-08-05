# python-embree #

This library is a thin wrapper around Embree 3.

As much as possible, it tries to emulate the C API usage. The main
point of this is to avoid creating a new API which would obfuscate the
usage of the C API. Ideally, it should be easy to read the Embree
documentation or examples, and translate things straightforwardly to
equivalent Python code.

A secondary goal is to provide easy interoperability with numpy.
