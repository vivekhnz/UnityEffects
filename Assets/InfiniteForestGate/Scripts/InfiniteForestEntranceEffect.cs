using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(MeshFilter)), RequireComponent(typeof(MeshRenderer))]
public class InfiniteForestEntranceEffect : MonoBehaviour
{
    void Start()
    {
        var filter = GetComponent<MeshFilter>();
        filter.mesh = CreateMesh();
    }

    private Mesh CreateMesh()
    {
        var mesh = new Mesh();

        // store relative distance to edge in W component
        var left = new Vector4(-0.5f, -0.5f, 0, 0);  // bottom-left
        var top = new Vector4(0, 0.5f, 0, 0);        // top
        var right = new Vector4(0.5f, -0.5f, 0, 0);  // bottom-right
        var inner = new Vector4(0.0f, -0.2f, 5, 1);  // inside

        var uvLeft = new Vector2(0, 0);
        var uvRight = new Vector2(1, 0);
        var uvInner = new Vector2(0.5f, 1);

        // the UVs of each vertex are different for each triangle so we can't share vertices
        var vertices = new List<Vector4>
        {
            left, top, inner,
            top, right, inner,
            right, left, inner
        };
        var triangles = new List<int>();

        // store UVs and distance to edge in the mesh normals
        var uvs = new List<Vector2>
        {
            uvRight, uvLeft, uvInner,
            uvRight, uvLeft, uvInner,
            uvRight, uvLeft, uvInner
        };
        var uvDistances = new List<Vector3>();
        for (int i = 0; i < vertices.Count; i++)
        {
            triangles.Add(i);
            var uv = uvs[i];
            uvDistances.Add(new Vector3(uv.x, uv.y, vertices[i].w));
        }

        mesh.SetVertices(vertices.Select(v => (Vector3)v).ToList());
        mesh.SetTriangles(triangles.ToArray(), 0);
        mesh.SetNormals(uvDistances);
        return mesh;
    }
}
