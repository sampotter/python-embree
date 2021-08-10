# cython: embedsignature=True
# cython: language_level=3

import errno
import numpy as np

from enum import Enum

from libc.stdio cimport printf
from libc.stdlib cimport free

# In this section, we define an aligned memory allocation function,
# "aligned_alloc". This should be used throughout this .pyx file to
# ensure that memory allocated for use by Embree is 16-byte
# aligned. This must be done differently on each major platform.
#
# TODO: update the Windows and Darwin implementations of aligned_alloc
# to ensure that they have the same "exception interface" as the Linux
# version of aligned_alloc.
IF UNAME_SYSNAME == "Windows":
    cdef extern from "<malloc.h>":
        cdef void *_aligned_malloc(size_t size, size_t alignment)
    cdef void *aligned_alloc(size_t size, size_t alignment):
        return _aligned_malloc(size, alignment)
ELIF UNAME_SYSNAME == "Darwin":
    # malloc is 16-byte mem aligned by default on Darwin
    from libc.stdlib cimport malloc
    cdef void *aligned_alloc(size_t size, size_t alignment):
        return malloc(size)
ELSE:
    from posix.stdlib cimport posix_memalign
    cdef void *aligned_alloc(size_t size, size_t alignment):
        cdef void *ptr = NULL
        cdef int code = posix_memalign(&ptr, alignment, size)
        if code == errno.EINVAL:
            raise Exception(
                'posix_memalign: bad alignment (size = %, alignment = %)' % (
                    size, alignment))
        elif code == errno.ENOMEM:
            raise Exception('posix_memalign: insufficient memory to allocate')
        elif code != 0:
            raise Exception('posix_memalign: unknown error code')
        return ptr

DEF RTC_MAX_INSTANCE_LEVEL_COUNT = 1

