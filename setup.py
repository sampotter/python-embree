from setuptools import find_packages, setup
from setuptools.extension import Extension

from Cython.Build import cythonize

extensions = [
    Extension(
        'embree',
        ['embree.pyx'],
        libraries=['embree3'],
        include_dirs=['/opt/local/include',
                      '/root/embree/include'],
        library_dirs=['/opt/local/lib',
                      '/root/embree/lib']
    )
]

setup(
    name='embree',
    packages=find_packages(),
    ext_modules=cythonize(extensions),
    zip_safe=False
)
