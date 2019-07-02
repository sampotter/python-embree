# cython: embedsignature=True
# cython: language_level=3

import numpy as np

from enum import Enum

from libc.stdio cimport printf
from libc.stdlib cimport free, malloc

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

    RTCGeometry rtcNewGeometry(RTCDevice, RTCGeometryType)
    void rtcRetainGeometry(RTCGeometry)
    void rtcReleaseGeometry(RTCGeometry)
    void rtcCommitGeometry(RTCGeometry)
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
    void rtcIntersect1(RTCScene, RTCIntersectContext*, RTCRayHit*)
    void rtcIntersect1M(RTCScene, RTCIntersectContext*, RTCRayHit*,
                        unsigned, size_t)

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
            Format.Int: np.int32,
            Format.Float: np.single,
            Format.Float3: np.single
        }[self]

    @property
    def dtype(self):
        return self.as_dtype()

    def get_nelts(self):
        return {
            Format.Uint3: 3,
            Format.Float3: 3
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

cdef typed_mv_from_ptr(void* ptr, fmt, size_t item_count):
    cdef float[:] float_mv
    cdef unsigned[:] uint_mv
    cdef int[:] int_mv
    if fmt in {Format.Uint3}:
        uint_mv = <unsigned[:fmt.nelts*item_count]>ptr
        return uint_mv
    elif fmt in {Format.Int}:
        int_mv = <int[:item_count]>ptr
        return int_mv
    elif fmt in {Format.Float, Format.Float3}:
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

    def __cinit__(self, Device device, size_t byte_size):
        self._buffer = rtcNewBuffer(device._device, byte_size)

    def __dealloc__(self):
        self.release()

    def retain(self):
        rtcRetainBuffer(self._buffer)

    def release(self):
        rtcReleaseBuffer(self._buffer)

cdef class Device:
    cdef:
        RTCDevice _device

    def __cinit__(self):
        self._device = rtcNewDevice(NULL)

    def __dealloc__(self):
        self.release()

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

    def __cinit__(self, Device device, geometry_type):
        self._geometry = rtcNewGeometry(device._device, geometry_type.value)

    def __dealloc__(self):
        self.release()

    def retain(self):
        rtcRetainGeometry(self._geometry)

    def release(self):
        rtcReleaseGeometry(self._geometry)

    def commit(self):
        rtcCommitGeometry(self._geometry)

    # def set_shared_buffer(self, buf_type, unsigned slot, fmt, arr):
    #     arr_ = np.asarray(arr, dtype=arr.dtype)
    #     cdef arr_.dtype[:] mv = arr_
    #     rtcSetSharedGeometryBuffer(
    #         self._geometry, buf_type.value, slot, fmt.value,
    #         &mv[0], 0, arr_.strides[0], arr_.shape[0])

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

cdef class Ray:
    cdef:
        RTCRay _ray

    def __cinit__(self, origin, direction, tnear=0, tfar=np.inf):
        self._ray.org_x = origin[0]
        self._ray.org_y = origin[1]
        self._ray.org_z = origin[2]
        self._ray.tnear = tnear
        self._ray.dir_x = direction[0]
        self._ray.dir_y = direction[1]
        self._ray.dir_z = direction[2]
        self._ray.tfar = tfar
        # TODO: this isn't finished

    @property
    def origin(self):
        return (self._ray.org_x, self._ray.org_y, self._ray.org_z)

    @property
    def direction(self):
        return (self._ray.dir_x, self._ray.dir_y, self._ray.dir_z)

    @property
    def tnear(self):
        return self._ray.tnear

    @property
    def tfar(self):
        return self._ray.tfar

    def __repr__(self):
        return 'Ray(direction = %s, origin = %s, tfar = %s, tnear = %s)' % (
            self.direction, self.origin, self.tfar, self.tnear
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

    def __init__(self, origin, direction, tnear=0.0, tfar=np.inf):
        self._rayhit.ray.org_x = origin[0]
        self._rayhit.ray.org_y = origin[1]
        self._rayhit.ray.org_z = origin[2]
        self._rayhit.ray.tnear = tnear
        self._rayhit.ray.dir_x = direction[0]
        self._rayhit.ray.dir_y = direction[1]
        self._rayhit.ray.dir_z = direction[2]
        self._rayhit.ray.tfar = tfar
        self._rayhit.hit.primID = INVALID_GEOMETRY_ID
        self._rayhit.hit.geomID = INVALID_GEOMETRY_ID
        # TODO: this isn't finished

    @property
    def origin(self):
        return (
            self._rayhit.ray.org_x,
            self._rayhit.ray.org_y,
            self._rayhit.ray.org_z
        )

    @property
    def direction(self):
        return (
            self._rayhit.ray.dir_x,
            self._rayhit.ray.dir_y,
            self._rayhit.ray.dir_z
        )

    @property
    def tnear(self):
        return self._rayhit.ray.tnear

    @property
    def tfar(self):
        return self._rayhit.ray.tfar

    @property
    def normal(self):
        return (
            self._rayhit.hit.Ng_x,
            self._rayhit.hit.Ng_y,
            self._rayhit.hit.Ng_z
        )

    @property
    def uv(self):
        return (
            self._rayhit.hit.u,
            self._rayhit.hit.v
        )

    @property
    def prim_id(self):
        return self._rayhit.hit.primID

    @property
    def geom_id(self):
        return self._rayhit.hit.geomID

    @property
    def inst_id(self):
        return self._rayhit.hit.instID[0]

    def __repr__(self):
        return (
            'RayHit(direction = %s, origin = %s, tfar = %s, tnear = %s, ' + \
            'geom_id = %d, inst_id = %d, normal = %s, prim_id = %d, uv = %s)'
        ) % (
            self.direction, self.origin, self.tfar, self.tnear,
            self.geom_id, self.inst_id, self.normal, self.prim_id, self.uv
        )

cdef class IntersectContext:
    cdef:
        RTCIntersectContext _context

    def __cinit__(self):
        rtcInitIntersectContext(&self._context)

cdef class Scene:
    cdef:
        RTCScene _scene

    def __cinit__(self, Device device):
        self._scene = rtcNewScene(device._device)

    def __dealloc__(self):
        self.release()

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

    def intersect1(self, IntersectContext context, RayHit rayhit):
        rtcIntersect1(self._scene, &context._context, &rayhit._rayhit)

    # def intersect1M(self, ):
    #     cdef unsigned M = len(rays)
    #     cdef RTCIntersectContext context
    #     rtcInitIntersectContext