cdef extern from "embree3/rtcore.h":

    cdef struct RTCBufferTy:
        pass
    ctypedef RTCBufferTy* RTCBuffer

    cdef struct RTCDeviceTy:
        pass
    ctypedef RTCDeviceTy* RTCDevice

    cdef struct RTCGeometryTy:
        pass
    ctypedef RTCGeometryTy* RTCGeometry

    cdef struct RTCSceneTy:
        pass
    ctypedef RTCSceneTy* RTCScene

    cdef enum RTCBufferType:
        RTC_BUFFER_TYPE_INDEX = 0
        RTC_BUFFER_TYPE_VERTEX = 1
        RTC_BUFFER_TYPE_VERTEX_ATTRIBUTE = 2
        RTC_BUFFER_TYPE_NORMAL = 3
        RTC_BUFFER_TYPE_TANGENT = 4
        RTC_BUFFER_TYPE_NORMAL_DERIVATIVE = 5
        RTC_BUFFER_TYPE_GRID = 8
        RTC_BUFFER_TYPE_FACE = 16
        RTC_BUFFER_TYPE_LEVEL = 17
        RTC_BUFFER_TYPE_EDGE_CREASE_INDEX = 18
        RTC_BUFFER_TYPE_EDGE_CREASE_WEIGHT = 19
        RTC_BUFFER_TYPE_VERTEX_CREASE_INDEX = 20
        RTC_BUFFER_TYPE_VERTEX_CREASE_WEIGHT = 21
        RTC_BUFFER_TYPE_HOLE = 22
        RTC_BUFFER_TYPE_FLAGS = 32

    cdef enum RTCError:
        RTC_ERROR_NONE = 0
        RTC_ERROR_UNKNOWN = 1
        RTC_ERROR_INVALID_ARGUMENT = 2
        RTC_ERROR_INVALID_OPERATION = 3
        RTC_ERROR_OUT_OF_MEMORY = 4
        RTC_ERROR_UNSUPPORTED_CPU = 5
        RTC_ERROR_CANCELLED = 6

    cdef enum RTCFormat:
        RTC_FORMAT_UNDEFINED = 0
        RTC_FORMAT_UCHAR = 0x1001
        RTC_FORMAT_UCHAR2 = 0x1002
        RTC_FORMAT_UCHAR3 = 0x1003
        RTC_FORMAT_UCHAR4 = 0x1004
        RTC_FORMAT_CHAR = 0x2001
        RTC_FORMAT_CHAR2 = 0x2002
        RTC_FORMAT_CHAR3 = 0x2003
        RTC_FORMAT_CHAR4 = 0x2004
        RTC_FORMAT_USHORT = 0x3001
        RTC_FORMAT_USHORT2 = 0x3002
        RTC_FORMAT_USHORT3 = 0x3003
        RTC_FORMAT_USHORT4 = 0x3004
        RTC_FORMAT_SHORT = 0x4001
        RTC_FORMAT_SHORT2 = 0x4002
        RTC_FORMAT_SHORT3 = 0x4003
        RTC_FORMAT_SHORT4 = 0x4004
        RTC_FORMAT_UINT = 0x5001
        RTC_FORMAT_UINT2 = 0x5002
        RTC_FORMAT_UINT3 = 0x5003
        RTC_FORMAT_UINT4 = 0x5004
        RTC_FORMAT_INT = 0x6001
        RTC_FORMAT_INT2 = 0x6002
        RTC_FORMAT_INT3 = 0x6003
        RTC_FORMAT_INT4 = 0x6004
        RTC_FORMAT_ULLONG = 0x7001
        RTC_FORMAT_ULLONG2 = 0x7002
        RTC_FORMAT_ULLONG3 = 0x7003
        RTC_FORMAT_ULLONG4 = 0x7004
        RTC_FORMAT_LLONG = 0x8001
        RTC_FORMAT_LLONG2 = 0x8002
        RTC_FORMAT_LLONG3 = 0x8003
        RTC_FORMAT_LLONG4 = 0x8004
        RTC_FORMAT_FLOAT = 0x9001
        RTC_FORMAT_FLOAT2 = 0x9002
        RTC_FORMAT_FLOAT3 = 0x9003
        RTC_FORMAT_FLOAT4 = 0x9004
        RTC_FORMAT_FLOAT5 = 0x9005
        RTC_FORMAT_FLOAT6 = 0x9006
        RTC_FORMAT_FLOAT7 = 0x9007
        RTC_FORMAT_FLOAT8 = 0x9008
        RTC_FORMAT_FLOAT9 = 0x9009
        RTC_FORMAT_FLOAT10 = 0x9010
        RTC_FORMAT_FLOAT11 = 0x9011
        RTC_FORMAT_FLOAT12 = 0x9012
        RTC_FORMAT_FLOAT13 = 0x9013
        RTC_FORMAT_FLOAT14 = 0x9014
        RTC_FORMAT_FLOAT15 = 0x9015
        RTC_FORMAT_FLOAT16 = 0x9016
        RTC_FORMAT_FLOAT2X2_ROW_MAJOR = 0x9122
        RTC_FORMAT_FLOAT2X3_ROW_MAJOR = 0x9123
        RTC_FORMAT_FLOAT2X4_ROW_MAJOR = 0x9124
        RTC_FORMAT_FLOAT3X2_ROW_MAJOR = 0x9132
        RTC_FORMAT_FLOAT3X3_ROW_MAJOR = 0x9133
        RTC_FORMAT_FLOAT3X4_ROW_MAJOR = 0x9134
        RTC_FORMAT_FLOAT4X2_ROW_MAJOR = 0x9142
        RTC_FORMAT_FLOAT4X3_ROW_MAJOR = 0x9143
        RTC_FORMAT_FLOAT4X4_ROW_MAJOR = 0x9144
        RTC_FORMAT_FLOAT2X2_COLUMN_MAJOR = 0x9222
        RTC_FORMAT_FLOAT2X3_COLUMN_MAJOR = 0x9223
        RTC_FORMAT_FLOAT2X4_COLUMN_MAJOR = 0x9224
        RTC_FORMAT_FLOAT3X2_COLUMN_MAJOR = 0x9232
        RTC_FORMAT_FLOAT3X3_COLUMN_MAJOR = 0x9233
        RTC_FORMAT_FLOAT3X4_COLUMN_MAJOR = 0x9234
        RTC_FORMAT_FLOAT4X2_COLUMN_MAJOR = 0x9242
        RTC_FORMAT_FLOAT4X3_COLUMN_MAJOR = 0x9243
        RTC_FORMAT_FLOAT4X4_COLUMN_MAJOR = 0x9244
        RTC_FORMAT_GRID = 0xA00

    cdef enum RTCGeometryType:
        RTC_GEOMETRY_TYPE_TRIANGLE = 0
        RTC_GEOMETRY_TYPE_QUAD = 1
        RTC_GEOMETRY_TYPE_GRID = 2
        RTC_GEOMETRY_TYPE_SUBDIVISION = 8
        RTC_GEOMETRY_TYPE_FLAT_LINEAR_CURVE = 17
        RTC_GEOMETRY_TYPE_ROUND_BEZIER_CURVE = 24
        RTC_GEOMETRY_TYPE_FLAT_BEZIER_CURVE = 25
        RTC_GEOMETRY_TYPE_NORMAL_ORIENTED_BEZIER_CURVE = 26
        RTC_GEOMETRY_TYPE_ROUND_BSPLINE_CURVE = 32
        RTC_GEOMETRY_TYPE_FLAT_BSPLINE_CURVE = 33
        RTC_GEOMETRY_TYPE_NORMAL_ORIENTED_BSPLINE_CURVE = 34
        RTC_GEOMETRY_TYPE_ROUND_HERMITE_CURVE = 40
        RTC_GEOMETRY_TYPE_FLAT_HERMITE_CURVE = 41
        RTC_GEOMETRY_TYPE_NORMAL_ORIENTED_HERMITE_CURVE = 42
        RTC_GEOMETRY_TYPE_SPHERE_POINT = 50
        RTC_GEOMETRY_TYPE_DISC_POINT = 51
        RTC_GEOMETRY_TYPE_ORIENTED_DISC_POINT = 52
        RTC_GEOMETRY_TYPE_USER = 120
        RTC_GEOMETRY_TYPE_INSTANCE = 121

    cdef enum RTCSceneFlags:
        RTC_SCENE_FLAG_NONE = 0,
        RTC_SCENE_FLAG_DYNAMIC = (1 << 0)
        RTC_SCENE_FLAG_COMPACT = (1 << 1)
        RTC_SCENE_FLAG_ROBUST = (1 << 2)
        RTC_SCENE_FLAG_CONTEXT_FILTER_FUNCTION = (1 << 3)

    cdef enum RTCIntersectContextFlags:
        RTC_INTERSECT_CONTEXT_FLAG_NONE = 0,
        RTC_INTERSECT_CONTEXT_FLAG_INCOHERENT = (0 << 0)
        RTC_INTERSECT_CONTEXT_FLAG_COHERENT = (1 << 0)

    cdef struct RTCRay:
        float org_x
        float org_y
        float org_z
        float tnear
        float dir_x
        float dir_y
        float dir_z
        float time
        float tfar
        unsigned mask
        unsigned id
        unsigned flags

    cdef struct RTCHit:
        float Ng_x
        float Ng_y
        float Ng_z
        float u
        float v
        unsigned primID
        unsigned geomID
        unsigned instID[RTC_MAX_INSTANCE_LEVEL_COUNT]

    cdef struct RTCRayHit:
        RTCRay ray
        RTCHit hit

    cdef struct RTCRayNp:
        float *org_x
        float *org_y
        float *org_z
        float *tnear
        float *dir_x
        float *dir_y
        float *dir_z
        float *time
        float *tfar
        unsigned int *mask
        unsigned int *id
        unsigned int *flags

    cdef struct RTCHitNp:
        float *Ng_x
        float *Ng_y
        float *Ng_z
        float *u
        float *v
        unsigned int *primID
        unsigned int *geomID
        unsigned int *instID[RTC_MAX_INSTANCE_LEVEL_COUNT]

    cdef struct RTCRayHitNp:
        RTCRayNp ray
        RTCHitNp hit

    cdef struct RTCRayN:
        pass

    cdef struct RTCHitN:
        pass

    cdef struct RTCFilterFunctionNArguments:
        int* valid
        void* geometryUserPtr
        const RTCIntersectContext* context
        RTCRayN* ray
        RTCHitN* hit
        unsigned int N

    ctypedef void(*RTCFilterFunctionN)(const RTCFilterFunctionNArguments*)

    cdef struct RTCIntersectContext:
        RTCIntersectContextFlags flags
        RTCFilterFunctionN filter
        unsigned int instID[RTC_MAX_INSTANCE_LEVEL_COUNT]

    RTCBuffer rtcNewBuffer(RTCDevice, size_t)
    RTCBuffer rtcNewSharedBuffer(RTCDevice, void*, size_t)
    void* rtcGetBufferData(RTCBuffer)
    void rtcRetainBuffer(RTCBuffer)
    void rtcReleaseBuffer(RTCBuffer)

    RTCDevice rtcNewDevice(const char*)
    void rtcRetainDevice(RTCDevice)
    void rtcReleaseDevice(RTCDevice)
    RTCError rtcGetDeviceError(RTCDevice)

    ctypedef void (*RTCErrorFunction)(void*, RTCError, const char*)
    void rtcSetDeviceErrorFunction(RTCDevice, RTCErrorFunction, void*)

    RTCGeometry rtcNewGeometry(RTCDevice, RTCGeometryType)
    void rtcRetainGeometry(RTCGeometry)
    void rtcReleaseGeometry(RTCGeometry)
    void rtcCommitGeometry(RTCGeometry)
    void rtcUpdateGeometryBuffer(RTCGeometry, RTCBufferType, unsigned)
    void rtcSetGeometryBuffer(RTCGeometry, RTCBufferType, unsigned,
                              RTCFormat, RTCBuffer, size_t, size_t, size_t)
    void rtcSetSharedGeometryBuffer(RTCGeometry, RTCBufferType, unsigned,
                                    RTCFormat, void*, size_t, size_t, size_t)
    void* rtcSetNewGeometryBuffer(RTCGeometry, RTCBufferType, unsigned,
                                  RTCFormat, size_t, size_t)
    void* rtcGetGeometryBufferData(RTCGeometry, RTCBufferType, unsigned)

    void rtcInitIntersectContext(RTCIntersectContext*)

    RTCScene rtcNewScene(RTCDevice)
    void rtcRetainScene(RTCScene)
    void rtcReleaseScene(RTCScene)
    unsigned rtcAttachGeometry(RTCScene, RTCGeometry)
    void rtcDetachGeometry(RTCScene, unsigned)
    void rtcCommitScene(RTCScene)
    void rtcSetSceneFlags(RTCScene, RTCSceneFlags)

    void rtcIntersect1(RTCScene, RTCIntersectContext*, RTCRayHit*)
    void rtcIntersect1M(RTCScene, RTCIntersectContext*, RTCRayHit*,
                        unsigned, size_t)
    void rtcOccluded1(RTCScene, RTCIntersectContext*, RTCRay*)
    void rtcOccluded1M(RTCScene, RTCIntersectContext*, RTCRay*, unsigned,
                       size_t)

    void rtcIntersectNp(RTCScene, RTCIntersectContext*, RTCRayHitNp*, unsigned)


