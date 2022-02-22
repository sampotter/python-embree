import os

from setuptools import find_packages, setup
from setuptools.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        'embree',
        ['embree/embree.pyx'],
        libraries=['embree3'],
        include_dirs=[
            '/opt/local/include',
            os.path.expanduser('~/embree/include')],
        library_dirs=[
            '/opt/local/lib',
            os.path.expanduser('~/embree/lib')]
    )
]

cwd = os.path.abspath(os.path.expanduser(
    os.path.dirname(__file__)))
with open(os.path.join(cwd, 'README.md'), 'r') as f:
    long_description = f.read()
with open(os.path.join(cwd, 'embree', 'version.py'), 'r') as f:
    # use eval to get a clean string of version from file
    __version__ = eval(f.read().strip().split('=')[-1])


setup(
    name='embree',
    version=__version__,
    description='Ray queries on triangular meshes.',
    long_description=long_description,
    long_description_content_type='text/markdown',
    install_requires=['numpy'],
    packages=find_packages(),
    ext_modules=cythonize(extensions),
    zip_safe=False
)
