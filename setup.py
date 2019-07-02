from setuptools import find_packages, setup
from setuptools.extension import Extension

from Cython.Build import cythonize

extensions = [
    Extension(
        'embree',
        ['embree.pyx'],
        libraries=['embree3']
    )
]

setup(
    name='embree',
    packages=find_packages(),
    ext_modules=cythonize(extensions),
    zip_safe=False
)