INVALID_GEOMETRY_ID = <unsigned int> -1

class BufferType(Enum):
    Index = 0
    Vertex = 1
    VertexAttribute = 2
    Normal = 3
    Tangent = 4
    NormalDerivative = 5
    Grid = 8
    Face = 16
    Level = 17
    EdgeCreaseIndex = 18
    EdgeCreaseWeight = 19
    VertexCreaseIndex = 20
    VertexCreaseWeight = 21
    Hole = 22
    Flags = 32

class Error(Enum):
    Success = 0
    Unknown = 1
    InvalidArgument = 2
    InvalidOperation = 3
    OutOfMemory = 4
    UnsupportedCpu = 5
    Cancelled = 6

class Format(Enum):
    Undefined = 0
    Uchar = 0x1001
    Uchar2 = 0x1002
    Uchar3 = 0x1003
    Uchar4 = 0x1004
    Char = 0x2001
    Char2 = 0x2002
    Char3 = 0x2003
    Char4 = 0x2004
    Ushort = 0x3001
    Ushort2 = 0x3002
    Ushort3 = 0x3003
    Ushort4 = 0x3004
    Short = 0x4001
    Short2 = 0x4002
    Short3 = 0x4003
    Short4 = 0x4004
    Uint = 0x5001
    Uint2 = 0x5002
    Uint3 = 0x5003
    Uint4 = 0x5004
    Int = 0x6001
    Int2 = 0x6002
    Int3 = 0x6003
    Int4 = 0x6004
    Ullong = 0x7001
    Ullong2 = 0x7002
    Ullong3 = 0x7003
    Ullong4 = 0x7004
    Llong = 0x8001
    Llong2 = 0x8002
    Llong3 = 0x8003
    Llong4 = 0x8004
    Float = 0x9001
    Float2 = 0x9002
    Float3 = 0x9003
    Float4 = 0x9004
    Float5 = 0x9005
    Float6 = 0x9006
    Float7 = 0x9007
    Float8 = 0x9008
    Float9 = 0x9009
    Float10 = 0x9010
    Float11 = 0x9011
    Float12 = 0x9012
    Float13 = 0x9013
    Float14 = 0x9014
    Float15 = 0x9015
    Float16 = 0x9016
    Float2x2RowMajor = 0x9122
    Float2x3RowMajor = 0x9123
    Float2x4RowMajor = 0x9124
    Float3x2RowMajor = 0x9132
    Float3x3RowMajor = 0x9133
    Float3x4RowMajor = 0x9134
    Float4x2RowMajor = 0x9142
    Float4x3RowMajor = 0x9143
    Float4x4RowMajor = 0x9144
    Float2x2ColumnMajor = 0x9222
    Float2x3ColumnMajor = 0x9223
    Float2x4ColumnMajor = 0x9224
    Float3x2ColumnMajor = 0x9232
    Float3x3ColumnMajor = 0x9233
    Float3x4ColumnMajor = 0x9234
    Float4x2ColumnMajor = 0x9242
    Float4x3ColumnMajor = 0x9243
    Float4x4ColumnMajor = 0x9244
    Grid = 0xA00

    def as_dtype(self):
        return {
            Format.Uint3: np.uint32,
            Format.Uint4: np.uint32,
            Format.Int: np.int32,
            Format.Float: np.single,
            Format.Float3: np.single,
            Format.Float4: np.single
        }[self]

    @property
    def dtype(self):
        return self.as_dtype()

    def get_nelts(self):
        return {
            Format.Uint3: 3,
            Format.Uint4: 4,
            Format.Float3: 3,
            Format.Float4: 4
        }[self]

    @property
    def nelts(self):
        return self.get_nelts()

