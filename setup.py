from setuptools import find_packages, setup
from setuptools.extension import Extension

from Cython.Build import cythonize

extensions = [
    Extension(
        'embree',
        ['embree/embree.pyx'],
        libraries=['embree3']
    )
]

setup(
    name='python-embree',
    packages=find_packages(),
    ext_modules=cythonize(extensions)
)
