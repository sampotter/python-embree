import os

import embree
import numpy as np
import unittest


cwd = os.path.expanduser(
    os.path.abspath(os.path.dirname(__file__)))


np.seterr('raise')


class TestIntersect1M(unittest.TestCase):
    def setUp(self):

        with open(os.path.join(cwd, 'data', 'sphere.npz'), 'rb') as f:
            npz = np.load(f)
            verts, faces = npz['V'], npz['F']

        self.verts = verts.astype(np.float32)
        self.num_verts = verts.shape[0]

        self.faces = faces.astype(np.uint32)
        self.num_faces = faces.shape[0]

        self.centroids = self.verts[self.faces].mean(1)

        self.device = embree.Device()
        self.scene = self.device.make_scene()
        self.geometry = self.device.make_geometry(embree.GeometryType.Triangle)

        vertex_buffer = self.geometry.set_new_buffer(
            embree.BufferType.Vertex,       # buf_type
            0,                              # slot
            embree.Format.Float3,           # fmt
            3 * np.dtype('float32').itemsize,  # byte_stride
            self.num_verts)                 # item_count
        vertex_buffer[:] = self.verts[:]

        index_buffer = self.geometry.set_new_buffer(
            embree.BufferType.Index,       # buf_type
            0,                             # slot
            embree.Format.Uint3,           # fmt
            3 * np.dtype('uint32').itemsize,  # byte_stride,
            self.num_faces)                # item count
        index_buffer[:] = self.faces[:]

        self.geometry.commit()
        self.scene.attach_geometry(self.geometry)
        self.geometry.release()
        self.scene.commit()

    def test_ray_shot_from_sphere_center(self):
        rayhit = embree.RayHit1M(self.num_faces)
        rayhit.org[:] = 0
        rayhit.dir[:] = np.divide(
            self.centroids,
            np.sqrt(np.sum(self.centroids**2, axis=1)).reshape(-1, 1)
        )
        rayhit.tnear[:] = 0
        rayhit.tfar[:] = np.inf
        rayhit.flags[:] = 0
        rayhit.geom_id[:] = embree.INVALID_GEOMETRY_ID

        context = embree.IntersectContext()
        self.scene.intersect1M(context, rayhit)

        self.assertTrue((rayhit.geom_id != embree.INVALID_GEOMETRY_ID).all())
        self.assertTrue((rayhit.prim_id == np.arange(self.num_faces)).all())

    def test_rays_shot_between_sphere_facets(self):
        N = self.num_faces

        rayhit = embree.RayHit1M(N**2)

        for i in range(N):
            rayhit.org[N * i:N * (i + 1)] = self.centroids[i]

        for i in range(N):
            D = self.centroids - self.centroids[i]
            dist = np.sqrt(np.sum(D**2, axis=1))
            dist[dist == 0] = np.inf
            D /= dist.reshape(-1, 1)
            rayhit.dir[N * i:N * (i + 1)] = D

        rayhit.tnear[:] = 0.01
        rayhit.tfar[:] = np.inf
        rayhit.flags[:] = 0
        rayhit.geom_id[:] = embree.INVALID_GEOMETRY_ID

        context = embree.IntersectContext()
        self.scene.intersect1M(context, rayhit)

        for i in range(N):
            geom_id = rayhit.geom_id[N * i:N * (i + 1)]
            self.assertTrue(geom_id[i] == embree.INVALID_GEOMETRY_ID)
            J = np.setdiff1d(np.arange(N), [i])
            self.assertTrue((geom_id[J] != embree.INVALID_GEOMETRY_ID).all())

        for i in range(N):
            prim_id = rayhit.prim_id[N * i:N * (i + 1)]
            J = np.setdiff1d(np.arange(N), [i])
            self.assertTrue((prim_id[J] == np.arange(N)[J]).all())


if __name__ == '__main__':
    unittest.main()