class GeometryType(Enum):
    Triangle = 0
    Quad = 1
    Grid = 2
    Subdivision = 8
    FlatLinearCurve = 17
    RoundBezierCurve = 24
    FlatBezierCurve = 25
    NormalOrientedBezierCurve = 26
    RoundBsplineCurve = 32
    FlatBsplineCurve = 33
    NormalOrientedBsplineCurve = 34
    RoundHermiteCurve = 40
    FlatHermiteCurve = 41
    NormalOrientedHermiteCurve = 42
    SpherePoint = 50
    DiscPoint = 51
    OrientedDiscPoint = 52
    User = 120
    Instance = 121

class SceneFlags(Enum):
    NONE = 0
    DYNAMIC = (1 << 0)
    COMPACT = (1 << 1)
    ROBUST = (1 << 2)
    CONTEXT_FILTER_FUNCTION = (1 << 3)

cdef typed_mv_from_ptr(void* ptr, fmt, size_t item_count):
    cdef float[:] float_mv
    cdef unsigned[:] uint_mv
    cdef int[:] int_mv
    if fmt in {Format.Uint3, Format.Uint4}:
        uint_mv = <unsigned[:fmt.nelts*item_count]>ptr
        return uint_mv
    elif fmt in {Format.Int}:
        int_mv = <int[:item_count]>ptr
        return int_mv
    elif fmt in {Format.Float, Format.Float3, Format.Float4}:
        float_mv = <float[:fmt.nelts*item_count]>ptr
        return float_mv

