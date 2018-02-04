using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(MeshFilter)), RequireComponent(typeof(MeshRenderer))]
public class InfiniteForestEntranceEffect : MonoBehaviour
{
    private Material effectMat;

    [Range(0, 100)]
    public int Slices = 1;

    void Start()
    {
        effectMat = GetComponent<MeshRenderer>().material;

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

        var vertices = new List<Vector3>();
        var triangles = new List<int>();
        var uvDistances = new List<Vector4>();

        vertices.Add(inner);
        uvDistances.Add(new Vector4(0.5f, 1, 1, 0.5f));

        AddTriangle(left, top, inner, 0, Slices, vertices, triangles, uvDistances);
        AddTriangle(top, right, inner, 1, Slices, vertices, triangles, uvDistances);
        AddTriangle(right, left, inner, 2, Slices, vertices, triangles, uvDistances);
        // AddTriangle(right, left, inner, 0, Slices, vertices, triangles, uvDistances);

        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles.ToArray(), 0);
        mesh.SetTangents(uvDistances);

        effectMat.SetVector("_InnerPoint", inner);

        return mesh;
    }

    private void AddTriangle(Vector4 a, Vector4 b, Vector4 c, int n, int slices,
        List<Vector3> vertices, List<int> triangles, List<Vector4> uvDistances)
    {
        // store the UVs and distance to edge in the mesh tangents
        Vector4 uvA = new Vector4(1, 0, a.w, 0);
        Vector4 uvB = new Vector4(0, 0, b.w, 1);
        Vector4 uvC = new Vector4(0.5f, 1, c.w, 0.5f);

        int verticesPerTri = 2 + (2 * slices);
        int start = verticesPerTri * n;

        // add inner-most triangle
        triangles.Add(0);
        triangles.Add(start + 1);
        triangles.Add(start + 2);

        float perSlice = 1f / (slices + 1);
        for (int i = 0; i < slices; i++)
        {
            float progress = perSlice * (i + 1);

            // add slice vertices
            vertices.Add(Vector3.Lerp(c, a, progress));
            vertices.Add(Vector3.Lerp(c, b, progress));
            uvDistances.Add(Vector4.Lerp(uvC, uvB, progress));
            uvDistances.Add(Vector4.Lerp(uvC, uvA, progress));

            // add slice triangles
            int sliceStart = start + (i * 2);
            triangles.Add(sliceStart + 1);
            triangles.Add(sliceStart + 3);
            triangles.Add(sliceStart + 2);

            triangles.Add(sliceStart + 2);
            triangles.Add(sliceStart + 3);
            triangles.Add(sliceStart + 4);
        }

        // add edge vertices
        vertices.Add(a);
        vertices.Add(b);
        uvDistances.Add(uvA);
        uvDistances.Add(uvB);
    }
}