cdef array_from_ptr(void* ptr, fmt, item_count):
    mv = typed_mv_from_ptr(ptr, fmt, item_count)
    arr = np.asarray(mv, dtype=fmt.dtype)
    if fmt.nelts > 1:
        arr = arr.reshape(item_count, fmt.nelts)
    return arr

cdef class Buffer:
    cdef:
        RTCBuffer _buffer
        Device device

    def __cinit__(self, Device device, size_t byte_size):
        self._buffer = rtcNewBuffer(device._device, byte_size)

    def retain(self):
        rtcRetainBuffer(self._buffer)

    def release(self):
        rtcReleaseBuffer(self._buffer)

cdef void simple_error_function(void* userPtr, RTCError code, const char* str):
    print('%s: %s' % (Error(code), str))

cdef class Device:
    cdef:
        RTCDevice _device

    def __cinit__(self):
        self._device = rtcNewDevice(NULL)

        # TODO: hardcode an error function until we decide on a nice
        # way of exposing error functions to the library user
        rtcSetDeviceErrorFunction(self._device, simple_error_function, NULL);

    def retain(self):
        rtcRetainDevice(self._device)

    def release(self):
        rtcReleaseDevice(self._device)

    def get_error(self):
        return Error(rtcGetDeviceError(self._device))

    def make_buffer(self, byte_size):
        return Buffer(self, byte_size)

    def make_geometry(self, geometry_type):
        return Geometry(self, geometry_type)

    def make_scene(self):
        return Scene(self)

cdef class Geometry:
    cdef:
        RTCGeometry _geometry
        Device device

    def __cinit__(self, Device device, geometry_type):
        self._geometry = rtcNewGeometry(device._device, geometry_type.value)

    def retain(self):
        rtcRetainGeometry(self._geometry)

    def release(self):
        rtcReleaseGeometry(self._geometry)

    def commit(self):
        rtcCommitGeometry(self._geometry)

    def set_new_buffer(self, buf_type, unsigned slot, fmt,
                       size_t byte_stride, size_t item_count):
        if byte_stride % 4 != 0:
            raise Exception('byte_stride must be aligned to 4 bytes')
        cdef void* ptr = rtcSetNewGeometryBuffer(
            self._geometry, buf_type.value, slot, fmt.value, byte_stride,
            item_count)
        return array_from_ptr(ptr, fmt, item_count)

    def get_buffer(self, buf_type, unsigned slot, fmt, size_t item_count):
        cdef void* ptr = rtcGetGeometryBufferData(
            self._geometry, buf_type.value, slot)
        return array_from_ptr(ptr, fmt, item_count)

    def update_buffer(self, buf_type, unsigned slot):
        rtcUpdateGeometryBuffer(self._geometry, buf_type.value, slot)


cdef class Ray:
    cdef:
        RTCRay _ray

    @property
    def org(self):
        return np.asarray(<float[:3]> &self._ray.org_x)

    @org.setter
    def org(self, org):
        self._ray.org_x = org[0]
        self._ray.org_y = org[1]
        self._ray.org_z = org[2]

    @property
    def tnear(self):
        return self._ray.tnear

    @tnear.setter
    def tnear(self, float tnear):
        self._ray.tnear = tnear

    @property
    def dir(self):
        return np.asarray(<float[:3]> &self._ray.dir_x)

    @dir.setter
    def dir(self, dir):
        self._ray.dir_x = dir[0]
        self._ray.dir_y = dir[1]
        self._ray.dir_z = dir[2]

    @property
    def time(self):
        return self._ray.time

    @time.setter
    def time(self, float time):
        self._ray.time = time

    @property
    def tfar(self):
        return self._ray.tfar

    @tfar.setter
    def tfar(self, float tfar):
        self._ray.tfar = tfar

    @property
    def mask(self):
        return self._ray.mask

    @mask.setter
    def mask(self, unsigned mask):
        self._ray.mask = mask

    @property
    def id(self):
        return self._ray.id

    @id.setter
    def id(self, unsigned id):
        self._ray.id = id

    @property
    def flags(self):
        return self._ray.flags

    @flags.setter
    def flags(self, unsigned flags):
        self._ray.flags = flags

    def __repr__(self):
        return 'Ray(dir = %s, org = %s, tfar = %s, tnear = %s)' % (
            self.dir, self.org, self.tfar, self.tnear
        )

cdef class Hit:
    cdef:
        RTCHit _hit

    def __cinit__(self):
        self._hit.primID = INVALID_GEOMETRY_ID
        self._hit.geomID = INVALID_GEOMETRY_ID

    @property
    def normal(self):
        return (self._hit.Ng_x, self._hit.Ng_y, self._hit.Ng_z)

    @property
    def uv(self):
        return (self._hit.u, self._hit.v)

    @property
    def prim_id(self):
        return self._hit.primID

    @property
    def geom_id(self):
        return self._hit.geomID

    @property
    def inst_id(self):
        return self._hit.instID[0]

    def __repr__(self):
        return 'Hit(geom_id = %d, inst_id = %d, normal = %s, prim_id = %d, uv = %s)' % (
            self.geom_id, self.inst_id, self.normal, self.prim_id, self.uv
        )

cdef class RayHit:
    cdef:
        RTCRayHit _rayhit

    @property
    def org(self):
        return np.asarray(<float[:3]> &self._rayhit.ray.org_x)

    @org.setter
    def org(self, org):
        self._rayhit.ray.org_x = org[0]
        self._rayhit.ray.org_y = org[1]
        self._rayhit.ray.org_z = org[2]

    @property
    def dir(self):
        return np.asarray(<float[:3]> &self._rayhit.ray.dir_x)

    @dir.setter
    def dir(self, dir):
        self._rayhit.ray.dir_x = dir[0]
        self._rayhit.ray.dir_y = dir[1]
        self._rayhit.ray.dir_z = dir[2]

    @property
    def tnear(self):
        return self._rayhit.ray.tnear

    @tnear.setter
    def tnear(self, tnear):
        self._rayhit.ray.tnear = tnear

    @property
    def tfar(self):
        return self._rayhit.ray.tfar

    @tfar.setter
    def tfar(self, tfar):
        self._rayhit.ray.tfar = tfar

    @property
    def normal(self):
        return np.asarray(<float[:3]> &self._rayhit.hit.Ng_x)

    @property
    def uv(self):
        return np.asarray(<float[:2]> &self._rayhit.hit.u)

    @property
    def prim_id(self):
        return self._rayhit.hit.primID

    @prim_id.setter
    def prim_id(self, prim_id):
        self._rayhit.hit.primID = prim_id

    @property
    def geom_id(self):
        return self._rayhit.hit.geomID

    @geom_id.setter
    def geom_id(self, geom_id):
        self._rayhit.hit.geomID = geom_id

    @property
    def inst_id(self):
        return np.asarray(
            <unsigned[:RTC_MAX_INSTANCE_LEVEL_COUNT]> self._rayhit.hit.instID)

    def __repr__(self):
        return (
            'RayHit(dir = %s, org = %s, tfar = %s, tnear = %s, ' + \
            'geom_id = %d, inst_id = %d, normal = %s, prim_id = %d, uv = %s)'
        ) % (
            self.dir, self.org, self.tfar, self.tnear,
            self.geom_id, self.inst_id, self.normal, self.prim_id, self.uv
        )

cdef class Ray1M:
    cdef:
        RTCRay *_ray
        unsigned _M

    def __cinit__(self, unsigned M):
        cdef size_t size = M*sizeof(RTCRay)
        self._ray = <RTCRay *>aligned_alloc(size, 0x10)
        if self._ray == NULL:
            raise Exception('failed to allocate %d bytes' % (size,))
        self._M = M

    def __dealloc__(self):
        free(self._ray)

    @property
    def size(self):
        return self._M

    def toarray(self):
        return np.asarray(<RTCRay[:self._M]> self._ray)

    @property
    def org(self):
        cdef float[:, :] mv = <float[:self._M, :3]> &self._ray[0].org_x
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def tnear(self):
        cdef float[:] mv = <float[:self._M]> &self._ray[0].tnear
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def dir(self):
        cdef float[:, :] mv = <float[:self._M, :3]> &self._ray[0].dir_x
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def time(self):
        cdef float[:] mv = <float[:self._M]> &self._ray[0].time
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def tfar(self):
        cdef float[:] mv = <float[:self._M]> &self._ray[0].tfar
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def mask(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._ray[0].mask
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def id(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._ray[0].id
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

    @property
    def flags(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._ray[0].flags
        mv.strides[0] = sizeof(RTCRay)
        return np.asarray(mv)

cdef class RayHit1M:
    cdef:
        RTCRayHit *_rayhit
        unsigned _M

    def __cinit__(self, unsigned M):
        cdef size_t size = M*sizeof(RTCRayHit)
        self._rayhit = <RTCRayHit *>aligned_alloc(size, 0x10)
        if self._rayhit == NULL:
            raise Exception('failed to allocate %d bytes' % (size,))
        self._M = M

    def __dealloc__(self):
        free(self._rayhit)

    @property
    def size(self):
        return self._M

    def toarray(self):
        return np.asarray(<RTCRayHit[:self._M]> self._rayhit)

    @property
    def org(self):
        cdef float[:, :] mv = <float[:self._M, :3]> &self._rayhit[0].ray.org_x
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def tnear(self):
        cdef float[:] mv = <float[:self._M]> &self._rayhit[0].ray.tnear
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def dir(self):
        cdef float[:, :] mv = <float[:self._M, :3]> &self._rayhit[0].ray.dir_x
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def time(self):
        cdef float[:] mv = <float[:self._M]> &self._rayhit[0].ray.time
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def tfar(self):
        cdef float[:] mv = <float[:self._M]> &self._rayhit[0].ray.tfar
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def mask(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._rayhit[0].ray.mask
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def id(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._rayhit[0].ray.id
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def flags(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._rayhit[0].ray.flags
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def normal(self):
        cdef float[:, :] mv = <float[:self._M, :3]> &self._rayhit[0].hit.Ng_x
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def uv(self):
        cdef float[:, :] mv = <float[:self._M, :2]> &self._rayhit[0].hit.u
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def prim_id(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._rayhit[0].hit.primID
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def geom_id(self):
        cdef unsigned[:] mv = <unsigned[:self._M]> &self._rayhit[0].hit.geomID
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

    @property
    def inst_id(self):
        cdef unsigned[:, :] mv = \
            <unsigned[:self._M, :RTC_MAX_INSTANCE_LEVEL_COUNT]> \
            &self._rayhit[0].hit.instID[0]
        mv.strides[0] = sizeof(RTCRayHit)
        return np.asarray(mv)

cdef class RayHitNp:
    cdef:
        RTCRayHitNp _rayhit
        unsigned N

    def __cinit__(self, unsigned N):
        cdef RTCRayNp *ray = &self._rayhit.ray
        ray.org_x = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.org_y = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.org_z = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.tnear = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.dir_x = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.dir_y = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.dir_z = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.time = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.tfar = <float *>aligned_alloc(N*sizeof(float), 0x10)
        ray.mask = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)
        ray.id = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)
        ray.flags = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)

        cdef RTCHitNp *hit = &self._rayhit.hit
        hit.Ng_x = <float *>aligned_alloc(N*sizeof(float), 0x10)
        hit.Ng_y = <float *>aligned_alloc(N*sizeof(float), 0x10)
        hit.Ng_z = <float *>aligned_alloc(N*sizeof(float), 0x10)
        hit.u = <float *>aligned_alloc(N*sizeof(float), 0x10)
        hit.v = <float *>aligned_alloc(N*sizeof(float), 0x10)
        hit.primID = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)
        hit.geomID = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)
        for i in range(RTC_MAX_INSTANCE_LEVEL_COUNT):
            hit.instID[i] = <unsigned *>aligned_alloc(N*sizeof(unsigned), 0x10)

    def __dealloc__(self):
        free(self._rayhit.ray.org_x)
        free(self._rayhit.ray.org_y)
        free(self._rayhit.ray.org_z)
        free(self._rayhit.ray.tnear)
        free(self._rayhit.ray.dir_x)
        free(self._rayhit.ray.dir_y)
        free(self._rayhit.ray.dir_z)
        free(self._rayhit.ray.time)
        free(self._rayhit.ray.tfar)
        free(self._rayhit.ray.mask)
        free(self._rayhit.ray.id)
        free(self._rayhit.ray.flags)
        free(self._rayhit.hit.Ng_x)
        free(self._rayhit.hit.Ng_y)
        free(self._rayhit.hit.Ng_z)
        free(self._rayhit.hit.u)
        free(self._rayhit.hit.v)
        free(self._rayhit.hit.primID)
        free(self._rayhit.hit.geomID)
        for i in range(RTC_MAX_INSTANCE_LEVEL_COUNT):
            free(self._rayhit.hit.instID[i])

    @property
    def size(self):
        return self._N

    @property
    def org_x(self):
        return np.asarray(<float[:self._N]>self._rayhit.ray.org_x)

    @property
    def org_y(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.org_y)

    @property
    def org_z(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.org_z)

    @property
    def tnear(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.tnear)

    @property
    def dir_x(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.dir_x)

    @property
    def dir_y(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.dir_y)

    @property
    def dir_z(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.dir_z)

    @property
    def mask(self):
        np.asarray(<unsigned[:self._N]>self._rayhit.ray.mask)

    @property
    def flags(self):
        np.asarray(<unsigned[:self._N]>self._rayhit.ray.flags)

    @property
    def time(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.time)

    @property
    def tfar(self):
        np.asarray(<float[:self._N]>self._rayhit.ray.tfar)

    @property
    def Ng_x(self):
        np.asarray(<float[:self._N]>self._rayhit.hit.Ng_x)

    @property
    def Ng_y(self):
        np.asarray(<float[:self._N]>self._rayhit.hit.Ng_y)

    @property
    def Ng_z(self):
        np.asarray(<float[:self._N]>self._rayhit.hit.Ng_z)

    @property
    def u(self):
        np.asarray(<float[:self._N]>self._rayhit.hit.u)

    @property
    def v(self):
        np.asarray(<float[:self._N]>self._rayhit.hit.v)

    @property
    def primID(self):
        np.asarray(<unsigned[:self._N]>self._rayhit.hit.primID)

    @property
    def geomID(self):
        np.asarray(<unsigned[:self._N]>self._rayhit.hit.geomID)

    @property
    def instID(self):
        return tuple(
            <unsigned[:self._N]>self._rayhit.hit.instID[i]
            for i in range(RTC_MAX_INSTANCE_LEVEL_COUNT)
        )

cdef class IntersectContext:
    cdef:
        RTCIntersectContext _context

    def __cinit__(self):
        rtcInitIntersectContext(&self._context)

cdef class Scene:
    cdef:
        RTCScene _scene
        Device device

    def __cinit__(self, Device device):
        self._scene = rtcNewScene(device._device)

    def retain(self):
        rtcRetainScene(self._scene)

    def release(self):
        rtcReleaseScene(self._scene)

    def attach_geometry(self, Geometry geometry):
        return rtcAttachGeometry(self._scene, geometry._geometry)

    def detach_geometry(self, geom_id):
        rtcDetachGeometry(self._scene, geom_id)

    def commit(self):
        rtcCommitScene(self._scene)

    def set_flags(self, flags):
        if isinstance(flags, SceneFlags):
            flags = flags.value
        rtcSetSceneFlags(self._scene, flags)

    def intersect1(self, IntersectContext context, RayHit rayhit):
        rtcIntersect1(self._scene, &context._context, &rayhit._rayhit)

    def intersect1M(self, IntersectContext context, RayHit1M rayhit):
        rtcIntersect1M(self._scene, &context._context, rayhit._rayhit,
                       rayhit._M, sizeof(RTCRayHit))

    def intersectNp(self, IntersectContext context, RayHitNp rayhit):
        rtcIntersectNp(self._scene, &context._context, &rayhit._rayhit,
                       rayhit._N)

    def occluded1(self, IntersectContext context, Ray ray):
        rtcOccluded1(self._scene, &context._context, &ray._ray)

    def occluded1M(self, IntersectContext context, Ray1M ray):
        rtcOccluded1M(self._scene, &context._context, ray._ray, ray._M,
                      sizeof(RTCRay))
